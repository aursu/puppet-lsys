# @summary Manage network administration tools
#
# Manage network administration tools
#
# @example
#   include lsys::tools::network
#
# @param enable_hardening
# @param iputils_ensure
# @param iproute_ensure
# @param bind_utils_ensure
# @param whois_ensure
# @param net_tools_ensure
# @param tcpdump_ensure
# @param traceroute_ensure
# @param nmap_ncat_ensure
#
class lsys::tools::network (
  Boolean $enable_hardening  = false,
  Bsys::PackageVersion $iputils_ensure = true,
  Bsys::PackageVersion $iproute_ensure = true,
  Bsys::PackageVersion $bind_utils_ensure = false,
  Bsys::PackageVersion $whois_ensure = false,
  Bsys::PackageVersion $net_tools_ensure = false,
  Bsys::PackageVersion $tcpdump_ensure = false,
  Bsys::PackageVersion $traceroute_ensure = false,
  Bsys::PackageVersion $nmap_ncat_ensure = false,
  Bsys::PackageVersion $netcat_ensure = false,
) {
  # Network monitoring tools including ping
  bsys::tools::package { 'iputils': ensure => $iputils_ensure }

  # Advanced IP routing and network device configuration tools
  bsys::tools::package { 'iproute': ensure => $iproute_ensure }

  # Utilities for querying DNS name servers
  # dig, host, nslookup
  bsys::tools::package { 'bind-utils': ensure => $bind_utils_ensure }

  # Searches for an object in a RFC 3912 database.
  bsys::tools::package { 'whois': ensure => $whois_ensure }

  # Basic networking tools
  bsys::tools::package { 'net-tools': ensure => $net_tools_ensure }

  # A network traffic monitoring tool
  bsys::tools::package { 'tcpdump': ensure => $tcpdump_ensure }

  # Traces the route taken by packets over an IPv4/IPv6 network
  bsys::tools::package { 'traceroute': ensure => $traceroute_ensure }

  # Nmap's Netcat replacement
  bsys::tools::package { 'nmap-ncat': ensure => $nmap_ncat_ensure }

  # OpenBSD netcat to read and write data across connections using TCP or UDP
  bsys::tools::package { 'netcat': ensure => $netcat_ensure }

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
