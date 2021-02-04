# @summary System statistic/monitoring tools
#
# System statistic/monitoring tools
#
# @example
#   include lsys::tools::diagnostic
class lsys::tools::diagnostic (
  Boolean $enable_hardening = false,
  Lsys::PackageVersion
          $iotop_ensure     = false,
  Lsys::PackageVersion
          $lsof_ensure      = false,
  Lsys::PackageVersion
          $strace_ensure    = false,
  Lsys::PackageVersion
          $perf_ensure      = false,
  Lsys::PackageVersion
          $procps_ensure    = false,
)
{
  # Top like utility for I/O
  lsys::tools::package { 'iotop': ensure => $iotop_ensure }

  # A utility which lists open files on a Linux/UNIX system
  lsys::tools::package { 'lsof': ensure => $lsof_ensure }

  # Tracks and displays system calls associated with a running process
  lsys::tools::package { 'strace': ensure => $strace_ensure }

  # Performance monitoring for the Linux kernel
  lsys::tools::package { 'perf': ensure => $perf_ensure }

  # System and process monitoring utilities
  lsys::tools::package { 'procps-ng': ensure => $procps_ensure }

  if $enable_hardening {
    file {
      default: mode => 'o=';

      # procps-ng
      '/usr/bin/free': ;
      '/usr/bin/pgrep': ;
      '/usr/bin/pkill': ;
      '/usr/bin/pmap': ;
      '/usr/bin/ps': ;
      '/usr/bin/pwdx': ;
      '/usr/bin/skill': ;
      '/usr/bin/slabtop': ;
      '/usr/bin/snice': ;
      '/usr/bin/tload': ;
      '/usr/bin/top': ;
      '/usr/bin/uptime': ;
      '/usr/bin/vmstat': ;
      '/usr/bin/w': ;
      '/usr/bin/watch': ;
      '/usr/sbin/sysctl': ;

      # strace
      '/usr/bin/strace': ;
      '/usr/bin/strace-log-merge': ;

      # lsof
      '/usr/sbin/lsof': ;
    }
  }
}
