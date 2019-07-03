# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   lsys::pxe::centos { 'namevar': }
define lsys::pxe::centos(
  Pattern[/^6|7|6\.([0-9]|10)|7\.[0-6]\.[0-9]{4}$/]
          $version  = $name,
  Enum['x86_64', 'i386']
          $arch     = 'x86_64',
)
{
  include lsys::pxe::storage

  include lsys::pxe::params
  $c6_current_version = $lsys::pxe::params::c6_current_version
  $c7_current_version = $lsys::pxe::params::c7_current_version

  $real_version = $version ? {
    '6'     => $c6_current_version,
    '7'     => $c7_current_version,
    default => $version
  }

  $base_directory    = "/var/lib/tftpboot/boot/centos/${real_version}"

  case $real_version {
    $c6_current_version, $c7_current_version: {
      $centos_url = "http://mirror.centos.org/centos/${real_version}/os/${arch}/images"
    }
    default: {
      file { $base_directory:
        ensure => directory,
      }
      $centos_url = "http://vault.centos.org/${version}/os/${arch}/images"
    }
  }

  $arch_directory    = "${base_directory}/os/${arch}"
  $images_directory  = "${arch_directory}/images"
  $pxeboot_directory = "${images_directory}/pxeboot"

  file { [
    "${base_directory}/os",
    $arch_directory,
    $images_directory,
    $pxeboot_directory ]:
    ensure => directory,
  }

  archive { "${pxeboot_directory}/vmlinuz":
    ensure => present,
    source => "${centos_url}/pxeboot/vmlinuz",
  }

  archive { "${pxeboot_directory}/initrd.img":
    ensure => present,
    source => "${centos_url}/pxeboot/initrd.img",
  }
}
