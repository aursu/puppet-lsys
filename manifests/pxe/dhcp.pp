# ISC DHCPD daemon setup as a bootp service
#
# @summary ISC DHCPD daemon setup as a bootp service
#
# @example
#   include lsys::pxe::dhcp
class lsys::pxe::dhcp (
  # PXE server IP address
  Stdlib::IP::Address::V4
          $next_server,

  # instruct DHCP daemon to listen on all available network interfaces
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
    Lsys::Dhcp::Subnet
  ]       $default_subnet     = {},
  Boolean  $enable            = true,
)
{
  if $enable {
    $manage_service = true
  }
  else {
    $manage_service = false

    include dhcp::params
    $servicename = $dhcp::params::servicename

    service { $servicename:
      ensure => stopped,
      enable => false,
    }
  }

  # ISC DHCP
  class { 'dhcp':
    service_ensure       => running,
    interfaces           => $dhcp_interfaces,
    authoritative        => $dhcp_authoritative,
    nameservers          => $dhcp_nameservers,

    # option 150 - TFTP server address
    # https://www.iana.org/assignments/bootp-dhcp-parameters/bootp-dhcp-parameters.xhtml
    option_code150_label => 'voip-tftp-server',
    option_code150_value => 'ip-address',

    dhcp_conf_pxe        => template('lsys/pxe/dhcpd.conf.pxe.erb'),
    manage_service       => $manage_service,
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

  # Default DHCP group
  dhcp_group { 'default': }

  # Default PXE group
  dhcp_group { 'pxe':
    pxe_settings     => true,
    next_server      => $next_server,
    tftp_server_name => true,
  }

  # Default iPXE group
  dhcp_group { 'ipxe':
    pxe_settings     => true,
    ipxe_settings    => true,
    next_server      => $next_server,
    tftp_server_name => true,
  }
}
