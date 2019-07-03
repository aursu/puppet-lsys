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
  String  $default_kickstart_template = 'lsys/pxe/default-ks.cfg.erb',
)
{
  include lsys::pxe::storage
  include lsys::pxe::params

  $storage_directory = $lsys::pxe::params::storage_directory
  $c7_current_version = $lsys::pxe::params::c7_current_version

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

  apache::custom_config { 'diskless':
    content => template('lsys/pxe/httpd.conf.diskless.erb'),
  }

  # Default asstes
  # Kickstart http://<install-server>/ks/default.cfg (CentOS 7 installation)
  $install_server = $server_name
  $centos_version = $c7_current_version
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

  file { '/root/bin/update-7-x86_64.sh':
    ensure  => file,
    content => file('lsys/pxe/scripts/update-7-x86_64.sh'),
    mode    => '0500',
  }

  unless $storage_directory == '/diskless' {
    file { '/diskless':
      ensure => link,
      target => $storage_directory,
    }
  }
}
