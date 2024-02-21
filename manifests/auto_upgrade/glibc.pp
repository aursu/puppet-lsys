# @summary Auto-upgrade for glibc package
#
# Auto-upgrade for glibc package
#
# @example
#   include lsys::auto_upgrade::glibc
#
# @param version
# @param corporate_repo
# @param corporate_repo_only
#
class lsys::auto_upgrade::glibc (
  String $version = 'latest',
  Optional[
    Variant[
      String,
      Array[String]
    ]
  ] $corporate_repo = undef,
  Boolean $corporate_repo_only = false,
) {
  bsys::tools::package { 'glibc':
    ensure              => $version,
    corporate_repo      => $corporate_repo,
    corporate_repo_only => $corporate_repo_only,
  }
}
