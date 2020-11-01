# @summary Logrotate management
#
# Logrotate management
#
# @example
#   include lsys::logrotate
class lsys::logrotate (
  Boolean $manage_cron_hourly = true,
  Boolean $create_base_rules  = true,
)
{
  class { 'logrotate':
    ensure             => 'latest',
    config             => {
                            dateext      => true,
                            compress     => true,
                            create       => true,
                            rotate       => 4,
                            rotate_every => 'week',
                          },
    manage_cron_hourly => $manage_cron_hourly,
    create_base_rules  => $create_base_rules,
  }

  # v5.0.0 does not contain logrotate::hourly
  include logrotate::hourly
}
