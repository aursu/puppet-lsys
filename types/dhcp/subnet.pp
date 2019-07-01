type Lsys::Dhcp::Subnet = Struct[{
  network                       => Stdlib::IP::Address::V4,
  mask                          => Stdlib::IP::Address::V4,
  Optional[routers]             => String,                  # see "option routers" on https://kb.isc.org/docs/isc-dhcp-44-manual-pages-dhcp-options
  Optional[domain_name]         => Stdlib::Fqdn,            # see "option domain-name"
  Optional[nameservers]         => Array[Stdlib::Host],     # see "option domain-name-servers"
  Optional[broadcast]           => Stdlib::IP::Address::V4, # see "option broadcast-address"
  Optional[range]               => Lsys::Dhcp::Range,       # see "The range statement" in https://kb.isc.org/docs/isc-dhcp-41-manual-pages-dhcpdconf#REFERENCE:%20DECLARATIONS
  Optional[filename]            => String,                  # see "The filename statement" in https://kb.isc.org/docs/isc-dhcp-41-manual-pages-dhcpdconf#REFERENCE:%20PARAMETERS
  Optional[default_lease_time]  => Integer,                 # see "The default-lease-time statement"
  Optional[max_lease_time]      => Integer,                 # see "The max-lease-time statement"
  Optional[next_server]         => Stdlib::Host,            # see "The next-server statement"
}]
