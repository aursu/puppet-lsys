# @summary Auto-upgrade for bash package
#
# Auto-upgrade for bash package
#
# @example
#   include lsys::auto_upgrade::bash
class lsys::auto_upgrade::bash (
  String  $version = 'latest',
  Optional[String]
          $corporate_repo = undef,
)
{
  lsys::auto_upgrade::package { 'bash':
    version        => $version,
    corporate_repo => $corporate_repo,
  }
}
