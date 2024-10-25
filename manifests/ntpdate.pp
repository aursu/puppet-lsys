# @summary ntpdate support
#
# ntpdate support
#
# @example
#   include lsys::ntpdate
class lsys::ntpdate (
  String  $package_ensure   = 'latest',
  Integer $retries          = 2,
  Boolean $sync_hwclock     = false,
  Boolean $enable_hardening = false,
) {
  # RedHat 8+
  # https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_the_chrony_suite#sect-Understanding_the_chrony_configuration_commands
  #
  $os_release_major = $facts['os']['release']['major']
  if ($facts['os']['family'] == 'RedHat' and $os_release_major == '7') {
    package { 'ntpdate':
      ensure => $package_ensure,
    }

    if $enable_hardening {
      file { '/usr/sbin/ntpdate': mode => 'o=' }
    }

    if $facts['os']['family'] == 'RedHat' {
      # -s   Divert logging output from the standard output (default) to the
      #      system syslog facility. This is designed primarily for convenience
      #      of cron scripts.
      # -b   Force the time to be stepped using the settimeofday() system call,
      #      rather than slewed (default) using the adjtime() system call. This
      #      option should be used when called from a  startup file at boot time.
      # -p samples
      #      Specify the number of samples to be acquired from each server as the
      #      integer samples, with values from 1 to 8 inclusive. The default is 4.
      $options = $os_release_major ? {
        '6' => '-U ntp -s -b',
        '7' => '-p 2',
      }

      file { '/etc/sysconfig/ntpdate':
        content => template('lsys/ntpdate/sysconfig.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['ntpdate'],
      }

      service { 'ntpdate':
        enable  => true,
        require => File['/etc/sysconfig/ntpdate'],
      }
    }
  }
}
