# PXE server setup
#
# @summary PXE server setup
#
# @example
#   include lsys::pxe::server
class lsys::pxe::server (
  Stdlib::Fqdn
          $server_name,
  Stdlib::Port
          $web_port                   = 80,
  Boolean $manage_web_user            = true,
  Stdlib::Unixpath
          $storage_directory          = '/diskless',
  String  $default_kickstart_template = 'lsys/pxe/default-ks.cfg.erb',
)
{
  include apache::params
  $user = $apache::params::user

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

  # Web service
  class { 'lsys::httpd':
    listen_port  => $web_port,
    servername   => $server_name,
    manage_group => $manage_web_user,
    manage_user  => $manage_web_user,
  }

  class { 'apache::mod::cgi':
    notify => Class['Apache::Service'],
  }

  # GRUB configuration
  file {
    default:
      ensure => directory,
    ;
    '/var/lib/tftpboot/boot':
      mode => '0711',
    ;
    [ '/var/lib/tftpboot/boot/install', '/var/lib/pxe' ]:
      owner => $user,
      mode  => '0751',
  }

  apache::custom_config { 'diskless':
    content => template('lsys/pxe/httpd.conf.diskless.erb'),
  }

  # Default asstes
  # Kickstart http://<install-server>/ks/default.cfg (CentOS 7 installation)
  $install_server = $server_name
  file{ "${storage_directory}/configs/default.cfg":
    ensure  => file,
    content => template($default_kickstart_template),
  }

  # CGI trigger for host installation
  file { "${storage_directory}/exec/move.cgi":
    ensure  => file,
    content => file('lsys/pxe/scripts/copy.cgi'),
    mode    => '0755',
  }
}
