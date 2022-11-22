# @summary Manage system/administration tools
#
# Manage system/administration tools
#
# @example
#   include lsys::tools::system
class lsys::tools::system (
  Boolean $enable_hardening = false,
  Lsys::PackageVersion $sudo_ensure = false,
  Lsys::PackageVersion $file_ensure = false,
  Lsys::PackageVersion $which_ensure = false,
  Lsys::PackageVersion $quota_ensure = false,
  String $quota_owner = 'root',
  String $quota_group = 'root',
) {
  # Allows restricted root access for specified users
  lsys::tools::package { 'sudo': ensure => $sudo_ensure }

  # A utility for determining file types
  lsys::tools::package { 'file': ensure => $file_ensure }

  # The which command shows the full pathname of a specified program
  lsys::tools::package { 'which': ensure => $which_ensure }

  # System administration tools for monitoring users' disk usage
  lsys::tools::package { 'quota': ensure => $quota_ensure }

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
