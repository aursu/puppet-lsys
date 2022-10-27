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
  Boolean $manage_package        = true,
  String  $package_ensure        = 'installed',
  String  $package_name          = $lsys::params::cron_package_name,
  Boolean $enable_monit          = false,
  Boolean $enable_hardening      = false,
  Boolean $file_system_hardening = true,
  Array[String]
          $users_allow           = ['root'],
) inherits lsys::params {
  if $enable_hardening {
    $manage_users_allow = true

    # Running cron jobs can be allowed or disallowed for different users. For
    # this purpose, use the cron.allow and cron.deny files. If the cron.allow
    # file exists, a user must be listed in it to be allowed to use cron. If
    # the cron.allow file does not exist but the cron.deny file does exist,
    # then a user must not be listed in the cron.deny file in order to use cron.
    # If neither of these files exists, only the super user is allowed to use
    # cron.
    file { '/etc/cron.deny':
      ensure => absent,
    }

    # FS hardening
    if $file_system_hardening {
      file {
        '/etc/anacrontab':      mode => '0600';
        '/etc/crontab':         mode => '0600';
        '/var/spool/anacron':   mode => '0750';
        '/var/spool/cron':      mode => '0700';
        '/var/spool/cron/root': mode => '0600';
        '/usr/sbin/crond':      mode => '0750';
      }
    }
  }
  else {
    $manage_users_allow = false
  }

  #  forge.puppet.com/puppet/cron
  class { 'cron':
    manage_service     => true,
    manage_package     => false,
    manage_users_allow => $manage_users_allow,
    users_allow        => $users_allow,
    manage_users_deny  => false,
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
