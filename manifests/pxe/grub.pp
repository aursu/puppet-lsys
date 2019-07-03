# Setup GRUB2 for booting over network
#
# @summary Setup GRUB2 for booting over network
#
# @example
#   include lsys::pxe::grub
class lsys::pxe::grub (
  Boolean $c6_download = true,
  Boolean $c7_download = true,
){

  include lsys::pxe::params
  $c6_current_version = $lsys::pxe::params::c6_current_version
  $c7_current_version = $lsys::pxe::params::c7_current_version

  if $c6_download {
    lsys::pxe::centos { $c6_current_version: }
  }

  if $c7_download {
    lsys::pxe::centos { $c7_current_version: }
  }

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
    before  => File['/var/lib/tftpboot/boot/grub/grub.cfg']
  }

  exec { 'grub2-mknetdir --net-directory=/var/lib/tftpboot --subdir=boot/grub -d /usr/lib/grub/i386-efi':
    path    => '/usr/bin:/bin',
    creates => '/var/lib/tftpboot/boot/grub/i386-efi/core.efi',
    require => Package['grub2-pc-modules'],
  }

  # GRUB configuration files
  # MAC: 00:50:56:8e:5b:30
  # IP: 10.55.156.40 (hex: 0A.37.9C.28)
  # /boot/grub/i386-pc/grub.cfg-01-00-50-56-8e-5b-30
  # /boot/grub/i386-pc/grub.cfg-01-00-50-56-8e-5b-30
  # /boot/grub/i386-pc/grub.cfg-0A379C28
  # /boot/grub/i386-pc/grub.cfg-0A379C28
  # /boot/grub/i386-pc/grub.cfg-0A379C2
  # /boot/grub/i386-pc/grub.cfg-0A379C2
  # /boot/grub/i386-pc/grub.cfg-0A379C
  # /boot/grub/i386-pc/grub.cfg-0A379C
  # /boot/grub/i386-pc/grub.cfg-0A379
  # /boot/grub/i386-pc/grub.cfg-0A379
  # /boot/grub/i386-pc/grub.cfg-0A37
  # /boot/grub/i386-pc/grub.cfg-0A37
  # /boot/grub/i386-pc/grub.cfg-0A3
  # /boot/grub/i386-pc/grub.cfg-0A3
  # /boot/grub/i386-pc/grub.cfg-0A
  # /boot/grub/i386-pc/grub.cfg-0A
  # /boot/grub/i386-pc/grub.cfg-0
  # /boot/grub/i386-pc/grub.cfg-0
  # /boot/grub/i386-pc/grub.cfg
  #
  # cat boot/grub/i386-pc/grub.cfg
  # source boot/grub/grub.cfg

  $default_kernel = "/boot/centos/${c7_current_version}/os/x86_64/images/pxeboot/vmlinuz"
  $default_initimg = "/boot/centos/${c7_current_version}/os/x86_64/images/pxeboot/initrd.img"

  file { '/var/lib/tftpboot/boot/grub/grub.cfg':
    ensure  => file,
    content => template('lsys/pxe/grub.cfg.erb'),
  }
}
