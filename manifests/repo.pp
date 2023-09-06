# Yum cache cleanup
#
# @summary Resources for Yum cache cleanup
#
# @example
#   include lsys::repo
class lsys::repo {
  case $facts['os']['family'] {
    'Debian': {
      exec { 'apt-update-e0c99ff':
        command     => 'apt update',
        path        => '/bin:/usr/bin',
        refreshonly => true,
      }
    }
    # default is RedHat based systems (CentOS/Rocky)
    default: {
      $reload_command = $facts['os']['release']['major'] ? {
        '7'     => 'yum clean all',
        default => 'dnf clean all',
      }

      exec { 'yum-reload-e0c99ff':
        command     => $reload_command,
        path        => '/bin:/usr/bin',
        refreshonly => true,
      }
    }
  }
}
