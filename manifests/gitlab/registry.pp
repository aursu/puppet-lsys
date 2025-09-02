# @summary Deploys a secure Docker Registry integrated with a co-located GitLab instance.
#
# This class provides a high-level, opinionated interface to deploy a complete
# Docker Registry stack. It acts as a wrapper, composing the `dockerinstall`
# module's profile and base classes to handle the underlying complexity.
#
# The primary design goal of this class is to simplify the deployment of a
# Docker Registry that uses a co-located GitLab instance for token
# authentication. While it can be configured for a distributed setup, its
# defaults are optimized for a single-host deployment.
#
# It orchestrates the deployment in two main steps:
#   1. It ensures the Docker Registry container itself is configured and running.
#   2. It configures a secure Nginx reverse proxy to handle traffic, SSL, and
#      authentication for the registry.
#
# @example Basic usage (no token auth, Hiera for certs)
#   class { 'lsys::gitlab::registry':
#     server_name   => 'registry.example.com',
#     cert_identity => 'wildcard.example.com', # Optional: use a different key for Hiera
#   }
#
# @example Enabling token auth for a co-located GitLab
#   # In this common case, auth_token_local_gitlab defaults to true and
#   # auth_token_realm_host defaults to the server_name.
#   class { 'lsys::gitlab::registry':
#     server_name       => 'registry.example.com',
#     auth_token_enable => true,
#   }
#
# @example Enabling token auth for a remote GitLab
#   class { 'lsys::gitlab::registry':
#     server_name               => 'registry.example.com',
#     auth_token_enable         => true,
#     auth_token_local_gitlab  => false, # Enable PuppetDB sync
#     auth_token_realm_host     => 'gitlab.example.com',
#   }
#
# @param server_name
#   The FQDN of the registry server. This is used as the `server_name` for the
#   Nginx proxy and as the default `realm_host` for token authentication.
# @param docker_image
#   The Docker image and tag to use for the registry container.
# @param manage_nginx_core
#   Toggles whether the underlying Nginx module should manage the core Nginx
#   package and service, or just add the registry vhost configuration.
# @param manage_cert_data
#   Toggles whether the underlying profile should manage the SSL certificate and
#   key files via the `tlsinfo::certpair` type.
# @param cert_identity
#   The identity (Common Name) used to look up the server's SSL certificate from
#   Hiera. This is only used if `$ssl_cert` and `$ssl_key` are not directly
#   provided. If this is also `undef`, the profile defaults to using `$server_name`.
# @param ssl_client_ca_auth
#   Toggles mutual TLS (mTLS), which enables client certificate authentication
#   in the Nginx reverse proxy.
# @param ssl_client_ca_certs
#   An array of names used to look up CA certificates from Hiera. These are used
#   to build the trust chain for client certificate authentication. If not provided,
#   it defaults to using the infrastructure's main Puppet CA certificate.
# @param accesslog_disabled
#   Toggles the access log service within the Docker Registry container itself.
# @param ssl_cert
#   The full PEM-encoded content of the server's SSL certificate. If provided,
#   this bypasses the Hiera lookup. Both `$ssl_cert` and `$ssl_key` must be specified.
# @param ssl_key
#   The full PEM-encoded content of the server's private key. If provided,
#   this bypasses the Hiera lookup. Both `$ssl_cert` and `$ssl_key` must be specified.
# @param auth_token_enable
#   If `true`, this activates the token authentication feature for the registry.
# @param auth_token_realm_host
#   The FQDN of the GitLab server that provides authentication tokens.
#   If left `undef`, this will default to the value of `$server_name`.
# @param auth_token_local_gitlab
#   A flag to simplify configuration based on your architecture.
#   - Set to `true` (default) for a co-located setup where GitLab and the registry
#     are on the same host. This disables PuppetDB resource synchronization.
#   - Set to `false` for a distributed setup where GitLab and the registry are on
#     different hosts. This enables PuppetDB resource synchronization.
#
class lsys::gitlab::registry (
  Stdlib::Fqdn $server_name,
  String  $docker_image            = 'registry:3.0.0',
  Boolean $manage_nginx_core       = true,
  Boolean $manage_cert_data        = true,
  Optional[String]
  $cert_identity                   = undef,
  Boolean $ssl_client_ca_auth      = true,
  Optional[Array[Stdlib::Fqdn]]
  $ssl_client_ca_certs             = undef,

  Boolean $accesslog_disabled      = true,
  Boolean $traces_disabled         = true,

  # TLS data
  Optional[String] $ssl_cert       = undef,
  Optional[String] $ssl_key        = undef,

  Boolean $global_ssl_redirect     = true,

  # Token Authentication
  Boolean $auth_token_enable       = false,
  Optional[Stdlib::Fqdn]
  $auth_token_realm_host           = undef,
  Boolean $auth_token_local_gitlab = true,
  Optional[Stdlib::Fqdn]
  $gitlab_server_name              = undef,
) {
  # --- Token Authentication Logic ---
  # If enabled, declare the auth_token class with the correct parameters.
  if $auth_token_enable {
    # Determine if PuppetDB synchronization is needed. Synchronization is required
    # only when GitLab is NOT local (`auth_token_local_gitlab` is false). We export
    # resources specifically so that another node can import them through PuppetDB.
    $enable_puppetdb_sync = !$auth_token_local_gitlab

    class { 'dockerinstall::registry::auth_token':
      enable               => true,
      gitlab               => true, # This profile is hardcoded to GitLab auth mode.
      realm_host           => pick($auth_token_realm_host, $gitlab_server_name),
      registry_cert_export => $enable_puppetdb_sync,
      token_map_export     => $enable_puppetdb_sync,
    }
  }

  # --- Main Deployment Steps ---

  # 1. Ensure the Registry container is configured to run.
  # This class handles the Docker image and runtime environment for the registry service itself.
  class { 'dockerinstall::registry::base':
    accesslog_disabled => $accesslog_disabled,
    traces_disabled    => $traces_disabled,
    docker_image       => $docker_image,
  }

  # 2. Configure the Nginx reverse proxy to front the Registry.
  # This class handles Nginx setup, SSL termination, and certificate management.
  class { 'dockerinstall::profile::registry':
    server_name         => $server_name,
    manage_nginx_core   => $manage_nginx_core,
    manage_cert_data    => $manage_cert_data,
    cert_identity       => $cert_identity,
    ssl_cert            => $ssl_cert,
    ssl_key             => $ssl_key,
    ssl_client_ca_auth  => $ssl_client_ca_auth,
    ssl_client_ca_certs => $ssl_client_ca_certs,
    global_ssl_redirect => $global_ssl_redirect,
  }
}
