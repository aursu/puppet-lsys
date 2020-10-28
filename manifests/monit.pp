# @summary Monit installation and setup
#
# Monit installation and setup
#
# @param prebuilt_binary
#   - whether to download Monit binary and install or use system package
#
# @param version
#   - system package version to install or 'present', 'absent'
#
# @param download_version
#   - Monit version to download from https://mmonit.com/monit/dist/binary/
#
# @param binary_path
#   - installation path to install Monit binary to
#
# @param logfile
#   - log file location to manage with logrotate script
#
# @param httpd
#   - whether to start Monit with HTTP support or not
#
# @example
#   include lsys::monit
class lsys::monit (
  Boolean $prebuilt_binary  = true,
  String  $version          = 'present',
  String  $download_version = $lsys::params::monit_version,
  Stdlib::Unixpath
          $binary_path      = $lsys::params::monit_binary_path,
  Stdlib::Unixpath
          $logfile          = $lsys::params::monit_logfile,
  Boolean $httpd            = true,
  Stdlib::IP::Address
          $httpd_address    = '127.0.0.1',
  Stdlib::IP::Address
          $httpd_allow      = '127.0.0.1',
  String  $httpd_user       = 'admin',
  Optional[String]
          $httpd_password   = undef,
) inherits lsys::params
{
  if $prebuilt_binary {
    $config_file    = $lsys::params::monit_config_file
    $package_ensure = 'absent'

    class { 'lsys::monit::prebuilt_binary':
      version     => $download_version,
      binary_path => $binary_path,
      before      => Class['monit'],
    }

    class { 'lsys::monit::service':
      binary_path => $binary_path,
      config_file => $config_file,
      logfile     => $logfile,
      before      => Class['monit'],
    }
  }
  else {
    $config_file    = undef
    $package_ensure = $version
  }

  class { 'monit':
    package_ensure   => $package_ensure,
    # configuration directory /etc/monit.d
    config_dir       => $lsys::params::monit_config_dir,
    config_dir_purge => true,

    # configuration file
    config_file      => $config_file,

    # configuration options
    logfile          => $logfile,

    # monit httpd service
    httpd            => $httpd,
    httpd_address    => $httpd_address,
    httpd_allow      => $httpd_allow,
    httpd_user       => $httpd_user,
    httpd_password   => $httpd_password,
  }
}
