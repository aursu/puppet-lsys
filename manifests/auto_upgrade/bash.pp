# @summary Auto-upgrade for bash package
#
# Auto-upgrade for bash package
#
# @example
#   include lsys::auto_upgrade::bash
#
# @param corporate_repo
# @param corporate_repo_only
#
class lsys::auto_upgrade::bash (
  String $version = 'latest',
  Optional[
    Variant[
      String,
      Array[String]
    ]
  ] $corporate_repo = undef,
  Boolean $corporate_repo_only = false,
) {
  bsys::tools::package { 'bash':
    ensure              => $version,
    corporate_repo      => $corporate_repo,
    corporate_repo_only => $corporate_repo_only,
  }
}
