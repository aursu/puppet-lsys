# @summary Manage tools for remote access
#
# Manage tools for remote access
#
# @example
#   include lsys::tools::remote
class lsys::tools::remote (
  String  $curl_ensure  = present,
  Optional[String]
          $rsync_ensure = undef,
  Optional[String]
          $wget_ensure  = undef,
)
{
  package { 'curl':
    ensure => $curl_ensure,
  }

  if $rsync_ensure {
    package { 'rsync':
      ensure => $rsync_ensure,
    }
  }

  if $wget_ensure {
    package { 'wget':
      ensure => $wget_ensure,
    }
  }
}
