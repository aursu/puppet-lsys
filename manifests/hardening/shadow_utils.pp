# @summary Configuration file for shadow-utils component
#
# Configuration file to control the behavior of the tools from the shadow-utils
# component
#
# @example
#   include lsys::hardening::shadow_utils
#
# @param pass_max_days
# @param pass_min_days
# @param pass_min_len
# @param pass_warn_age
# @param uid_min
# @param gid_min
# @param system_accounts
# @param enable_hardening
#
class lsys::hardening::shadow_utils (
  Integer $pass_max_days = 180,
  Integer $pass_min_days = 0,
  Integer $pass_min_len = 8,
  Integer $pass_warn_age = 14,
  String  $umask = '022',
  Integer $uid_min = $lsys::hardening::params::uid_min,
  Integer $gid_min = $lsys::hardening::params::gid_min,
  Boolean $system_accounts = $lsys::hardening::params::system_accounts,
  Boolean $enable_hardening = false,
  String $login_defs_template = $lsys::params::login_defs_template,
) inherits lsys::hardening::params {
  file { '/etc/login.defs':
    content => template($login_defs_template),
    group   => 'root',
    mode    => '0600',
    owner   => 'root',
  }

  if $enable_hardening {
    file {
      default:
        mode => 'o=';
      '/usr/bin/chage': ;
      '/usr/bin/gpasswd': ;
      '/usr/bin/lastlog': ;
      '/usr/bin/newgidmap': ;
      '/usr/bin/newgrp': ;
      '/usr/bin/newuidmap': ;
      '/usr/sbin/chgpasswd': ;
      '/usr/sbin/chpasswd': ;
      '/usr/sbin/groupadd': ;
      '/usr/sbin/groupdel': ;
      '/usr/sbin/groupmems': ;
      '/usr/sbin/groupmod': ;
      '/usr/sbin/grpck': ;
      '/usr/sbin/grpconv': ;
      '/usr/sbin/grpunconv': ;
      '/usr/sbin/newusers': ;
      '/usr/sbin/pwck': ;
      '/usr/sbin/pwconv': ;
      '/usr/sbin/pwunconv': ;
      '/usr/sbin/useradd': ;
      '/usr/sbin/userdel': ;
      '/usr/sbin/usermod': ;
      '/usr/sbin/vipw': ;
    }
  }
}
