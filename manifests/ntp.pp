# @summary A basic NTP profile
#
# A basic NTP profile
#
# @example
#   include lsys::ntp
class lsys::ntp {
  if $facts['os']['name'] in ['RedHat', 'CentOS'] and $facts['os']['release']['major'] in ['8'] {
    class { 'chrony': }
  }
  else {
    class { 'ntp': }
  }
}
