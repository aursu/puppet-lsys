# dhcpd.conf shared-network declaration
#
# @summary dhcpd.conf shared-network declaration
#
# @example
#   lsys::dhcp::shared_network { 'namevar': }
define lsys::dhcp::shared_network(
  # Name should be the name of the shared network. This name is used when
  # printing debugging messages, so it should be descriptive for the shared
  # network. The name may have the syntax of a valid domain name (although it
  # will never be used as such), or it may be any arbitrary name, enclosed in
  # quotes.
  String  $network_name     = $name,
  Optional[
    Variant[
      Stdlib::Host,
      Array[Stdlib::Host]
    ]
  ]       $nameservers      = undef,
  Optional[Stdlib::Fqdn]
          $domain_name      = undef,
  Optional[Array[String]]
          $options          = undef,
  Optional[Array[String]]
          $parameters       = undef,
  # Any subnets in a shared network should be declared within a shared-network
  # statement
  Hash[
    String,
    Lsys::Dhcp::Subnet
  ]       $subnet       = {},
) {
  include dhcp::params

  $dhcp_dir = $dhcp::params::dhcp_dir

  concat::fragment { "dhcp_shared_network_${name}":
    target  => "${dhcp_dir}/dhcpd.pools",
    content => template('lsys/dhcp/dhcpd.shared_network.erb'),
  }
}
