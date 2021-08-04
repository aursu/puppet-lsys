# @summary SELinux disable
#
# SELinux disable
#
# @example
#   include lsys::selinux::noop
class lsys::selinux::noop {
  if $facts['os']['selinux'] and $facts['os']['selinux']['enabled'] {
    class { 'selinux':
      mode => 'disabled',
    }
  }
}
