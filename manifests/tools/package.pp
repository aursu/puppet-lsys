# @summary Install package if ensure is set
#
# Install package if ensure is set
#
# @example
#   lsys::tools::package { 'sudo': }
#
# @param package_name
# @param ensure
#
# @param corporate_repo
#   if specified - use only this repo for installation of the package
#
# @param corporate_repo_only
#
define lsys::tools::package (
  String $package_name = $name,
  Optional[Bsys::PackageVersion] $ensure = undef,
  Optional[
    Variant[
      String,
      Array[String]
    ]
  ] $corporate_repo = undef,
  Boolean $corporate_repo_only = true,
) {
  bsys::tools::package { $name:
    ensure              => $ensure,
    package_name        => $package_name,
    corporate_repo      => $corporate_repo,
    corporate_repo_only => $corporate_repo_only,
  }
}
