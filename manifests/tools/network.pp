# @summary Manage network administration tools
#
# Manage network administration tools
#
# @example
#   include lsys::tools::network
class lsys::tools::network (
  Boolean $enable_hardening  = false,
  Lsys::PackageVersion
          $iputils_ensure    = true,
  Lsys::PackageVersion
          $iproute_ensure    = true,
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
  # Network monitoring tools including ping
  lsys::tools::package { 'iputils': ensure => $iputils_ensure }

  # Advanced IP routing and network device configuration tools
  lsys::tools::package { 'iproute': ensure => $iproute_ensure }

  # Utilities for querying DNS name servers
  # dig, host, nslookup
  lsys::tools::package { 'bind-utils': ensure => $bind_utils_ensure }

  # Searches for an object in a RFC 3912 database.
  lsys::tools::package { 'whois': ensure => $whois_ensure }

  # Basic networking tools
  lsys::tools::package { 'net-tools': ensure => $net_tools_ensure }

  # A network traffic monitoring tool
  lsys::tools::package { 'tcpdump': ensure => $tcpdump_ensure }

  # Traces the route taken by packets over an IPv4/IPv6 network
  lsys::tools::package { 'traceroute': ensure => $traceroute_ensure }

  # Nmap's Netcat replacement
  lsys::tools::package { 'nmap-ncat': ensure => $nmap_ncat_ensure }

  if $enable_hardening {
    file {
      default: mode => 'o=';
      # iproute
      '/etc/iproute2': ;
      '/usr/sbin/arpd': ;
      '/usr/sbin/bridge': ;
      '/usr/sbin/cbq': ;
      '/usr/sbin/devlink': ;
      '/usr/sbin/genl': ;
      '/usr/sbin/ifcfg': ;
      '/usr/sbin/ifstat': ;
      '/usr/sbin/ip': ;
      '/usr/sbin/lnstat': ;
      '/usr/sbin/nstat': ;
      '/usr/sbin/rdma': ;
      '/usr/sbin/routef': ;
      '/usr/sbin/routel': ;
      '/usr/sbin/rtacct': ;
      '/usr/sbin/rtmon': ;
      '/usr/sbin/rtpr': ;
      '/usr/sbin/ss': ;
      '/usr/sbin/tc': ;

      # iputils
      '/usr/bin/ping': ;
      '/usr/bin/tracepath': ;
      '/usr/bin/tracepath6': ;
      '/usr/sbin/arping': ;
      '/usr/sbin/clockdiff': ;
      '/usr/sbin/ifenslave': ;
      '/usr/sbin/rdisc': ;

      # net-tools
      '/bin/netstat': ;
      '/sbin/arp': ;
      '/sbin/ether-wake': ;
      '/sbin/ifconfig': ;
      '/sbin/ipmaddr': ;
      '/sbin/iptunnel': ;
      '/sbin/mii-diag': ;
      '/sbin/mii-tool': ;
      '/sbin/nameif': ;
      '/sbin/plipconfig': ;
      '/sbin/route': ;
      '/sbin/slattach': ;

      # tcpdump
      '/usr/sbin/tcpdump': ;
      '/usr/sbin/tcpslice': ;
    }
  }
}
