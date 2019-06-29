# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include lsys::pxe::dhcp
class lsys::pxe::dhcp (
  # instruct DHCP daemon to listen on all available
  # network interfaces
  Array[String[1]]
          $dhcp_interfaces    = [],

  # installation server could not be authoritative
  # see "authoritative" directive on https://kb.isc.org/docs/isc-dhcp-41-manual-pages-dhcpdconf
  Boolean $dhcp_authoritative = false,

  # no global (default) DNS servers
  # see "option domain-name-servers" in https://kb.isc.org/docs/isc-dhcp-44-manual-pages-dhcp-options
  Array[Stdlib::IP::Address::V4]
          $dhcp_nameservers   = [],

  # ISC DHCP will exit immediately if not declared subnet for at least one
  # listening interface.
  # see "dhcp::pool" defined type from https://github.com/voxpupuli/puppet-dhcp
  Hash[
    String,
    Struct[{
      network               => Stdlib::IP::Address::V4,
      mask                  => Stdlib::IP::Address::V4,
      Optional[routers]     => String,                  # see "option routers" on https://kb.isc.org/docs/isc-dhcp-44-manual-pages-dhcp-options
      Optional[domain_name] => Stdlib::Fqdn,            # see "option domain-name"
      Optional[nameservers] => Array[Stdlib::Host],     # see "option domain-name-servers"
      Optional[broadcast]   => Stdlib::IP::Address::V4, # see "option broadcast-address"
    }]
  ]       $default_subnet     = {},
)
{
  # ISC DHCP
  class { 'dhcp':
    service_ensure       => running,
    interfaces           => $dhcp_interfaces,
    authoritative        => $dhcp_authoritative,
    nameservers          => $dhcp_nameservers,

    # option 150 - TFTP server address
    # https://www.iana.org/assignments/bootp-dhcp-parameters/bootp-dhcp-parameters.xhtml
    option_code150_label => 'tftp-server-address',
    option_code150_value => 'ip-address',
  }

  $default_subnet.each | String $name, $parameters | {
    $subnet_broadcast_address = $parameters['broadcast']
    $dhcp_pool_gateway        = $parameters['routers']
    $dhcp_pool_parameters     = $parameters - ['broadcast', 'routers']

    $option_broadcast_address = $subnet_broadcast_address ? {
      Stdlib::IP::Address::V4 => [ "broadcast-address ${subnet_broadcast_address}" ],
      default                 => [],
    }

    dhcp::pool { $name:
      * => {
        gateway => "${dhcp_pool_gateway}", # lint:ignore:only_variable_string
        options => $option_broadcast_address,
      } + $dhcp_pool_parameters;
    }
  }
}
