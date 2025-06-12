# @summary Adds cron service always run control
#
# Adds cron service always run control
#
# @example
#   include lsys::cron::service
#
class lsys::cron::service {
  if  $facts['os']['family'] == 'RedHat'
  and versioncmp($facts['os']['release']['major'], '7') >= 0 {
    systemd::dropin_file { 'crond.service.d/override.conf':
      filename => 'override.conf',
      unit     => 'crond.service',
      content  => file('lsys/cron/systemd.conf'),
    }
  }
}
