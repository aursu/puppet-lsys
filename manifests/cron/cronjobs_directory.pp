# @summary
#   Manages the main cron job directories and optionally purges unmanaged jobs.
#
# @description
#   This class ensures that the main cron job directories exist with the desired mode.
#   It can also purge unmanaged files from these directories, except for system defaults.
#   By default, it manages `/etc/cron.d`, `/etc/cron.hourly`, `/etc/cron.daily`,
#   `/etc/cron.weekly`, and `/etc/cron.monthly`.
#
# @param items
#   The list of cron job directories to manage. Defaults to the standard cron directories.
# @param manage
#   Whether to manage the cron job directories. If false, no resources are applied.
# @param mode
#   The file mode to set on the cron job directories (e.g., '0750').
# @param purge
#   Whether to purge all unmanaged files from the cron job directories, except system defaults.
#
# @example
#   include lsys::cron::cronjobs_directory
class lsys::cron::cronjobs_directory (
  Array[Stdlib::Unixpath] $items = [
    '/etc/cron.d',
    '/etc/cron.hourly',
    '/etc/cron.daily',
    '/etc/cron.weekly',
    '/etc/cron.monthly',
  ],
  Boolean $manage = true,
  String $mode = '0750',
  Boolean $purge = true,
) {
  if $manage {
    file { $items:
      ensure  => directory,
      mode    => $mode,
      recurse => $purge,
      purge   => $purge,
    }

    # keep system default cron jobs
    if $purge {
      file {
        '/etc/cron.d/0hourly': ;
        '/etc/cron.hourly/0anacron': ;
        default:
          ensure => file,
          ;
      }
    }
  }
}
