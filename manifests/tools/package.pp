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
  Optional[Lsys::PackageVersion] $ensure = undef,
  Optional[
    Variant[
      String,
      Array[String]
    ]
  ] $corporate_repo = undef,
  Boolean $corporate_repo_only = true,
) {
  if  $facts['os']['family'] == 'RedHat' and $corporate_repo {
    $corporate_repo_list = $corporate_repo ? {
      String  => [$corporate_repo],
      default => $corporate_repo,
    }

    if $facts['os']['release']['major'] in ['8', '9'] {
      $package_provider = 'dnf'
      if $corporate_repo_only {
        $package_install_options = $corporate_repo_list.reduce([]) |$memo, $repo| { $memo + ['--repo', $repo] }
      }
      else {
        $package_install_options = $corporate_repo_list.reduce([]) |$memo, $repo| { $memo + ['--enablerepo', $repo] }
      }
    }
    else {
      $package_provider = 'yum'
      $enabled_repos = $corporate_repo_list.reduce([]) |$memo, $repo| { $memo + ['--enablerepo', $repo] }
      if $corporate_repo_only {
        $package_install_options = ['--disablerepo', '*'] + $enabled_repos
      }
      else {
        $package_install_options = $enabled_repos
      }
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
