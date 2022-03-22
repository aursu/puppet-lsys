# @summary Auto-upgrade for kernel package
#
# Auto-upgrade for kernel package
#
# @example
#   include lsys::auto_upgrade::kernel
class lsys::auto_upgrade::kernel (
  String  $version             = 'latest',
  Optional[
    Variant[
      String,
      Array[String]
    ]
  ]       $corporate_repo      = undef,
  Boolean $corporate_repo_only = false,
)
{
  lsys::tools::package { 'kernel':
    ensure              => $version,
    corporate_repo      => $corporate_repo,
    corporate_repo_only => $corporate_repo_only,
  }
}
