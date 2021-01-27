# @summary Scripting/programming interpreters/compilers
#
# Scripting/programming interpreters/compilers
#
# @example
#   include lsys::tools::lang
class lsys::tools::lang (
  Lsys::PackageVersion
          $bc_ensure = false,
)
{
  # GNU's bc (a numeric processing language) and dc (a calculator)
  lsys::tools::package { 'bc': ensure => $bc_ensure }
}
