# Setup GRUB2 for booting over network
#
# @summary Setup GRUB2 for booting over network
#
# @example
#   include lsys::pxe::grub
class lsys::pxe::grub {

  # GRUB2 Modules installation
  package {
    default:
      ensure  => 'present',
    ;
    'grub2-tools-extra':
    ;
    [ 'grub2-efi-ia32-modules', 'grub2-pc-modules', 'grub2-efi-x64-modules' ]:
      require => Package['grub2-tools-extra'],
    ;
  }

  # GRUB2 TFTP data
  exec { 'grub2-mknetdir --net-directory=/var/lib/tftpboot --subdir=boot/grub -d /usr/lib/grub/x86_64-efi':
    path    => '/usr/bin:/bin',
    creates => '/var/lib/tftpboot/boot/grub/x86_64-efi/core.efi',
    require => Package['grub2-efi-x64-modules'],
  }

  exec { 'grub2-mknetdir --net-directory=/var/lib/tftpboot --subdir=boot/grub -d /usr/lib/grub/i386-pc':
    path    => '/usr/bin:/bin',
    creates => '/var/lib/tftpboot/boot/grub/i386-pc/core.0',
    require => Package['grub2-pc-modules'],
  }

  exec { 'grub2-mknetdir --net-directory=/var/lib/tftpboot --subdir=boot/grub -d /usr/lib/grub/i386-efi':
    path    => '/usr/bin:/bin',
    creates => '/var/lib/tftpboot/boot/grub/i386-efi/core.efi',
    require => Package['grub2-pc-modules'],
  }
}
