# @summary This class will manage hosts records
#
# This class will manage hosts records inside /etc/hosts file
#
# @param hosts
#   Hash, default is IPv4 localhost record. If given, each record will be passed
#   as "host" resource via "create_resources" function
#
# @param aliases
#   Array of Strings, default empty. If given, each value will be used as alias
#   for current host (where class "hosts" included)
#
# @param exported
#   Boolean, default 'true'. True means export "host" record with current host's
#   IPv4 address, hostname, fqdn and aliases (depnds on hosts::exported_aliases)
#
# @param collect_exported
#   Boolean, default 'true'. True means collect all exported @@host resources by
#   class "hosts" on current and another nodes
#
# @param exported_aliases
#   Boolean, default 'false'. True means export also aliases
#
# @param manage_local
#   Boolean, default 'true'. True means manage localhost records for IPv4 and
#   IPv6 default loopback addressess (127.0.0.1 and ::1)
#
# @param aliases_network
# @param collect_tag
# @param ipv6_enable
#
class lsys::hosts (
  Boolean $exported = true,
  Array[Stdlib::Fqdn] $aliases = [],
  Boolean $exported_aliases = false,
  Optional[Stdlib::IP::Address::V4::CIDR] $aliases_network = undef,
  String $collect_tag = 'exported',
  Hash[Stdlib::Fqdn, Lsys::Host] $hosts = {},
  Boolean $manage_local = true,
  Boolean $collect_exported = true,
  Boolean $ipv6_enable = true,
) {
  $hosts_local4 = {
    'localhost' => {
      'ensure'       => 'present',
      'name'         => 'localhost',
      'host_aliases' => ['localhost.localdomain', 'localhost4', 'localhost4.localdomain4'],
      'ip'           => '127.0.0.1',
    },
  }

  $hosts_local6 = {
    'localhost6' => {
      'ensure'       => 'present',
      'name'         => 'localhost6',
      'host_aliases' => ['localhost', 'localhost.localdomain', 'localhost6.localdomain6'],
      'ip'           => '::1',
    },
  }

  if $ipv6_enable {
    $hosts_local = $hosts_local4 + $hosts_local6
  }
  else {
    $hosts_local = $hosts_local4
  }

  $aliases_address = networksetup::local_ips($aliases_network)

  $fqdn     = $facts['networking']['fqdn']
  $hostname = $facts['networking']['hostname']
  $domain   = $facts['networking']['domain']

  if $fqdn {
    $aliases_hostname = [$hostname]
    $local_hostname = $fqdn
  }
  else {
    $aliases_hostname = []
    $local_hostname = $hostname
  }

  # either $local_hostname or $aliases_hostname include $hostname
  # therefore remove it from $local_aliases
  $aliases_defined = $aliases - [$hostname]

  if $domain and "${hostname}.${domain}" != $fqdn {
    $aliases_domain = ["${hostname}.${domain}"]
  }
  else {
    $aliases_domain = []
  }

  # to export aliases, both flags should be 'true'
  if $exported_aliases and $exported {
    $aliases_local = []
    $aliases_export = $aliases_defined
  }
  else {
    $aliases_local = $aliases_defined
    $aliases_export = []
  }

  if $aliases_address[0] {
    if $exported {
      @@host { $local_hostname:
        ensure       => 'present',
        ip           => $aliases_address[0],
        host_aliases => $aliases_hostname + $aliases_domain + $aliases_export,
        tag          => $collect_tag,
      }
    }
    else {
      host { $local_hostname:
        ensure       => 'present',
        ip           => $aliases_address[0],
        host_aliases => $aliases_hostname + $aliases_domain + $aliases_local,
      }
    }
  }

  # if manage_local flag set - define also "host" resource for loopback records
  if $manage_local {
    $nodes = $hosts + $hosts_local
  }
  else {
    $nodes = $hosts
  }

  $nodes.each | $node_name, $node_data | {
    host { $node_name:
      * => $node_data,
    }
  }

  # collect all exported records (as well as self-exported)
  if $collect_exported {
    Host <<| tag == $collect_tag |>>
  }
  # otherwise - collect only self-exported
  else {
    Host <<| title == $local_hostname |>>
  }

  # we should add aliases separately (as they was not exported/collected)
  # accessing non-existing element returns 'undef'
  if $exported and $aliases_local[0] and $aliases_address[0] {
    host { $aliases_local[0]:
      ensure       => 'present',
      ip           => $aliases_address[0],
      host_aliases => $aliases_local[1,-1],
    }
  }
}
