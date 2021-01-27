# @summary Manage system/administration tools
#
# Manage system/administration tools
#
# @example
#   include lsys::tools::system
class lsys::tools::system (
  Optional[String]
          $sudo_ensure = undef,
)
{
  if $sudo_ensure { package { 'sudo': ensure => $sudo_ensure } }
}
