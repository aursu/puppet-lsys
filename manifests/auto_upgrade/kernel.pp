# @summary Auto-upgrade for kernel package
#
# Auto-upgrade for kernel package
#
# @example
#   include lsys::auto_upgrade::kernel
class lsys::auto_upgrade::kernel (
  String  $version = 'latest',
  Optional[String]
          $corporate_repo = undef,
)
{
  lsys::auto_upgrade::package { 'kernel':
    version        => $version,
    corporate_repo => $corporate_repo,
  }
}
