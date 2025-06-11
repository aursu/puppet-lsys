# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include lsys::registry
class lsys::registry (
  String  $server_name,
  String  $docker_image       = 'registry:3.0.0',
  Boolean $manage_nginx_core  = true,
  Boolean $manage_cert_data   = true,
  Optional[String]
  $cert_identity              = undef,
  Boolean $ssl_client_ca_auth = true,
  Optional[Array[Stdlib::Fqdn]]
  $ssl_client_ca_certs        = undef,

  Boolean $accesslog_disabled = true,
  # TLS data
  Optional[String] $ssl_cert  = undef,
  Optional[String] $ssl_key   = undef,
) {
  class { 'dockerinstall::registry::base':
    accesslog_disabled => $accesslog_disabled,
    docker_image       => $docker_image,
  }

  # Docker registry
  class { 'dockerinstall::profile::registry':
    server_name         => $server_name,
    manage_nginx_core   => $manage_nginx_core,

    manage_cert_data    => $manage_cert_data,
    cert_identity       => $cert_identity,
    ssl_cert            => $ssl_cert,
    ssl_key             => $ssl_key,

    ssl_client_ca_auth  => $ssl_client_ca_auth,
    ssl_client_ca_certs => $ssl_client_ca_certs,
  }
}
