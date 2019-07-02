# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include lsys::pxe::server
class lsys::pxe::server (
  Stdlib::Fqdn
          $server_name,
  Stdlib::Port
          $web_port        = 80,
  Boolean $manage_web_user = true,
  Stdlib::Unixpath
          $storage_directory = '/diskless',
)
{
  file { [
    $storage_directory,
    "${storage_directory}/centos",
    "${storage_directory}/configs",
    "${storage_directory}/exec" ]:
    ensure => directory,
  }

  class { 'lsys::httpd':
    listen_port  => $web_port,
    servername   => $server_name,
    manage_group => $manage_web_user,
    manage_user  => $manage_web_user,
  }

  include apache::mod::cgi

  apache::custom_config { 'diskless':
    content => template('lsys/pxe/httpd.conf.diskless.erb'),
  }
}
