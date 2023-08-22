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

  $osfam  = $facts['os']['family']
  $osname = $facts['os']['name']
  $osmaj  = $facts['os']['release']['major']

  case $osname {
    'Ubuntu': {
      $oscode = $facts['os']['distro']['codename']

      $nginx_version = "1.23.1-1~${oscode}"

      $syslog_default = '/var/log/syslog'
      $logrotate_syslog_name = 'rsyslog'
      $logrotate_postrotate = '/usr/lib/rsyslog/rsyslog-rotate'
      $logrotate_default_config = {
        'rotate'        => 7,
        'daily'         => true,
        'missingok'     => true,
        'ifempty'       => false,
        'delaycompress' => true,
        'compress'      => true,
        'postrotate'    => $logrotate_postrotate,
      }

      $logrotate_syslog_path = [
        '/var/log/mail.info',
        '/var/log/mail.warn',
        '/var/log/mail.err',
        '/var/log/mail.log',
        '/var/log/daemon.log',
        '/var/log/kern.log',
        '/var/log/auth.log',
        '/var/log/user.log',
        '/var/log/lpr.log',
        '/var/log/cron.log',
        '/var/log/debug',
        '/var/log/messages',
      ]

      $logrotate_syslog_config = {
        'rotate'        => 7,
        'weekly'        => true,
        'missingok'     => true,
        'ifempty'       => false,
        'delaycompress' => true,
        'compress'      => true,
        'sharedscripts' => true,
        'postrotate'    => $logrotate_postrotate,
      }

      $logrotate_main_config = {
        create       => true,
        # keep 4 weeks worth of backlogs
        rotate       => 4,
        # rotate log files weekly
        rotate_every => 'week',
        su           => true,
        su_user      => 'root',
        su_group     => 'adm',
      }

      $postfix_uid = undef
      $postfix_gid = undef
      $postfix_shell = '/usr/sbin/nologin'
      $postdrop_gid = undef

      $cron_package_name = 'cron'
      $centos_stream = false

      $postgres_version = '15.3'
      $postgres_manage_repo = true

      $postfix_master_os_template = undef
    }
    'CentOS', 'Rocky': {
      $nginx_version = $osmaj ? {
        '6'     => '1.19.5-1.el6.ngx',
        default => "1.23.1-1.el${osmaj}.ngx",
      }

      $syslog_default = '/var/log/messages'
      $logrotate_syslog_name = 'syslog'
      $logrotate_postrotate = '/usr/bin/systemctl kill -s HUP rsyslog.service >/dev/null 2>&1 || true'
      $logrotate_default_config = {
        'missingok'     => true,
        'sharedscripts' => true,
        'postrotate'    => $logrotate_postrotate,
      }
      $logrotate_syslog_path = [
        '/var/log/cron',
        '/var/log/maillog',
        '/var/log/messages',
        '/var/log/secure',
        '/var/log/spooler',
      ]
      $logrotate_syslog_config = $logrotate_default_config
      $logrotate_main_config = {
        dateext      => true,
        compress     => true,
        create       => true,
        rotate       => 4,
        rotate_every => 'week',
      }

      $postfix_uid = 89
      $postfix_gid = 89
      $postfix_shell = '/sbin/nologin'
      $postdrop_gid = 90

      $cron_package_name = $osmaj ? {
        '5'     => 'vixie-cron',
        default => 'cronie',
      }

      if $osname == 'CentOS' {
        # Puppet > 6
        if 'distro' in $facts['os'] {
          # centos stream
          $centos_stream = $osmaj ? {
            '6' => false,
            '7' => false,
            '9' => true,
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
            '9'     => true,
            default => false,
          }
        }

        $repo_gpgkey = 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial'
        if $centos_stream {
          $repo_powertools_mirrorlist = 'http://mirrorlist.centos.org/?release=$stream&arch=$basearch&repo=PowerTools&infra=$infra'
          $repo_os_name = 'CentOS Stream'
        }
        else {
          $repo_powertools_mirrorlist = 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=PowerTools&infra=$infra'
          $repo_os_name = 'CentOS Linux'
        }
      }
      else {
        $centos_stream = false
        $repo_gpgkey = 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial'
        $repo_powertools_mirrorlist = 'https://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=PowerTools-$releasever'
        $repo_os_name = 'Rocky Linux'
      }

      if $osname == 'CentOS' and $osmaj == '8' and $centos_stream {
        $postgres_version = '15.0'
        $postgres_manage_repo = false
      }
      elsif $osname == 'Rocky' {
        $postgres_version = '15.2'
        $postgres_manage_repo = false
      }
      else {
        $postgres_version = '15.3'
        $postgres_manage_repo = true
      }

      if $osname == 'Rocky' and $osmaj == '8' {
        $postfix_master_os_template = 'lsys/postfix/master.cf.rocky-8.erb'
      }
      else {
        $postfix_master_os_template = undef
      }
    }
  }

  $nginx_conf_dir        = $nginx::params::conf_dir

  # directory to store configuration snippets to include into map directive
  $nginx_map_dir         = "${nginx_conf_dir}/conf.d/mapping"

  # monit
  $monit_version     = '5.33.0'
  $monit_binary_path = '/usr/local/bin/monit'
  $monit_config_dir  = '/etc/monit.d'
  $monit_config_file = '/etc/monitrc'
  $monit_logfile     = '/var/log/monit.log'
  $monit_pid_file    = '/var/run/monit.pid'
}
