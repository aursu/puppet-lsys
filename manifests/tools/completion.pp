# @summary Install bash-completion package
#
# Install bash-completion package
#
# @example
#   include lsys::tools::completion
class lsys::tools::completion (
  Lsys::PackageVersion $package_ensure = true,
)
{
  lsys::tools::package { 'bash-completion': ensure => $package_ensure }
}
