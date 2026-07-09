# @summary Define one restic repository (env file, init, prune schedule)
#
# Writes a 0600 environment file describing a single restic repository
# (`RESTIC_REPOSITORY` + `RESTIC_PASSWORD` + any backend env such as S3
# credentials), optionally initialises the repository, and installs a
# dedicated `prune` cron. Prune is deliberately kept OUT of the per-run
# `forget` in `lsys::restic::job`: prune takes an exclusive repository
# lock and is expensive, so it runs once on its own schedule while each
# backup job only runs the cheap `forget`.
#
# The title is the repository's short name; the env file is
# `${lsys::restic::config_dir}/<title>.env` and jobs reference it by that
# same short name.
#
# @param repository    the RESTIC_REPOSITORY value (local path or s3:… URL).
# @param password      repository encryption password (loss = unrecoverable).
# @param env           extra backend env vars (e.g. AWS_ACCESS_KEY_ID); land
#                      in the 0600 env file.
# @param init          run `restic init` if the repository is not yet present.
# @param cache_dir     optional RESTIC_CACHE_DIR.
# @param manage_prune  install the prune cron for this repository.
# @param prune_minute  prune cron minute.
# @param prune_hour    prune cron hour.
# @param prune_weekday prune cron weekday.
#
# @example
#   lsys::restic::repository { 'mariadb':
#     repository => '/share/backups/restic/cem3/mariadb',
#     password   => $repo_password,
#   }
define lsys::restic::repository (
  String                              $repository,
  Variant[String, Sensitive[String]] $password,
  Hash[String, String]                $env           = {},
  Boolean                             $init          = true,
  Optional[String]                    $cache_dir     = undef,
  Boolean                             $manage_prune  = true,
  String                              $prune_minute  = '20',
  String                              $prune_hour    = '4',
  String                              $prune_weekday = '*',
) {
  include lsys::restic

  $config_dir = $lsys::restic::config_dir
  $bin_dir    = $lsys::restic::bin_dir
  $env_file   = "${config_dir}/${title}.env"
  $lockfile   = "/run/restic-${title}.lock"
  $restic_run = "${bin_dir}/restic-run"

  $pass = $password =~ Sensitive ? {
    true    => $password.unwrap,
    default => $password,
  }

  file { $env_file:
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0600',
    show_diff => false,
    content   => Sensitive(epp('lsys/restic/repository.env.epp', {
        repository => $repository,
        password   => $pass,
        env        => $env,
        cache_dir  => $cache_dir,
    })),
    require   => Class['lsys::restic'],
  }

  if $init {
    # `restic cat config` succeeds only when the repo exists AND the
    # password matches, so it is a safe idempotency guard for init.
    exec { "lsys-restic-init-${title}":
      command => "${restic_run} ${env_file} init",
      unless  => "${restic_run} ${env_file} cat config",
      require => [File[$env_file], File[$restic_run]],
    }
  }

  if $manage_prune {
    $prune_script = "${bin_dir}/restic-${title}-prune.sh"

    file { $prune_script:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0750',
      content => epp('lsys/restic/prune.sh.epp', {
          restic_run   => $restic_run,
          repo_envfile => $env_file,
          lockfile     => $lockfile,
      }),
      require => File[$env_file],
    }

    cron { "restic prune ${title}":
      command => "${prune_script} 2>&1 | /usr/bin/logger -t restic-prune-${title}",
      user    => 'root',
      minute  => $prune_minute,
      hour    => $prune_hour,
      weekday => $prune_weekday,
      require => File[$prune_script],
    }
  }
}
