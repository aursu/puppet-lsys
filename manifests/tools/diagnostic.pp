# @summary System statistic/monitoring tools
#
# System statistic/monitoring tools
#
# @example
#   include lsys::tools::
#
# @param enable_hardening
# @param iotop_ensure
# @param lsof_ensure
# @param strace_ensure
# @param perf_ensure
# @param procps_ensure
# @param htop_ensure
#
class lsys::tools::diagnostic (
  Boolean $enable_hardening = false,
  Bsys::PackageVersion $iotop_ensure = false,
  Bsys::PackageVersion $lsof_ensure = false,
  Bsys::PackageVersion $strace_ensure = false,
  Bsys::PackageVersion $perf_ensure = false,
  Bsys::PackageVersion $procps_ensure = false,
  Bsys::PackageVersion $htop_ensure = false,
) {
  # Top like utility for I/O
  bsys::tools::package { 'iotop': ensure => $iotop_ensure }

  # A utility which lists open files on a Linux/UNIX system
  bsys::tools::package { 'lsof': ensure => $lsof_ensure }

  # Tracks and displays system calls associated with a running process
  bsys::tools::package { 'strace': ensure => $strace_ensure }

  # Performance monitoring for the Linux kernel
  bsys::tools::package { 'perf': ensure => $perf_ensure }

  # System and process monitoring utilities
  bsys::tools::package { 'procps-ng': ensure => $procps_ensure }

  # Interactive process viewer
  bsys::tools::package { 'htop': ensure => $htop_ensure }

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

      # htop
      '/usr/bin/htop': ;
    }
  }
}
