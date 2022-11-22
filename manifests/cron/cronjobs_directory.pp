# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @param manage
#   Whether to manage cron jobs directories or not
#
# @param items
#   Whether to mange cron jobs directories which are /etc/cron.d
#   /etc/cron.hourly, /etc/cron.daily, /etc/cron.weekly are
#   /etc/cron.monthly
#
# @param mode
#   Directory mode for cron jobs directories
#
# @param purge
#   Whether to purge all non-managed cron jobs
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
