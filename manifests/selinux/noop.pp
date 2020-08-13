# @summary SELinux disable
#
# SELinux disable
#
# @example
#   include lsys::selinux::noop
class lsys::selinux::noop {
  if $facts['selinux'] {
    class {'selinux':
      mode => 'disabled',
    }
  }
}
