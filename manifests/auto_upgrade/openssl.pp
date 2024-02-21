# @summary Auto-upgrade for openssl package
#
# Auto-upgrade for openssl package
#
# @example
#   include lsys::auto_upgrade::openssl
#
# @param version
# @param corporate_repo
# @param corporate_repo_only
#
class lsys::auto_upgrade::openssl (
  String  $version = 'latest',
  Optional[
    Variant[
      String,
      Array[String]
    ]
  ] $corporate_repo = undef,
  Boolean $corporate_repo_only = false,
) {
  bsys::tools::package { 'openssl':
    ensure              => $version,
    corporate_repo      => $corporate_repo,
    corporate_repo_only => $corporate_repo_only,
  }
}
