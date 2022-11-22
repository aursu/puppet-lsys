# @summary Install bash-completion package
#
# Install bash-completion package
#
# @example
#   include lsys::tools::completion
#
# @param package_ensure
#
class lsys::tools::completion (
  Lsys::PackageVersion $package_ensure = true,
) {
  lsys::tools::package { 'bash-completion': ensure => $package_ensure }
}
