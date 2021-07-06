# @summary Local system parameters
#
# Local system parameters
#
# @example
#   include lsys::params
class lsys::params {
  include nginx::params
  include lsys::webserver::params

  # nginx
  $nginx_libdir          = '/var/lib/nginx'
  $nginx_cachedir        = '/var/cache/nginx'
  $nginx_proxy_temp_path = "${nginx_cachedir}/proxy_temp"
  $nginx_user_home       = '/var/lib/nginx'

  $nginx_version = $facts['os']['release']['major'] ? {
    '6'     => '1.19.5-1.el6.ngx',
    '8'     => '1.21.1-1.el8.ngx',
    default => '1.21.1-1.el7.ngx',
  }

  $nginx_conf_dir        = $nginx::params::conf_dir

  # directory to store configuration snippets to include into map directive
  $nginx_map_dir         = "${nginx_conf_dir}/conf.d/mapping"

  # cron
  $cron_package_name = $facts['os']['release']['major'] ? {
    '5'     => 'vixie-cron',
    default => 'cronie',
  }

  # monit
  $monit_version     = '5.27.1'
  $monit_binary_path = '/usr/local/bin/monit'
  $monit_config_dir  = '/etc/monit.d'
  $monit_config_file = '/etc/monitrc'
  $monit_logfile     = '/var/log/monit.log'
  $monit_pid_file    = '/var/run/monit.pid'

  # Puppet > 6
  if 'distro' in $facts['os'] {
    # centos stream
    $centos_stream = $facts['os']['release']['major'] ? {
      '6' => false,
      '7' => false,
      default => $facts['os']['distro']['id'] ? {
        'CentOSStream' => true,
        default        => false,
      },
    }
  }
  else {
    $centos_stream = $facts['os']['release']['full'] ? {
      # for CentOS Stream 8 it is just '8' but for CentOS Linux 8 it is 8.x.x
      '8'     => true,
      default => false,
    }
  }

  if $centos_stream {
    $repo_powertools_mirrorlist = 'http://mirrorlist.centos.org/?release=$stream&arch=$basearch&repo=PowerTools&infra=$infra'
    $repo_os_name = 'CentOS Stream'
  }
  else {
    $repo_powertools_mirrorlist = 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=PowerTools&infra=$infra'
    $repo_os_name = 'CentOS Linux'
  }
}
