# @summary Remove different packages
#
# Remove different packages
#
# @example
#   include lsys::tools::cleanup
class lsys::tools::cleanup (
  Lsys::PackageVersion
          $fprintd_ensure   = absent,
  Lsys::PackageVersion
          $man_ensure       = absent,
  Lsys::PackageVersion
          $man_pages_ensure = absent,
)
{
  #  D-Bus service for Fingerprint reader access
  lsys::tools::package {
    default:
      nsure => $fprintd_ensure;
    'fprintd': ;
    'fprintd-pam': ;
      before => Lsys::Tools::Package['fprintd']
  }

  lsys::tools::package { 'man-db': ensure => $man_ensure }
  lsys::tools::package { 'man-pages': ensure => $man_pages_ensure }
}
