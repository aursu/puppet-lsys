# @summary Manage system/administration tools
#
# Manage system/administration tools
#
# @example
#   include lsys::tools::system
class lsys::tools::system (
  Lsys::PackageVersion
          $sudo_ensure = false,
  Lsys::PackageVersion
          $file_ensure = false,
)
{
  # Allows restricted root access for specified users
  lsys::tools::package { 'sudo': ensure => $sudo_ensure }

  # A utility for determining file types
  lsys::tools::package { 'file': ensure => $file_ensure }
}
