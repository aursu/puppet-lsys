# @summary Monit service scripts
#
# Monit service scripts
#   - startup script
#   - logrotate script
#
# @param binary_path
#   - installation path to install Monit binary to
#
# @param config_file
#   - configuration file to use for installed Monit binary
#
# @param logfile
#   - log file location to manage with logrotate script
#
# @example
#   include lsys::monit::service
class lsys::monit::service (
  Stdlib::Unixpath
          $binary_path = $lsys::params::monit_binary_path,
  Stdlib::Unixpath
          $config_file = $lsys::params::monit_config_file,
  Stdlib::Unixpath
          $logfile     = $lsys::params::monit_logfile,
) inherits lsys::params
{
  if $facts['os']['name'] in ['RedHat', 'CentOS'] and $facts['os']['release']['major'] in ['5', '6'] {
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
  }

  file { 'monit_logrotate_script':
    ensure  => file,
    path    => '/etc/logrotate.d/monit',
    content => epp('lsys/monit/logrotate.epp'),
  }
}
