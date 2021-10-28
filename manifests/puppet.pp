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
# @param compiler
#   Whether Puppet server is compiler or not
#   see https://puppet.com/docs/puppet/7/server/scaling_puppet_server.html
#   If server is compiler then
#     - no Puppet CA and
#     - no PuppetDB on it
#
# @param sameca
#   Whether Puppet server provides CA service or not
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
          $platform_name  = 'puppet7',

  Boolean $puppetserver   = false,
  Boolean $compiler       = true,
  Boolean $sameca         = true,

  Boolean $puppetdb_local = true,
  Boolean $postgres_local = true,

  Stdlib::Host
          $server         = 'puppet',
  # https://puppet.com/docs/puppet/7/server/scaling_puppet_server.html#directing-individual-agents-to-a-central-ca
  Optional[Stdlib::Host]
          $ca_server      = undef,

  Boolean $hosts_update   = false,

  Boolean $use_common_env = false,
  Optional[String]
          $common_envname = undef,
)
{
  if $puppetserver {
    if $compiler {
      class { 'puppet::profile::compiler':
        platform_name  => $platform_name,
        ca_server      => $ca_server,
        server         => $server,
        use_common_env => $use_common_env,
        common_envname => $common_envname,
      }
      contain puppet::profile::compiler
    }
    else {
      if $puppetdb_local and $postgres_local {
        if $platform_name == 'puppet5' {
          class { 'lsys::postgres':
            package_version => '9.6.23',
          }
        }
        else {
          class { 'lsys::postgres': }
        }
      }

      class { 'puppet::profile::server':
        platform_name  => $platform_name,
        ca_server      => $ca_server,
        server         => $server,
        sameca         => $sameca,
        hosts_update   => $hosts_update,
        puppetdb_local => $puppetdb_local,
        postgres_local => $postgres_local,
        use_common_env => $use_common_env,
        common_envname => $common_envname,
      }
      contain puppet::profile::server
    }
  }
  else {
    class { 'puppet::profile::agent':
      platform_name  => $platform_name,
      server         => $server,
      ca_server      => $ca_server,
      use_common_env => $use_common_env,
      common_envname => $common_envname,
    }
  }
}
