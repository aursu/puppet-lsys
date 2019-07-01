type Lsys::Dhcp::Host = Struct[{
  mac                     => Dhcp::Mac,               # see "The hardware statement" on https://kb.isc.org/docs/isc-dhcp-41-manual-pages-dhcpdconf#REFERENCE:%20PARAMETERS
  Optional[ip]            => Stdlib::IP::Address,     # see "The fixed-address declaration"
  Optional[mask]          => Stdlib::IP::Address,     # see "option subnet-mask" on https://kb.isc.org/docs/isc-dhcp-44-manual-pages-dhcp-options
  Optional[host_name]     => Stdlib::Fqdn,            # see "option host-name"
  Optional[routers]       => String,                  # see "option routers"
  Optional[filename]      => String,                  # see "The filename statement"
  Optional[next_server]   => Stdlib::Host,            # see "The next-server statement"
}]
