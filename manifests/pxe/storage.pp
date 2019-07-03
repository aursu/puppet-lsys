# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include lsys::pxe::storage
class lsys::pxe::storage
{
  include apache::params
  $user = $apache::params::user

  include lsys::pxe::params
  $storage_directory  = $lsys::pxe::params::storage_directory
  $c6_current_version = $lsys::pxe::params::c6_current_version
  $c7_current_version = $lsys::pxe::params::c7_current_version

  # Storage
  file { [
    $storage_directory,
    "${storage_directory}/centos",
    "${storage_directory}/configs",
    "${storage_directory}/configs/assets",
    "${storage_directory}/exec" ]:
    ensure => directory,
    owner  => $user,
    mode   => '0511',
  }

  # GRUB configuration
  file {
    default:
      ensure => directory,
    ;
    [ '/var/lib/tftpboot/boot',
      '/var/lib/tftpboot/boot/centos',
      "/var/lib/tftpboot/boot/centos/${c6_current_version}",
      "/var/lib/tftpboot/boot/centos/${c7_current_version}" ]:
      mode => '0711',
    ;
    [ '/var/lib/tftpboot/boot/install', '/var/lib/pxe' ]:
      owner => $user,
      mode  => '0751',
    ;
  }

  # General URL
  file { '/var/lib/tftpboot/boot/centos/6':
      ensure => link,
      target => $c6_current_version,
  }

  file { '/var/lib/tftpboot/boot/centos/7':
      ensure => link,
      target => $c7_current_version,
  }
}
