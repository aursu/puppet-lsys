# @summary Puppet installation
#
# Puppet installation
#
# @param platform_name
#   Puppet platform name. Either puppet5, puppet6 or puppet7
#
# @param puppetserver
#   Whether it is Puppet server or not
#
# @param server
#   Puppet server name
#
# @param hosts_update
#   Whether to setup puppet server hostnamr into /etc/hosts file
#
# @example
#   include lsys::puppet
class lsys::puppet (
  Puppet::Platform
          $platform_name = 'puppet7',
  Boolean $puppetserver  = false,
  Stdlib::Host
          $server        = 'puppet',
  Optional[Stdlib::Host]
          $ca_server     = undef,
  Boolean $hosts_update  = false,
)
{
  if $puppetserver {
    if $platform_name == 'puppet5' {
      class { 'lsys::postgres':
        package_version => '9.6.20',
      }
    }
    else {
      class { 'lsys::postgres': }
    }

    class { 'puppet::profile::server':
      platform_name => $platform_name,
      server        => $server,
      hosts_update  => $hosts_update,
    }
  }
  else {
    class { 'puppet::profile::agent':
      platform_name => $platform_name,
      server        => $server,
      ca_server     => $ca_server,
      hosts_update  => $hosts_update,
    }
  }
}
