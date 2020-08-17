# @summary Auto-upgrade for openssl package
#
# Auto-upgrade for openssl package
#
# @example
#   include lsys::auto_upgrade::openssl
class lsys::auto_upgrade::openssl (
  String  $version = 'latest',
  Optional[String]
          $corporate_repo = undef,
)
{
  lsys::auto_upgrade::package { 'openssl':
    version        => $version,
    corporate_repo => $corporate_repo,
  }
}
