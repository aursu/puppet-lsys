# @summary C/C++ configuration file library
#
# Libconfig is a simple library for manipulating structured configuration
# files. This file format is more compact and more readable than XML. And
# unlike XML, it is type-aware, so it is not necessary to do string parsing
# in application code.
#
# @example
#   include lsys::tools::libconfig
#
# @param package_ensure
#
class lsys::tools::libconfig (
  Lsys::PackageVersion $package_ensure = true,
) {
  lsys::tools::package { 'libconfig': ensure => $package_ensure }
}
