# @summary
#   Manages the installation and upgrade of the glibc package.
#
# @description
#   This class ensures that the `glibc` package is installed and kept at the
#   specified version. It supports installation from a corporate repository if
#   required. The class is useful for enforcing a specific version of glibc or
#   ensuring it is always up to date as part of automated system maintenance.
#
# @example Install the latest version of glibc
#   include lsys::auto_upgrade::glibc
#
# @example Install a specific version of glibc from a corporate repository
#   class { 'lsys::auto_upgrade::glibc':
#     version        => '2.28-151',
#     corporate_repo => 'corp-repo',
#   }
#
# @param version
#   The version of the glibc package to ensure is installed. Defaults to 'latest'.
# @param corporate_repo
#   The name or list of names of corporate repositories to use for installation.
#   If not specified, the default system repositories are used.
# @param corporate_repo_only
#   If true, only the specified corporate repositories will be used for installation.
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
