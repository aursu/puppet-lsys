# @summary Lockrun installation
#
# launch a program out with a lockout so that only one can run at a time. It's
# mainly intended for use out of cron so that our five-minute running jobs
# which run long don't get walked on.
#
# @param custom
#   if set to true then /usr/local/bin/lockrun will be installed
#
# @example
#   include lsys::tools::lockrun
class lsys::tools::lockrun (
  Boolean $custom = false,
) {
  $os_release_major = $facts['os']['release']['major']

  if $custom and $facts['os']['name'] in ['RedHat', 'CentOS'] and $os_release_major in ['6', '7', '8'] {
    file { '/usr/local/bin/lockrun':
      ensure => file,
      source => "puppet:///modules/lsys/lockrun/lockrun.el${os_release_major}",
      owner  => 'root',
      group  => 'root',
      mode   => '0750',
    }
  }

  # install also util-linux to provide flock
  include lsys::tools::system
}
