# @summary Scripting/programming interpreters/compilers
#
# Scripting/programming interpreters/compilers
#
# @example
#   include lsys::tools::lang
#
# @param bc_ensure
# @param gcc_ensure
#
class lsys::tools::lang (
  Bsys::PackageVersion $bc_ensure  = false,
  Bsys::PackageVersion $gcc_ensure = false,
) {
  # GNU's bc (a numeric processing language) and dc (a calculator)
  bsys::tools::package { 'bc': ensure => $bc_ensure }

  # GCC/CPP/C++
  bsys::tools::package {
    default: ensure => $gcc_ensure;
    'gcc':   require => Bsys::Tools::Package['gcc-c++'];
    'cpp':   require => Bsys::Tools::Package['gcc-c++'];
    'gcc-c++': ;
  }
}
