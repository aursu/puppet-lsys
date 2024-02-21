# @summary Manage storage tools
#
# Manage storage tools
#
# @example
#   include lsys::tools::storage
class lsys::tools::storage (
  Boolean $enable_hardening = false,
  Bsys::PackageVersion $lvm2_ensure = true,
) {
  # Logical volume management tools
  bsys::tools::package { 'lvm2': ensure => $lvm2_ensure }

  if $enable_hardening {
    file {
      default:
        mode  => 'o=',
        ;
      # lvm2
      '/usr/sbin/fsadm': ;
      '/usr/sbin/lvm': ;
      '/usr/sbin/lvmdump': ;
      '/usr/sbin/lvmpolld': ;
    }
  }
}
