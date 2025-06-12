# @summary Ability for /etc/profile hardening
#
# Ability for /etc/profile hardening
#
# @example
#   include lsys::hardening::bash_profile
#
# @param system_umask
#
class lsys::hardening::bash_profile (
  Pattern[/[0-7]{3}/] $system_umask = '077',
) {
  if $facts['os']['family'] == 'RedHat' {
    $osmajor = $facts['os']['release']['major']

    if $osmajor in ['6', '7', '8'] {
      file { '/etc/profile' :
        ensure  => file,
        content => template("lsys/hardening/profile.el${osmajor}.erb"),
      }
    }
  }
}
