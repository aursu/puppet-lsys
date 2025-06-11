# @summary Deploys a secure Docker Registry with an Nginx reverse proxy.
#
# This class provides a high-level interface to deploy a complete Docker
# Registry stack. It acts as a wrapper, composing the `dockerinstall` module's
# profile and base classes to handle the underlying complexity.
#
# It orchestrates the deployment of:
#   - The Docker Registry container itself, managed by `dockerinstall::registry::base`.
#   - A secure Nginx reverse proxy, configured by `dockerinstall::profile::registry`.
#   - SSL/TLS certificate management for the Nginx proxy, also handled by the profile.
#
# By using this class, you can deploy the entire stack by providing a few
# high-level parameters, such as the server name and certificate details.
#
# @example Basic usage with Hiera-based certificate lookup
#   class { 'lsys::registry':
#     server_name   => 'registry.example.com',
#     cert_identity => 'wildcard.example.com', # Optional: use a different key for Hiera
#   }
#
# @example Providing certificate data directly
#   class { 'lsys::registry':
#     server_name => 'registry.example.com',
#     ssl_cert    => "-----BEGIN CERTIFICATE-----\n...",
#     ssl_key     => "-----BEGIN PRIVATE KEY-----\n...",
#   }
#
# @param server_name The FQDN of the registry server. This is used as the `server_name` in the Nginx configuration.
# @param docker_image The Docker image and tag to use for the registry container.
# @param manage_nginx_core Toggles whether the underlying `lsys_nginx` module should manage the core Nginx package and service, or just add the registry vhost configuration.
# @param manage_cert_data Toggles whether the underlying profile should manage the SSL certificate and key files via the `tlsinfo::certpair` type.
# @param cert_identity The identity (Common Name) to use for looking up the server's SSL certificate in Hiera. This parameter is only used if `$ssl_cert` and `$ssl_key` are not provided directly. If this parameter is also `undef`, the profile defaults to using the `$server_name`.
# @param ssl_client_ca_auth Toggles mutual TLS (mTLS), enabling or disabling client certificate authentication in the Nginx reverse proxy.
# @param ssl_client_ca_certs An array of FQDNs or names used to look up CA certificates from Hiera. These are used to build the trust chain for client certificate authentication. If not provided, it defaults to using the Puppet CA.
# @param accesslog_disabled Toggles the access log within the Docker Registry container itself.
# @param ssl_cert Allows providing the server's SSL certificate PEM data directly, bypassing Hiera lookup. Both `$ssl_cert` and `$ssl_key` must be provided together.
# @param ssl_key Allows providing the server's SSL private key PEM data directly, bypassing Hiera lookup. Both `$ssl_cert` and `$ssl_key` must be provided together.
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
