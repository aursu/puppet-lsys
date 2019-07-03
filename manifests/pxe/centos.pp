# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   lsys::pxe::centos { 'namevar': }
define lsys::pxe::centos(
  Pattern[/^6|7|8|6\.([0-9]|10)|7\.[0-6]\.[0-9]{4}$/]
          $version  = $name,
  Enum['x86_64', 'i386']
          $arch     = 'x86_64',
)
{
  include lsys::pxe::storage

  include lsys::pxe::params
  $c6_current_version = $lsys::pxe::params::c6_current_version
  $c7_current_version = $lsys::pxe::params::c7_current_version
  $storage_directory  = $lsys::pxe::params::storage_directory

  $real_version = $version ? {
    '6'     => $c6_current_version,
    '7'     => $c7_current_version,
    # Jul 3, 2019 - CentOS 8 is on Build Loop 1 (use CentOS 7 instead)
    '8'     => $c7_current_version,
    default => $version
  }

  $major_version = $real_version ? {
    /^6/ => 6,
    /^7/ => 7,
    /^8/ => 8,
  }

  $base_directory    = "/var/lib/tftpboot/boot/centos/${real_version}"
  $distro_base_directory = "${storage_directory}/centos/${real_version}"

  case $real_version {
    $c6_current_version, $c7_current_version: {
      $centos_url = "http://mirror.centos.org/centos/${real_version}/os/${arch}"
    }
    default: {
      file { [ $base_directory, $distro_base_directory ]:
        ensure => directory,
      }
      $centos_url = "http://vault.centos.org/${version}/os/${arch}"
    }
  }

  $arch_directory        = "${base_directory}/os/${arch}"
  $images_directory      = "${arch_directory}/images"
  $pxeboot_directory     = "${images_directory}/pxeboot"
  $distro_arch_directory = "${distro_base_directory}/os/${arch}"

  file { [
    "${base_directory}/os",
    $arch_directory,
    $images_directory,
    $pxeboot_directory,
    "${distro_base_directory}/os",
    $distro_arch_directory ]:
    ensure => directory,
  }

  archive { "${pxeboot_directory}/vmlinuz":
    ensure => present,
    source => "${centos_url}/images/pxeboot/vmlinuz",
  }

  archive { "${pxeboot_directory}/initrd.img":
    ensure => present,
    source => "${centos_url}/images/pxeboot/initrd.img",
  }

  # /diskless/centos/7/os/x86_64/LiveOS/squashfs.img
  if $major_version in [ 7, 8 ] {
    file { "${distro_arch_directory}/LiveOS":
      ensure => directory,
    }

    archive { "${distro_arch_directory}/LiveOS/squashfs.img":
      ensure => present,
      source => "${centos_url}/LiveOS/squashfs.img",
    }
  }
}
