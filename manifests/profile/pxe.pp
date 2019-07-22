# PXE profile
#
# @summary PXE profile
#
# @param dhcp_default_subnet
#   ISC DHCP server will not start if not defined subnet declarations for
#   at least one network interface on DHCP server. dhcpd daemon will listen
#   only those network interfaces for which appropriate subnet defined inside
#   dhcpd.conf
#
# @param root_authorized_keys
#   Default SSH authorized_keys file for root user. Parameter should be valid
#   path to Puppet file resource  which could be passed into standart Puppet
#   function file() (see https://puppet.com/docs/puppet/5.5/function.html#file)
#   This file can be accessed from Kickstart script via URL
#   http://${install_server}/ks/assets/root.authorized_keys

# @param puppet_local_config
#   Default Puppet configuration file for rpovisioned infrastructure. Parameter
#   should be valid path to Puppet file resource  which could be passed into
#   standart Puppet function file()
#   (see https://puppet.com/docs/puppet/5.5/function.html#file)
#   This file can be accessed from Kickstart script via URL
#   http://${install_server}/ks/assets/puppet.conf
#
# @param enc_repo_source
#   Git URL to be passed as 'source' parameter to Vcsrepo['/var/lib/pxe/enc']
#   puppet resource (see https://forge.puppet.com/puppetlabs/vcsrepo for
#   details)
#
# @param enc_repo_identity
#   SSH private key. This private key location is /root/.ssh/enc.id_rsa
#   It will be passed as 'identity' parameter to Vcsrepo['/var/lib/pxe/enc']
#   puppet resource
#
# @param enc_repo_branch
#   Git branch for ENC repository. Default value is 'enc'
#
# @note
#   This PXE environment must include ENC repository.
#   ENC repository is a Git repository which contain ENC data about each host
#   managed by Puppet.
#   See https://puppet.com/docs/puppet/5.0/nodes_external.html#what-is-an-enc
#   for details.
#   Each YAML file inside ENC repo named in form <fqdn>.yaml (or .yml or .eyaml)
#   No subfolders allowed inside repository
#   ENC repository could be used in conjuction with ENC script located here
#   https://github.com/aursu/puppet-puppet/blob/master/templates/enc.erb
#
# @example
#   class { 'lsys::profile::pxe':
#     install_server         => 'install.domain.tld',
#     install_server_address => '192.168.1.10',
#     resolver               => ['192.168.1.1', '8.8.8.8', '1.1.1.1'],
#     dhcp_default_subnet    => {
#        'VLAN400' => {
#          network     => '192.168.1.0',
#          mask        => '255.255.255.0',
#          broadcast   => '192.168.1.255',
#          routers     => '192.168.1.1',
#          domain_name => 'domain.tld',
#          nameservers => ['192.168.1.1', '8.8.8.8', '1.1.1.1'],
#        }
#     },
#     root_authorized_keys   => 'profile/pxe/root.authorized_keys',
#     puppet_local_config    => 'profile/pxe/puppet.conf',
#     enc_repo_source        => 'git@gitlab.domain.tld:infra/enc.git',
#     enc_repo_identity      => lookup('profile::pxe::enc_identity', String, 'first', undef),
#     enc_repo_branch        => 'master',
#   }
#
class lsys::profile::pxe (
  Stdlib::Fqdn
          $install_server,
  Stdlib::IP::Address
          $install_server_address,
  Array[Stdlib::IP::Address]
          $resolver,
  Hash[String, Lsys::Dhcp::Subnet]
          $dhcp_default_subnet,
  String  $enc_repo_source,
  String  $enc_repo_identity,
  String  $enc_repo_branch        = 'enc',
  Boolean $enable                 = true,
  Optional[String]
          $root_authorized_keys   = undef,
  Optional[String]
          $puppet_local_config    = undef,
)
{
  Lsys::Pxe::Client_config {
    install_server => $install_server,
  }

  # In case if main WEB service is Nginx we should proxy requests from Nginx
  # to Apache using settings in profile 'lsys::profile::pxe::nginx'
  # It requires to set 'lsys::pxe::server::web_port' to 8080
  #
  # This configuration is basic - of cource it depends on real Nginx setup and
  # network architecture
  #
  # class { 'lsys::profile::pxe::nginx':
  #   server_name => $install_server,
  #   resolver    => $resolver,
  # }

  # GRUB installation
  class { 'lsys::pxe::grub':
    enable => $enable,
  }

  # iPXE installation
  class { 'lsys::pxe::ipxe': }

  # TFTP installation
  class { 'lsys::pxe::tftp':
    service_enable => $enable,
    verbose        => true,
  }

  # DHCP daemon installation (ISC DHCP)
  class { 'lsys::pxe::dhcp':
    enable         => $enable,
    next_server    => $install_server_address,
    default_subnet => $dhcp_default_subnet,
  }

  # PXE server structure and assets setup
  #
  # Please notice 'manage_web_user' parameter - it could enable/disable system
  # users management by class 'httpd' declared inside 'lsys::pxe::server'
  class { 'lsys::pxe::server':
    enable               => $enable,
    server_name          => $install_server,
    manage_web_user      => $enable,
    root_authorized_keys => $root_authorized_keys,
    puppet_local_config  => $puppet_local_config,
  }

  # ENC repository setup
  class { 'lsys::profile::pxe::enc':
    repo_source   => $enc_repo_source,
    repo_identity => $enc_repo_identity,
    repo_branch   => $enc_repo_branch,
  }
}
