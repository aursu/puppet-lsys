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
  $syslog_default = $lsys::params::syslog_default
  $syslog_path    = $lsys::params::logrotate_syslog_path

  unless $syslog_default in $syslog_path {
    if $config['hourly'] {
      $default_rotate_every = 'hour'
    }
    elsif $config['daily'] {
      $default_rotate_every = 'day'
    }
    elsif $config['weekly'] {
      $default_rotate_every = 'week'
    }
    elsif $config['monthly'] {
      $default_rotate_every = 'month'
    }
    elsif $config['yearly'] {
      $default_rotate_every = 'year'
    }
    else {
      $default_rotate_every = undef
    }

    logrotate::rule { "${lsys::params::logrotate_syslog_name}-default":
      *            => $config - ['hourly', 'daily', 'weekly', 'monthly', 'yearly'],
      path         => $syslog_default,
      rotate_every => $default_rotate_every,
    }
  }

  if $syslog_config['hourly'] {
    $rotate_every = 'hour'
  }
  elsif $syslog_config['daily'] {
    $rotate_every = 'day'
  }
  elsif $syslog_config['weekly'] {
    $rotate_every = 'week'
  }
  elsif $syslog_config['monthly'] {
    $rotate_every = 'month'
  }
  elsif $syslog_config['yearly'] {
    $rotate_every = 'year'
  }
  else {
    $rotate_every = undef
  }

  logrotate::rule { $lsys::params::logrotate_syslog_name:
    *            => $syslog_config - ['hourly', 'daily', 'weekly', 'monthly', 'yearly'],
    path         => $syslog_path,
    rotate_every => $rotate_every,
  }
}
