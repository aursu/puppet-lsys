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

  # Rocky 10 runs logrotate from logrotate.timer, as EL9 does, but
  # voxpupuli/logrotate carries data for release 10 only from v9.0.0; the fleet
  # pins v7.1.0, so release 10 fell back to cron and ran logrotate twice. These
  # are upstream's own RedHat/10.yaml values. Drop them once the pin reaches v9.
  if $facts['os']['family'] == 'RedHat' and versioncmp($facts['os']['release']['major'], '10') >= 0 {
    $scheduler = {
      ensure_cron_daily    => 'absent',
      ensure_cron_hourly   => 'absent',
      manage_systemd_timer => true,
      ensure_systemd_timer => 'present',
    }
  }
  else {
    $scheduler = {}
  }

  class { 'logrotate':
    ensure             => 'latest',
    config             => $lsys::params::logrotate_main_config,
    manage_cron_hourly => $manage_cron_hourly,
    create_base_rules  => $create_base_rules,
    *                  => $scheduler,
  }

  # v5.0.0 does not contain logrotate::hourly
  include logrotate::hourly
}
