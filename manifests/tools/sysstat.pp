# @summary sysstat/sar installation and hardening
#
# sysstat/sar installation and hardening
#
# @example
#   include lsys::tools::sysstat
class lsys::tools::sysstat (
  Optional[Bsys::PackageVersion] $ensure = undef,
  Boolean $enable_hardening = false,
) {
  bsys::tools::package { 'sysstat': ensure => $ensure }

  if $enable_hardening {
    exec { 'chmod 0600 /var/log/sa/sa*':
      path   => '/usr/bin:/usr/sbin:/bin:/sbin',
      onlyif => 'find /var/log/sa -maxdepth 1 -type f -not -perm 0600 -exec false {} +',
    }
  }
}
