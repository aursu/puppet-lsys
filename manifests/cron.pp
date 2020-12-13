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
# @param enable_monit
#   Whether to monitor crond service with Monit or not
#
# @example
#   include lsys::cron
class lsys::cron (
  Boolean $manage_package = true,
  String  $package_ensure = 'installed',
  String  $package_name   = $lsys::params::cron_package_name,
  Boolean $enable_monit   = false,
) inherits lsys::params
{
  class { 'cron':
    manage_service => true,
    manage_package => false,
  }

  class { 'lsys::cron::cronjobs_directory': }
  class { 'lsys::cron::service':
    enable_monit => $enable_monit,
  }

  if $manage_package {
    package { 'cron':
      ensure   => $package_ensure,
      name     => $package_name,
      # provider yum can remove package with all circular dependencies
      provider => 'yum',
      before   => [
        Class['lsys::cron::cronjobs_directory'],
        Class['lsys::cron::service'],
      ],
    }
  }
}