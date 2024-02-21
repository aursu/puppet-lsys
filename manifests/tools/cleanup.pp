# @summary Remove different packages
#
# Remove different packages
#
# @example
#   include lsys::tools::cleanup
#
# @param fprintd_ensure
# @param man_ensure
# @param man_pages_ensure
#
class lsys::tools::cleanup (
  Bsys::PackageVersion $fprintd_ensure = absent,
  Bsys::PackageVersion $man_ensure = absent,
  Bsys::PackageVersion $man_pages_ensure = absent,
) {
  #  D-Bus service for Fingerprint reader access
  bsys::tools::package {
    default:
      ensure => $fprintd_ensure;
    'fprintd': ;
    'fprintd-pam':
      before => Bsys::Tools::Package['fprintd'];
  }

  bsys::tools::package { 'man-db': ensure => $man_ensure }
  bsys::tools::package { 'man-pages': ensure => $man_pages_ensure }
}
