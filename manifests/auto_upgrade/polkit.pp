# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include lsys::auto_upgrade::polkit
class lsys::auto_upgrade::polkit (
  String  $version = 'latest',
  Optional[String]
          $corporate_repo = undef,
)
{
  lsys::auto_upgrade::package { 'polkit':
    version        => $version,
    corporate_repo => $corporate_repo,
  }
}
