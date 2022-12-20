type Lsys::Host = Struct[{
    ip                     => Stdlib::IP::Address,
    Optional[name]         => Stdlib::Fqdn,
    Optional[ensure]       => Enum['present', 'absent'],
    Optional[host_aliases] => Array[Stdlib::Fqdn],
}]
