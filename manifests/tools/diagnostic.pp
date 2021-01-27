# @summary System statistic/monitoring tools
#
# System statistic/monitoring tools
#
# @example
#   include lsys::tools::diagnostic
class lsys::tools::diagnostic (
  Lsys::PackageVersion
          $iotop_ensure  = false,
  Lsys::PackageVersion
          $lsof_ensure   = false,
  Lsys::PackageVersion
          $strace_ensure = false,
  Lsys::PackageVersion
          $perf_ensure   = false,
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
}
