# @summary Resolver configuration file management
#
# Resolver configuration file management
#
# @param nameserver
#   Internet addresses of a name servers that the resolver should query. Up to
#   MAXNS (currently 3, see <resolv.h>) name servers may be listed. If there
#   are multiple servers, the resolver library queries them in the order listed.
#   If no  nameserver  entries  are  present, the default is to use the name
#   server on the local machine.
#
# @param search
#   Search list for host-name lookup
#
# @example
#   include lsys::resolv
class lsys::resolv (
  Array[Stdlib::IP::Address]
          $nameserver = [],
  Array[Stdlib::Fqdn]
          $search     = [],
  Array[Lsys::Resolv::Option]
          $options    = [],
  Array[String, 0, 10]
          $sortlist   = [],
  String  $conf_template = 'lsys/resolv/resolv.conf.erb',
)
{
  file { '/etc/resolv.conf' :
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($conf_template),
  }
}
