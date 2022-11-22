# @summary Manage tools for remote access
#
# Manage tools for remote access
#
# @example
#   include lsys::tools::remote
class lsys::tools::remote (
  Lsys::PackageVersion $curl_ensure = true,
  Lsys::PackageVersion $rsync_ensure = false,
  Lsys::PackageVersion $wget_ensure = false,
  Lsys::PackageVersion $telnet_ensure = false,
) {
  if $curl_ensure {
    lsys::tools::package { 'curl': ensure => $curl_ensure }
  }
  if $rsync_ensure {
    lsys::tools::package { 'rsync': ensure => $rsync_ensure }
  }
  if $wget_ensure {
    lsys::tools::package { 'wget':  ensure => $wget_ensure }
  }
  # The client program for the Telnet remote login protocol
  if $telnet_ensure {
    lsys::tools::package { 'telnet': ensure => $telnet_ensure }
  }
}
