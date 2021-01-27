# @summary Manage network administration tools
#
# Manage network administration tools
#
# @example
#   include lsys::tools::network
class lsys::tools::network (
  Lsys::PackageVersion
          $bind_utils_ensure = false,
  Lsys::PackageVersion
          $whois_ensure      = false,
  Lsys::PackageVersion
          $net_tools_ensure  = false,
  Lsys::PackageVersion
          $tcpdump_ensure    = false,
  Lsys::PackageVersion
          $traceroute_ensure = false,
  Lsys::PackageVersion
          $nmap_ncat_ensure  = false,
)
{
  # Utilities for querying DNS name servers
  # dig, host, nslookup
  lsys::tools::package { 'bind-utils': ensure => $bind_utils_ensure }

  # Searches for an object in a RFC 3912 database.
  lsys::tools::package { 'whois': ensure => $whois_ensure }

  # Basic networking tools
  # arp, ifconfig, route
  lsys::tools::package { 'net-tools': ensure => $net_tools_ensure }

  # A network traffic monitoring tool
  lsys::tools::package { 'tcpdump': ensure => $tcpdump_ensure }

  # Traces the route taken by packets over an IPv4/IPv6 network
  lsys::tools::package { 'traceroute': ensure => $traceroute_ensure }

  # Nmap's Netcat replacement
  lsys::tools::package { 'nmap-ncat': ensure => $nmap_ncat_ensure }
}
