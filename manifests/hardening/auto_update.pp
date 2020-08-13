# @summary Automatically update packages
#
# Check if packages specified are latest available version
#
# @example
#   include lsys::hardening::auto_update
#
# @param bash_version
#   Bash interpreter version
#
class lsys::hardening::auto_update (
  String $bash_version = 'latest',
  String $glibc_version = 'latest',
)
{
  package { 'bash':
    ensure => $bash_version,
  }

  package { 'glibc':
    ensure => $glibc_version,
  }
}
