# @summary Install package if ensure is set
#
# Install package if ensure is set
#
# @example
#   lsys::tools::package { 'sudo': }
define lsys::tools::package (
  Optional[Lsys::PackageVersion]
          $ensure = undef,
) {
  if $ensure {
    $package_ensure = $ensure ? {
      String  => $ensure,
      default => 'installed',
    }

    package { $name:
      ensure => $package_ensure,
    }
  }
}
