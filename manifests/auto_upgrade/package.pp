# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   lsys::auto_upgrade::package { 'namevar': }
define lsys::auto_upgrade::package (
  String  $package_name   = $name,
  String  $version        = 'latest',
  Optional[String]
          $corporate_repo = undef,
)
{
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

  package { $package_name:
    ensure          => $version,
    provider        => $package_provider,
    install_options => $package_install_options,
  }
}
