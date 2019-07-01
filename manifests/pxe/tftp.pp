# Install and manage TFTP service for PXE environment
#
# @summary Install and manage TFTP service for PXE environment
#
# @example
#   include lsys::pxe::tftp
class lsys::pxe::tftp {

  # Install the xinetd service, that manages the tftpd service
  package { 'xinetd':
    ensure => present,
  }

  package { 'tftp-server':
    ensure => present,
  }

  file { '/var/lib/tftpboot':
    ensure  => directory,
    require => Package['tftp-server'],
  }
}
