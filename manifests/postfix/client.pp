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
# @example
#   include lsys::postfix::client
class lsys::postfix::client (
  Optional[Variant[Stdlib::Fqdn, Stdlib::IP::Address]] $relayhost = undef,
  Boolean $postdrop_nosgid = false,
) {
  if $relayhost {
    $enable_mta = true
  }
  else {
    $enable_mta = false
  }

  class { 'postfix':
    manage_mailx   => false,
    manage_aliases => false,
    mta            => $enable_mta,
    relayhost      => $relayhost,
  }
  contain postfix

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
