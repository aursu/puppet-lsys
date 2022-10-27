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
# @param options
#   Options allows certain internal resolver variables to be modified.
#
# @param sortlist
#   This option allows addresses returned by gethostbyname(3) to be sorted.
#   A sortlist is specified by IP-address-netmask pairs.
#
# @param conf_template
#   Template to use for `/etc/resolv.conf`
#
# @example
#   include lsys::resolv
class lsys::resolv (
  Array[Stdlib::IP::Address] $nameserver = [],
  Array[Stdlib::Fqdn] $search = [],
  Array[Lsys::Resolv::Option] $options = [],
  Array[String, 0, 10] $sortlist = [],
  String $conf_template = 'lsys/resolv/resolv.conf.erb',
) {
  file { '/etc/resolv.conf' :
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($conf_template),
  }

  # TODO: https://wiki.ubuntuusers.de/systemd/systemd-resolved/
}
