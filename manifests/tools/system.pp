# @summary Manage system/administration tools
#
# Manage system/administration tools
#
# @example
#   include lsys::tools::system
class lsys::tools::system (
  Boolean $enable_hardening = false,
  Bsys::PackageVersion $sudo_ensure = false,
  Bsys::PackageVersion $file_ensure = false,
  Bsys::PackageVersion $which_ensure = false,
  Bsys::PackageVersion $quota_ensure = false,
  Bsys::PackageVersion $util_linux_ensure = true,
  Bsys::PackageVersion $chkconfig_ensure = false,
  String $quota_owner = 'root',
  String $quota_group = 'root',
) {
  # Allows restricted root access for specified users
  bsys::tools::package { 'sudo': ensure => $sudo_ensure }

  # A utility for determining file types
  bsys::tools::package { 'file': ensure => $file_ensure }

  # The which command shows the full pathname of a specified program
  bsys::tools::package { 'which': ensure => $which_ensure }

  # System administration tools for monitoring users' disk usage
  bsys::tools::package { 'quota': ensure => $quota_ensure }

  # The util-linux package contains a large variety of low-level system utilities
  bsys::tools::package { 'util-linux': ensure => $util_linux_ensure }

  # Chkconfig is a basic system utility. It updates and queries runlevel information for system services
  bsys::tools::package { 'chkconfig': ensure => $chkconfig_ensure }

  if $enable_hardening {
    file {
      default: mode => 'o=';

      # which
      '/usr/bin/which': ;
    }

    file {
      default:
        mode  => 'o=',
        owner => $quota_owner,
        group => $quota_group,
        ;
      # quota
      '/usr/bin/quota': ;
      '/usr/bin/quotasync': ;
      '/usr/sbin/convertquota': ;
      '/usr/sbin/edquota': ;
      '/usr/sbin/quot': ;
      '/usr/sbin/quotacheck': ;
      '/usr/sbin/quotaoff': ;
      '/usr/sbin/quotaon': ;
      '/usr/sbin/quotastats': ;
      '/usr/sbin/repquota': ;
      '/usr/sbin/rpc.rquotad': ;
      '/usr/sbin/setquota': ;
      '/usr/sbin/xqmstats': ;

      # quota-warnquota
      '/usr/sbin/warnquota': ;
    }
  }
}
