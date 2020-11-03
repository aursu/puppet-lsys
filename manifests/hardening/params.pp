# @summary Parameters for shadow-utils tools
#
# Parameters to control the behavior of the tools from the shadow-utils
# component
#
# @example
#   include lsys::hardening::params
class lsys::hardening::params {
  case $facts['os']['release']['major'] {
    '6': {
      $uid_min = 500
      $gid_min = 500
      $system_accounts = false
    }
    default:  {
      $uid_min = 1000
      $gid_min = 1000
      $system_accounts = true
    }
  }
}
