# @summary Google Chrome installation
#
# Google Chrome installation
#
# @example
#   include lsys::tools::google_chrome
class lsys::tools::google_chrome (
  Enum['unstable', 'beta', 'stable']
          $release = 'stable',
  Lsys::PackageVersion
          $ensure  = true,
)
{
  include lsys::repo::google_chrome

  $package_name = "google-chrome-${release}"

  lsys::tools::package { 'google-chrome':
    ensure => $ensure,
    name   => $package_name,
  }

  Class['lsys::repo::google_chrome'] -> Lsys::Tools::Package['google-chrome']
}
