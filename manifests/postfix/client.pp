# @summary Postfix mail client installation
#
# Postfix mail client installation
#
# @param relayhost
#  The next-hop destination(s) for non-local mail; overrides non-local domains in recipient addresses
#  http://www.postfix.org/postconf.5.html#relayhost
#
# @param postdrop_nosgid
#   Whether to set ip proper permissions for Postfix runtime directories in
#   case if SGID removed from /usr/sbin/postdrop and /usr/sbin/postqueue
#   (e.g. in scope of security hardening)
#
# @param custom_master_config
#   Whether to use master.cf configuration templates defined in this module.
#   See templates/postfix folder and lsys::params::postfix_master_os_template
#
# @param master_os_template
#   Custom template for master.cf
#
# @param maillog_file
#   If defined full path to log file, then set it into main.cf as maillog_file parameter
#
# @example
#   include lsys::postfix::client
class lsys::postfix::client (
  Boolean $postdrop_nosgid = false,
  Boolean $custom_master_config = true,
  Optional[String] $master_os_template = $lsys::params::postfix_master_os_template,
  Optional[Variant[Stdlib::Fqdn, Stdlib::IP::Address]] $relayhost = undef,
  Optional[Stdlib::Unixpath] $maillog_file = undef,
) inherits lsys::params {
  if $relayhost {
    $enable_mta = true
  }
  else {
    $enable_mta = false
  }

  if $custom_master_config and $master_os_template {
    class { 'postfix::params':
      master_os_template => $master_os_template,
    }
  }

  class { 'postfix':
    manage_mailx   => false,
    manage_aliases => false,
    mta            => $enable_mta,
    relayhost      => $relayhost,
  }
  contain postfix

  if $maillog_file {
    postfix::config { 'maillog_file':
      ensure => 'present',
      value  => $maillog_file,
    }
  }

  case $facts['os']['family'] {
    'RedHat': {
      # postfix:x:89:
      group { 'postfix':
        ensure => present,
        gid    => 89,
      }
      # postfix:x:89:89::/var/spool/postfix:/sbin/nologin
      user { 'postfix':
        ensure     => present,
        uid        => 89,
        gid        => 'postfix',
        home       => '/var/spool/postfix',
        managehome => false,
        shell      => '/sbin/nologin',
      }
      # postdrop:x:90:
      group { 'postdrop':
        ensure => present,
        gid    => 90,
      }

      if $postdrop_nosgid {
        file { '/var/spool/postfix/maildrop':
          ensure  => directory,
          group   => 'postdrop',
          owner   => 'postfix',
          mode    => '1733',
          require => Class['postfix'],
        }
        file { '/var/spool/postfix/public':
          ensure  => directory,
          group   => 'postdrop',
          owner   => 'postfix',
          mode    => '0711',
          require => Class['postfix'],
        }
      }
    }
    default: {}
  }
}
