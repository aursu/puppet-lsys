# @summary Monit installation and setup
#
# Monit installation and setup
#
# @example
#   include lsys::monit
class lsys::monit (
  String  $download_version = $lsys::params::monit_version,
  Stdlib::Unixpath
          $binary_path      = $lsys::params::monit_binary_path,
  Stdlib::Unixpath
          $config_file      = $lsys::params::monit_config_file,
  Stdlib::Unixpath
          $logfile          = $lsys::params::monit_logfile,
  Boolean $httpd            = false,
) inherits lsys::params
{
  # e.g. https://mmonit.com/monit/dist/binary/5.27.1/monit-5.27.1-linux-x64.tar.gz
  $download_name    = "monit-${download_version}-linux-x64.tar.gz"
  $download_url     = "https://mmonit.com/monit/dist/binary/${download_version}/${download_name}"
  $checksum_url     = "${download_url}.sha256"
  $extracted_binary = "/usr/local/monit-${download_version}/bin/monit"

  if $facts['os']['name'] in ['RedHat', 'CentOS']
  and $facts['os']['release']['major'] in ['5', '6'] {
    $init_path     = '/etc/rc.d/init.d/monit'
    $init_template = 'lsys/monit/init.epp'
  }
  else {
    $init_path     = '/etc/systemd/system/monit.service'
    $init_template = 'lsys/monit/systemd.epp'
  }

  file { 'monit_startup_script':
    ensure  => file,
    path    => $init_path,
    content => epp($init_template),
    before  => Service['monit'],
  }

  file { 'monit_logrotate':
    ensure  => file,
    path    => '/etc/logrotate.d/monit',
    content => epp('lsys/monit/logrotate.epp'),
  }

  archive { 'monit':
    ensure        => present,
    path          => "/usr/local/${download_name}",
    extract       => true,
    extract_path  => '/usr/local',
    source        => $download_url,
    checksum_url  => $checksum_url,
    checksum_type => 'sha256',
    creates       => $extracted_binary,
    cleanup       => true,
  }

  file { 'monit_binary':
    ensure    => file,
    path      => $binary_path,
    source    => "file://${extracted_binary}",
    mode      => '0755',
    owner     => 'root',
    group     => 'root',
    subscribe => Archive['monit'],
    before    => Service['monit'],
  }

  class { 'monit':
    package_ensure   => absent,
    # configuration directory /etc/monit.d
    config_dir       => $lsys::params::monit_config_dir,
    config_dir_purge => true,

    # configuration file
    config_file      => $config_file,

    # configuration options
    httpd            => $httpd,
    logfile          => $logfile,
  }
}
