# @summary Parameters for shadow-utils tools
#
# Parameters to control the behavior of the tools from the shadow-utils
# component
#
# @example
#   include lsys::hardening::params
class lsys::hardening::params inherits lsys::params {
  include bsys::hardening::params

  case $facts['os']['release']['major'] {
    '6': {
      $uid_min = 500
      $gid_min = 500
      $system_accounts = false
    }
    default:  {
      $uid_min = $bsys::hardening::params::uid_min
      $gid_min = $bsys::hardening::params::uid_min
      $system_accounts = true
    }
  }

  $login_defs_template = $bsys::hardening::params::login_defs_template
}
