# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include lsys::pxe::ipxe
class lsys::pxe::ipxe
{
  include lsys::pxe::storage

  # iPXE is an open source network bootloader
  package { 'ipxe-bootimgs':
      ensure  => 'present'
  }

  $tftp_root = '/var/lib/tftpboot'
  $ipxe_root = "${tftp_root}/boot/ipxe"

  file { $ipxe_root:
    ensure => directory,
  }

  [ 'undionly.kpxe', 'ipxe.efi' ].each |$ipxe_file| {
    file { "${ipxe_root}/${ipxe_file}":
      ensure  => file,
      source  => "file:///usr/share/ipxe/${ipxe_file}",
      require => Package['ipxe-bootimgs'],
    }
  }

  file { "${tftp_root}/boot/install.ipxe":
    ensure  => file,
    content => file('lsys/pxe/install.ipxe'),
  }
}
