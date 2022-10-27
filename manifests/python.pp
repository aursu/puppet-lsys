# @summary Python installation
#
# Python installation
#
# @example
#   include lsys::python
class lsys::python (
  Boolean $python2_install = true,
  Boolean $python3_install = true,
) {
  case $facts['os']['family'] {
    'RedHat': {
      case $facts['os']['release']['major'] {
        '7': {
          if $python2_install { package { 'python': ensure => present } }
          if $python3_install { package { 'python3': ensure => present } }
        }
        default: {
          if $python2_install { package { 'python2': ensure => present } }
          if $python3_install {
            package { 'python3':
              ensure        => present,
              allow_virtual => true,
            }
          }
        }
      }
    }
    default: {
      if $python2_install { package { 'python2': ensure => present } }
      if $python3_install {
        package { 'python3':
          ensure        => present,
          allow_virtual => true,
        }
      }
    }
  }
}
