# @summary A basic NTP profile
#
# A basic NTP profile
#
# @example
#   include lsys::ntp
class lsys::ntp (
  Boolean $enable_hardening = false,
)
{
  if $facts['os']['name'] in ['RedHat', 'CentOS'] and $facts['os']['release']['major'] in ['8'] {
    class { 'chrony': }
  }
  else {
    class { 'ntp': }
  }

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
