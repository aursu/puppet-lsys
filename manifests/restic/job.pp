# @summary Define one restic backup job (dump → restic → forget)
#
# Generates a wrapper script and a cron entry for a single backup job
# writing into an `lsys::restic::repository`. The dump is fed to restic
# with `restic backup --stdin-from-command` (restic >= 0.16): restic runs
# the dump command itself and ABORTS the snapshot if the command exits
# non-zero, so a failed/partial dump never becomes a "successful" backup
# (this is why the raw `dump | restic backup --stdin` pipe is avoided).
#
# After a successful backup the job runs `restic forget` scoped to this
# job's tag (per-workload retention). Pruning is handled separately by the
# owning `lsys::restic::repository` (single lock owner).
#
# @param repository      short name of the target `lsys::restic::repository`.
# @param command         argv of the dump command (NOT a shell string), passed
#                        to restic after `--`. Keeps quoting exact, no shell.
# @param stdin_filename  virtual filename recorded in the snapshot.
# @param snapshot_tag    restic tag for this job (default: the resource title).
# @param minute          cron minute.
# @param hour            cron hour.
# @param monthday        cron monthday.
# @param month           cron month.
# @param weekday         cron weekday.
# @param crontab         whole `minute hour monthday month weekday` string; when set it overrides the discrete cron fields.
# @param keep            forget retention policy, keyed by restic keep-* class.
# @param user            cron user (must reach the DB socket/creds).
#
# @example
#   lsys::restic::job { 'cem_www_prod':
#     repository     => 'mariadb',
#     command        => ['/usr/bin/mariadb-dump', '--single-transaction', 'cem_www_prod'],
#     stdin_filename => 'cem_www_prod.sql',
#     hour           => '*',
#     minute         => '55',
#   }
define lsys::restic::job (
  String            $repository,
  Array[String]     $command,
  String            $stdin_filename,
  String            $snapshot_tag  = $title,
  String            $minute        = '0',
  String            $hour          = '*',
  String            $monthday      = '*',
  String            $month         = '*',
  String            $weekday       = '*',
  Optional[String]  $crontab       = undef,
  Hash[Enum['last', 'hourly', 'daily', 'weekly', 'monthly', 'yearly'], Integer] $keep = {
    'hourly' => 24,
    'daily'  => 7,
  },
  String            $user          = 'root',
) {
  include lsys::restic

  $bin_dir    = $lsys::restic::bin_dir
  $env_file   = "${lsys::restic::config_dir}/${repository}.env"
  $lockfile   = "/run/restic-${repository}.lock"
  $script     = "${bin_dir}/backup-${title}.sh"
  $restic_run = "${bin_dir}/restic-run"

  $forget_flags = $keep.map |$rule, $count| { "--keep-${rule} ${count}" }

  # A whole crontab string (as commonly stored in Hiera) overrides the
  # discrete fields: `minute hour monthday month weekday`.
  if $crontab =~ String {
    $fields        = split($crontab, /\s+/)
    $cron_minute   = $fields[0]
    $cron_hour     = $fields[1]
    $cron_monthday = $fields[2]
    $cron_month    = $fields[3]
    $cron_weekday  = $fields[4]
  }
  else {
    $cron_minute   = $minute
    $cron_hour     = $hour
    $cron_monthday = $monthday
    $cron_month    = $month
    $cron_weekday  = $weekday
  }

  file { $script:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => epp('lsys/restic/job.sh.epp', {
        restic_run     => $restic_run,
        repo_envfile   => $env_file,
        command        => $command,
        stdin_filename => $stdin_filename,
        tag            => $snapshot_tag,
        lockfile       => $lockfile,
        forget_flags   => $forget_flags,
    }),
    require => Lsys::Restic::Repository[$repository],
  }

  cron { "restic backup ${title}":
    command  => "${script} 2>&1 | /usr/bin/logger -t restic-backup-${title}",
    user     => $user,
    minute   => $cron_minute,
    hour     => $cron_hour,
    monthday => $cron_monthday,
    month    => $cron_month,
    weekday  => $cron_weekday,
    require  => File[$script],
  }
}
