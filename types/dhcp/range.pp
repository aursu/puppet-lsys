type Lsys::Dhcp::Range = Struct[{
  low_address             => Stdlib::IP::Address::V4,
  Optional[high_address]  => Stdlib::IP::Address::V4,
  Optional[dynamic_bootp] => Boolean,
}]
