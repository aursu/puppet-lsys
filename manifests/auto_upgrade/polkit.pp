# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include lsys::auto_upgrade::polkit
#
# @param version
# @param corporate_repo
# @param corporate_repo_only
#
class lsys::auto_upgrade::polkit (
  String $version = 'latest',
  Optional[
    Variant[
      String,
      Array[String]
    ]
  ] $corporate_repo = undef,
  Boolean $corporate_repo_only = false,
) {
  bsys::tools::package { 'polkit':
    ensure              => $version,
    corporate_repo      => $corporate_repo,
    corporate_repo_only => $corporate_repo_only,
  }
}
