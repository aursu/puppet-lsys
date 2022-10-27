# @summary A basic NTP profile
#
# A basic NTP profile
#
# @example
#   include lsys::ntp
class lsys::ntp (
  Boolean $enable_hardening = false,
  Optional[Array[Stdlib::Host]] $servers = undef,
) {
  if $servers {
    $ntp_servers = $servers
  }
  elsif $facts['os']['family'] == 'RedHat' {
    $ntp_servers = [
      '0.centos.pool.ntp.org',
      '1.centos.pool.ntp.org',
      '2.centos.pool.ntp.org',
      '3.centos.pool.ntp.org',
    ]
  }
  else {
    $ntp_servers = [
      '0.pool.ntp.org',
      '1.pool.ntp.org',
      '2.pool.ntp.org',
      '3.pool.ntp.org',
    ]
  }

  if $facts['os']['name'] in ['RedHat', 'CentOS'] and $facts['os']['release']['major'] in ['8', '9'] {
    # https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_basic_system_settings/using-chrony-to-configure-ntp
    # https://access.redhat.com/solutions/1977523
    class { 'chrony':
      servers => $ntp_servers,
    }
    contain chrony

    if $enable_hardening {
      file {
        default: mode => 'o=';
        '/usr/bin/chronyc': ;
        '/usr/sbin/chronyd': ;
      }
    }
  }
  else {
    # https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_ntpd
    class { 'ntp':
      iburst_enable => true,
      servers       => $ntp_servers,
      restrict      => [
        'default nomodify notrap nopeer noquery',
        '-6 default nomodify notrap nopeer noquery',
        '127.0.0.1',
        '-6 ::1',
      ],
    }
    contain ntp

    if $enable_hardening {
      file {
        default: mode => 'o=';
        '/etc/ntp': ;
        '/usr/bin/ntpstat': ;
        '/usr/sbin/ntp-keygen': ;
        '/usr/sbin/ntpd': ;
        '/usr/sbin/ntpdc': ;
        '/usr/sbin/ntpq': ;
        '/usr/sbin/ntptime': ;
        '/usr/sbin/tickadj': ;
      }
    }
  }
}
