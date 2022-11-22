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
  Lsys::PackageVersion $bc_ensure  = false,
  Lsys::PackageVersion $gcc_ensure = false,
) {
  # GNU's bc (a numeric processing language) and dc (a calculator)
  lsys::tools::package { 'bc': ensure => $bc_ensure }

  # GCC/CPP/C++
  lsys::tools::package {
    default: ensure  => $gcc_ensure;
    'gcc':   require => Lsys::Tools::Package['gcc-c++'];
    'cpp':   require => Lsys::Tools::Package['gcc-c++'];
    'gcc-c++': ;
  }
}
