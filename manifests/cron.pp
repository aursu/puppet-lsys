# @summary Basic crond management (packages/services)
#
# Basic crond management (packages/services)
#
# @param manage_package
#   Whether to manage cron daemon package or not
#
# @param package_ensure
#   Ensure property to pass to resource Package for cron daemon
#
# @param package_name
#   Real cron daemon package name (either cronie or vixie-cron)
#
# @param cronjobs_directory_manage
#   Whether to mange cron jobs directories which are /etc/cron.d
#   /etc/cron.hourly, /etc/cron.daily, /etc/cron.weekly are
#   /etc/cron.monthly
#
# @param cronjobs_directory_mode
#   Directory mode for cron jobs directories
#
# @param cronjobs_directory_purge
#   Whether to purge all non-managed cron jobs
#
# @example
#   include lsys::cron
class lsys::cron (
  Boolean $manage_package            = true,
  String  $package_ensure            = 'installed',
  String  $package_name              = $lsys::params::cron_package_name,
  Boolean $cronjobs_directory_manage = true,
  String  $cronjobs_directory_mode   = '0750',
  Boolean $cronjobs_directory_purge  = true,
) inherits lsys::params
{
  class { 'cron':
    manage_service => true,
    manage_package => false,
  }

  if $manage_package {
    package { 'cron':
      ensure   => $package_ensure,
      name     => $package_name,
      # provider yum can remove package with all circular dependencies
      provider => 'yum',
    }
  }

  if $cronjobs_directory_manage {
    if $manage_package {
      $cronjobs_directory_require = [Package['cron']]
    }
    else {
      $cronjobs_directory_require = []
    }

    $cronjobs_directory = [
      '/etc/cron.d',
      '/etc/cron.hourly',
      '/etc/cron.daily',
      '/etc/cron.weekly',
      '/etc/cron.monthly',
    ]

    file { $cronjobs_directory:
      ensure  => directory,
      mode    => $cronjobs_directory_mode,
      recurse => $cronjobs_directory_purge,
      purge   => $cronjobs_directory_purge,
      require => $cronjobs_directory_require,
    }

    # keep system default cron jobs
    if $cronjobs_directory_purge {
      file {
        '/etc/cron.d/0hourly': ;
        '/etc/cron.hourly/0anacron': ;
        default:
          ensure => present,
        ;
      }
    }
  }
}
