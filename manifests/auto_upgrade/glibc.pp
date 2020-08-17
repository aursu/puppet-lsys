# @summary Auto-upgrade for glibc package
#
# Auto-upgrade for glibc package
#
# @example
#   include lsys::auto_upgrade::glibc
class lsys::auto_upgrade::glibc (
  String  $version = 'latest',
  Optional[String]
          $corporate_repo = undef,
)
{
  lsys::auto_upgrade::package { 'glibc':
    version        => $version,
    corporate_repo => $corporate_repo,
  }
}

