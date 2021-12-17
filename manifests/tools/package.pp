# @summary Install package if ensure is set
#
# Install package if ensure is set
#
# @param corporate_repo
#   if specified - use only this repo for installation of the package
#
# @example
#   lsys::tools::package { 'sudo': }
define lsys::tools::package (
  String  $package_name   = $name,
  Optional[Lsys::PackageVersion]
          $ensure         = undef,
  Optional[String]
          $corporate_repo = undef,
) {
  if  $facts['os']['name'] in ['RedHat', 'CentOS'] and $corporate_repo {
    if $facts['os']['release']['major'] == '8' {
      $package_provider = 'dnf'
      $package_install_options  = ['--repo', $corporate_repo]
    }
    else {
      $package_provider = 'yum'
      $package_install_options  = ['--disablerepo', '*', '--enablerepo', $corporate_repo]
    }
  }
  else {
    $package_provider = undef
    $package_install_options = []
  }

  if $ensure {
    $package_ensure = $ensure ? {
      String  => $ensure,
      default => 'installed',
    }

    package { $package_name:
      ensure          => $package_ensure,
      provider        => $package_provider,
      install_options => $package_install_options,
    }
  }
}
