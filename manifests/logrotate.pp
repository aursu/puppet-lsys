# @summary Logrotate management
#
# Logrotate management
#
# @example
#   include lsys::logrotate
class lsys::logrotate (
  Boolean $manage_cron_hourly = true,
  Boolean $create_base_rules  = true,
) {
  include lsys::params

  class { 'logrotate':
    ensure             => 'latest',
    config             => $lsys::params::logrotate_main_config,
    manage_cron_hourly => $manage_cron_hourly,
    create_base_rules  => $create_base_rules,
  }

  # v5.0.0 does not contain logrotate::hourly
  include logrotate::hourly
}
