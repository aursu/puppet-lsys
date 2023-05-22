# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @param config
#   Set of logrotate configuration for default log file (eg /var/log/messages on RedHat)
#
# @param syslog_config
#   Set of logrotate configuration for all other rsyslog log files
#
# @example
#   include lsys::logrotate::default
class lsys::logrotate::default (
  Lsys::Logrotate $config = $lsys::params::logrotate_default_config,
  Lsys::Logrotate $syslog_config = $lsys::params::logrotate_syslog_config,
) inherits lsys::params {
  include lsys::logrotate

  $syslog_default = $lsys::params::syslog_default
  $syslog_path    = $lsys::params::logrotate_syslog_path

  unless $syslog_default in $syslog_path {
    lsys::logrotate::rule { "${lsys::params::logrotate_syslog_name}-default":
      path   => $syslog_default,
      config => $config,
    }
  }

  lsys::logrotate::rule { $lsys::params::logrotate_syslog_name:
    path   => $syslog_path,
    config => $syslog_config,
  }
}
