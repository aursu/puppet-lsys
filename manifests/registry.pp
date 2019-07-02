# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include lsys::registry
class lsys::registry (
  String  $server_name,
  Boolean $manage_nginx_core      = true,
  Boolean $manage_web_server_user = true,
  Boolean $ssl_client_ca_auth     = true,
  Optional[Array[Stdlib::Fqdn]]
          $ssl_client_ca_certs    = undef,
  # TLS data
  Optional[String]
          $ssl_cert               = undef,
  Optional[String]
          $ssl_key                = undef,
)
{
  include tlsinfo
  include lsys::registry::base

  include puppet::params
  include lsys::registry::params
  $web_server_user_id    = $lsys::registry::params::web_server_user_id
  $web_server_user       = $lsys::registry::params::web_server_user
  $web_server_group_id   = $lsys::registry::params::web_server_group_id
  $web_server_group      = $lsys::registry::params::web_server_group
  $web_server_user_home  = $lsys::registry::params::web_server_user_home
  $web_server_user_shell = $lsys::registry::params::web_server_user_shell
  $internal_certdir      = $lsys::registry::params::internal_certdir
  $internal_cacert       = $lsys::registry::params::internal_cacert
  $localcacert           = $puppet::params::localcacert

  if $ssl_client_ca_auth {
    # CA certificate
    # create CA certificate directory
    file { $internal_certdir:
      ensure  => directory,
    }

    if $ssl_client_ca_certs {
      $cacertdata = $ssl_client_ca_certs.map |$ca_name| { tlsinfo::lookup($ca_name) }

      file { $internal_cacert:
        ensure  => file,
        content => $cacertdata.join("\n"),
      }
    }
    else {
      file { $internal_cacert:
        ensure => file,
        source => "file://${localcacert}",
      }
    }

    if $manage_nginx_core {
      File[$internal_cacert] ~> Class['nginx::service']
    }
  }

  # we use Hiera for certificate/private key storage
  tlsinfo::certpair { $server_name:
    identity => true,
    cert     => $ssl_cert,
    pkey     => $ssl_key,
    # in case of self signed CA
    strict   => false,
  }

  # get certificate data from Hiera
  if $ssl_cert {
    $certdata = $ssl_cert
  }
  else {
    $certdata = tlsinfo::lookup($server_name)
  }

  # we use default locations for certificate and key storage - get
  # these locations
  $ssl_cert_path = tlsinfo::certpath($certdata)
  $ssl_key_path = tlsinfo::keypath($certdata)

  class { 'lsys::registry::nginx':
    server_name           => $server_name,
    manage_service        => $manage_nginx_core,
    manage_user           => $manage_web_server_user,
    daemon_user           => $web_server_user,
    daemon_user_id        => $web_server_user_id,
    daemon_group          => $web_server_group,
    daemon_group_id       => $web_server_group_id,
    web_server_user_home  => $web_server_user_home,
    web_server_user_shell => $web_server_user_shell,
    ssl                   => true,
    ssl_cert              => $ssl_cert_path,
    ssl_key               => $ssl_key_path,
    ssl_client_ca_auth    => $ssl_client_ca_auth,
  }

  if $manage_nginx_core {
    Tlsinfo::Certpair[$server_name] ~> Class['nginx::service']
  }
}
