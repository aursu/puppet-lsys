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
  Optional[String]
          $root_authorized_keys       = undef,
  Optional[String]
          $puppet_local_config        = undef,
)
{
  include lsys::pxe::storage
  include lsys::pxe::params

  $storage_directory = $lsys::pxe::params::storage_directory
  $centos_version    = $lsys::pxe::params::c7_current_version
  $install_server    = $server_name

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
  # Default kickstart http://<install-server>/ks/default.cfg (CentOS 7 installation)
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

  # /usr/bin/nmap required for repository installation and update scripts
  package { 'nmap':
    ensure => present,
  }

  # create /root/bin directory if not existing
  exec { 'mkdir -p /root/bin':
    path    => '/usr/bin:/bin',
    creates => '/root/bin',
  }

  # repository installation script
  file { '/root/bin/install-7-x86_64.sh':
    ensure  => file,
    content => file('lsys/pxe/scripts/install.sh'),
    mode    => '0500',
  }

  # repository update script (including EPEL and rpmforge)
  file { '/root/bin/update-7-x86_64.sh':
    ensure  => file,
    content => file('lsys/pxe/scripts/update.sh'),
    mode    => '0500',
  }

  # install Puppet repository
  file { "${storage_directory}/configs/assets/puppet5.repo":
    ensure  => file,
    content => file('lsys/pxe/assets/puppet5.repo'),
    mode    => '0644',
  }

  # install Puppet repository GPG key
  # https://puppet.com/docs/puppet/5.5/puppet_platform.html
  # https://yum.puppetlabs.com/RPM-GPG-KEY-puppet
  file { "${storage_directory}/configs/assets/RPM-GPG-KEY-puppet5-release":
    ensure  => file,
    content => file('lsys/pxe/assets/RPM-GPG-KEY-puppet5-release'),
    mode    => '0644',
  }

  if $root_authorized_keys {
    file { "${storage_directory}/configs/assets/root.authorized_keys":
      ensure  => file,
      content => file($root_authorized_keys),
      mode    => '0644',
    }
  }

  if $puppet_local_config {
    file { "${storage_directory}/configs/assets/puppet.conf":
      ensure  => file,
      content => file($puppet_local_config),
      mode    => '0644',
    }
  }
}
