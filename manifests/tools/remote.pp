# @summary Manage tools for remote access
#
# Manage tools for remote access
#
# @example
#   include lsys::tools::remote
class lsys::tools::remote (
  Bsys::PackageVersion $curl_ensure = true,
  Bsys::PackageVersion $rsync_ensure = false,
  Bsys::PackageVersion $wget_ensure = false,
  Bsys::PackageVersion $telnet_ensure = false,
) {
  if $curl_ensure {
    bsys::tools::package { 'curl': ensure => $curl_ensure }
  }
  if $rsync_ensure {
    bsys::tools::package { 'rsync': ensure => $rsync_ensure }
  }
  if $wget_ensure {
    bsys::tools::package { 'wget':  ensure => $wget_ensure }
  }
  # The client program for the Telnet remote login protocol
  if $telnet_ensure {
    bsys::tools::package { 'telnet': ensure => $telnet_ensure }
  }
}
