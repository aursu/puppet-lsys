# @summary Man pages and documentation
#
# Man pages and documentation
#
# @example
#   include lsys::tools::docs
#
# @param man_ensure
#
class lsys::tools::docs (
  Lsys::PackageVersion $man_ensure = true,
) {
  # Tools for searching and reading man pages
  lsys::tools::package { 'man-db': ensure => $man_ensure }
}
