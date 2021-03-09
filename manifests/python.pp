# @summary Python installation
#
# Python installation
#
# @example
#   include lsys::python
class lsys::python (
  Boolean $python2_install = true,
  Boolean $python3_install = true,
)
{
  if $facts['os']['name'] in ['RedHat', 'CentOS'] {
    case $facts['os']['release']['major'] {
      '7': {
        if $python2_install {
          # 2.7.5
          package { 'python':
            ensure => present,
          }
        }
        if $python3_install {
          # 3.6.8
          package { 'python3':
            ensure => present,
          }
        }
      }
      default: {
        if $python2_install {
          # 2.7.17
          package { 'python2':
            ensure => present,
          }
        }
        if $python3_install {
          # 3.6.8
          package { 'python3':
            ensure => present,
          }
        }
      }
    }
  }
}
