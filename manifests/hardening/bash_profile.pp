# @summary Ability for /etc/profile hardening
#
# Ability for /etc/profile hardening
#
# @example
#   include lsys::hardening::bash_profile
class lsys::hardening::bash_profile (
  Pattern[/[0-7]{3}/]
          $system_umask = '077',
)
{
  if  $facts['os']['name'] in ['RedHat', 'CentOS'] {
    $osmajor = $facts['os']['release']['major']

    file { '/etc/profile' :
      ensure  => present,
      content => file("hardening/profile.el${osmajor}"),
    }
  }
}
