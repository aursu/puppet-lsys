# @summary Installs and configures a complete GitLab instance and its dependencies.
#
# This class is the main "role" profile for deploying a full GitLab stack. It
# acts as an orchestrator, using other `gitlabinstall` and `lsys` component
# classes to manage the GitLab Omnibus package, an external PostgreSQL database,
# an external Nginx reverse proxy, and integrations like LDAP and an external
# Docker Registry.
#
# It provides a single, unified interface for configuring the entire system.
#
# @example Minimal configuration
#   # Installs GitLab with mandatory parameters, using defaults for everything else.
#   class { 'lsys::gitlab':
#     external_url      => 'https://gitlab.example.com',
#     registry_host     => 'registry.example.com',
#     database_password => 'AVerySecurePassword',
#   }
#
# @example Configuration with LDAP enabled
#   class { 'lsys::gitlab':
#     external_url      => 'https://gitlab.example.com',
#     registry_host     => 'registry.example.com',
#     database_password => 'AVerySecurePassword',
#     ldap_enabled      => true,
#     ldap_host         => 'ldap.example.com',
#     ldap_base         => 'ou=people,dc=example,dc=com',
#     ldap_password     => 'LdapBindPassword',
#   }
#
# @param external_url
#   The main public-facing URL for GitLab. Used to generate all links within GitLab.
# @param registry_host
#   FQDN of the external Docker Registry that this GitLab instance will integrate with.
# @param database_password
#   Password for the GitLab database user.
# @param registry_api_url
#   The internal URL that GitLab uses to contact the Docker Registry API.
# @param ldap_enabled
#   Enables or disables LDAP authentication.
# @param ldap_provider_id
#   The ID of the LDAP provider in the GitLab configuration.
# @param ldap_port
#   The port for connecting to the LDAP server.
# @param ldap_uid
#   The LDAP attribute used for the username (e.g., 'uid' or 'sAMAccountName').
# @param ldap_encryption
#   The encryption method for the LDAP connection (`simple_tls`, `start_tls`, `plain`).
# @param ldap_label
#   A human-readable label for the LDAP server, displayed on the sign-in page.
# @param ldap_prevent_ldap_sign_in
#   If `true`, disables the ability to sign in via LDAP but keeps group sync.
# @param ldap_active_directory
#   Set to `true` if your LDAP server is Active Directory.
# @param ldap_allow_username_or_email_login
#   Allows users to sign in using either their username or email.
# @param ldap_block_auto_created_users
#   If `true`, new users created via LDAP will be blocked until approved.
# @param manage_postgres_dnf_module
#   Whether to manage the DNF module for PostgreSQL (for RedHat 8+ based systems).
# @param manage_postgres_package_repo
#   Whether to manage the PostgreSQL package repository.
# @param smtp_enabled
#   Enables or disables sending mail via an external SMTP server.
# @param manage_cert_data
#   Whether to manage the GitLab SSL certificate files on disk.
# @param default_token_threshold
#   The lifetime in seconds for Docker Registry tokens.
# @param backup_cron_enable
#   Whether to enable scheduled GitLab backups via cron.
# @param pg_tools_setup
#   Whether to create symlinks for PostgreSQL tools (`pg_dump`, `psql`) for Omnibus compatibility.
# @param registry_cert_export
#   Whether to collect the Registry token certificate via exported PuppetDB resources.
# @param token_map_export
#   Whether to collect the Registry token map via exported PuppetDB resources.
# @param gitlab_rails_port
#   The internal port that `gitlab-rails` (Puma/Unicorn) listens on.
# @param monitoring
#   Whether to enable internal monitoring endpoints.
# @param external_postgresql_service
#   If `true`, GitLab will be configured to use an external, not bundled, PostgreSQL.
# @param manage_postgresql_core
#   Whether to manage the PostgreSQL server installation itself (if external).
# @param non_bundled_web_server
#   If `true`, GitLab will be configured to use an external, not bundled, Nginx.
# @param manage_nginx_core
#   Whether to manage the Nginx server installation itself (if external).
# @param jwt_gem_version
#   Version of the JWT gem to be installed. Can be a specific version number or 'installed'
#   to use the latest available version.
# @param gitlab_package_ensure
#   The version of the GitLab package to install (e.g., '17.10.8-ce.0.el8'). If `undef`, uses the version from
#   `gitlabinstall::params`.
# @param smtp_user_name
#   The username for SMTP authentication.
# @param smtp_password
#   The password for SMTP authentication.
# @param ldap_host
#   The FQDN or IP address of the LDAP server. Required if `ldap_enabled` is `true`.
# @param ldap_password
#   The password for the `bind_dn` user to connect to LDAP. Required if `ldap_enabled` is `true`.
# @param ldap_base
#   The base DN for searching for users in LDAP. Required if `ldap_enabled` is `true`.
# @param ldap_group_base
#   The base DN for searching for groups in LDAP.
# @param ldap_bind_dn
#   The DN of the user that GitLab will use to connect to LDAP.
# @param ldap_user_filter
#   An RFC 4515 formatted filter to restrict which users can sign in.
# @param ldap_first_name
#   The LDAP attribute for the user's first name.
# @param ldap_last_name
#   The LDAP attribute for the user's last name.
# @param ldap_full_name
#   The LDAP attribute for the user's full name.
# @param ldap_email
#   The LDAP attribute for the user's email.
# @param postgres_version
#   The version of PostgreSQL to install. If `undef`, uses the default from `lsys_postgresql::params`.
# @param cert_identity
#   The identity used to look up the SSL certificate in Hiera. If `undef`, defaults to the `$server_name` from
#   `gitlabinstall`.
# @param ssl_cert
#   The content of the SSL certificate in PEM format. Takes precedence over Hiera lookup.
# @param ssl_key
#   The content of the private key in PEM format. Takes precedence over Hiera lookup.
# @param external_registry_service
#   If `true`, configures integration with an external Docker Registry.
class lsys::gitlab (
  String  $external_url,
  String  $registry_host,
  String  $database_password,

  String  $registry_api_url                    = 'http://localhost:5000',
  Boolean $ldap_enabled                        = false,
  # Your configuration file must contain the following basic configuration settings:
  # label, host, port, uid, base, encryption
  String  $ldap_provider_id                    = 'main',
  Integer $ldap_port                           = 636,
  Enum['userPrincipalName', 'sAMAccountName', 'uid']
  $ldap_uid                                    = 'uid',
  Enum['simple_tls', 'start_tls', 'plain']
  $ldap_encryption                             = 'simple_tls',
  String  $ldap_label                          = 'LDAP',
  Boolean $ldap_prevent_ldap_sign_in           = false,
  Boolean $ldap_active_directory               = false,
  Boolean $ldap_allow_username_or_email_login  = false,
  Boolean $ldap_block_auto_created_users       = true,
  Boolean $manage_postgres_dnf_module          = true,
  Boolean $manage_postgres_package_repo        = false,
  Boolean $smtp_enabled                        = false,
  Boolean $manage_cert_data                    = true,

  Integer $default_token_threshold             = 600, # 10 minutes
  Boolean $backup_cron_enable                  = false,
  Boolean $pg_tools_setup                      = true,
  Boolean $registry_cert_export                = true,
  Boolean $token_map_export                    = true,
  Integer $gitlab_rails_port                   = 8080,
  Boolean $monitoring                          = false,
  Boolean $external_postgresql_service         = true,
  Boolean $manage_postgresql_core              = true,
  Boolean $non_bundled_web_server              = true,
  Boolean $manage_nginx_core                   = true,
  String  $jwt_gem_version                     = 'installed',
  Optional[String] $gitlab_package_ensure      = undef,
  Optional[String] $smtp_user_name             = undef,
  Optional[String] $smtp_password              = undef,
  Optional[Variant[Stdlib::Fqdn, Stdlib::IP::Address]]
  $ldap_host                                   = undef,
  Optional[String]  $ldap_password             = undef,
  Optional[String]  $ldap_base                 = undef,
  Optional[String] $ldap_group_base            = undef,
  Optional[String] $ldap_bind_dn               = undef,
  Optional[String] $ldap_user_filter           = undef,
  Optional[String] $ldap_first_name            = undef,
  Optional[String] $ldap_last_name             = undef,
  Optional[String] $ldap_full_name             = undef,
  Optional[String] $ldap_email                 = undef,
  Optional[String] $postgres_version           = undef,
  Optional[String] $cert_identity              = undef,
  Optional[String] $ssl_cert                   = undef,
  Optional[String] $ssl_key                    = undef,
  Boolean $external_registry_service           = true,
) {
  if $ldap_enabled and $ldap_host and $ldap_password and $ldap_base {
    class { 'gitlabinstall::ldap':
      provider_id                   => $ldap_provider_id,
      host                          => $ldap_host,
      password                      => $ldap_password,
      base                          => $ldap_base,
      port                          => $ldap_port,
      uid                           => $ldap_uid,
      encryption                    => $ldap_encryption,
      label                         => $ldap_label,
      prevent_ldap_sign_in          => $ldap_prevent_ldap_sign_in,
      active_directory              => $ldap_active_directory,
      allow_username_or_email_login => $ldap_allow_username_or_email_login,
      block_auto_created_users      => $ldap_block_auto_created_users,
      group_base                    => $ldap_group_base,
      bind_dn                       => $ldap_bind_dn,
      user_filter                   => $ldap_user_filter,
      first_name                    => $ldap_first_name,
      last_name                     => $ldap_last_name,
      full_name                     => $ldap_full_name,
      email                         => $ldap_email,
    }
  }

  include lsys_postgresql::params

  class { 'lsys_postgresql':
    repo_sslverify      => 0,
    package_version     => pick($postgres_version, $lsys_postgresql::params::postgres_version),
    manage_dnf_module   => $manage_postgres_dnf_module,
    manage_package_repo => $manage_postgres_package_repo,
  }

  class { 'gitlabinstall':
    external_url       => $external_url,
    ldap_enabled       => $ldap_enabled,
    # mandatory parameters for GitLab LDAP settings
    ldap_host          => $ldap_host,
    ldap_password      => $ldap_password,
    ldap_base          => $ldap_base,
    smtp_enabled       => $smtp_enabled,
    smtp_user_name     => $smtp_user_name,
    smtp_password      => $smtp_password,
    backup_cron_enable => $backup_cron_enable,
    pg_tools_setup     => $pg_tools_setup,
  }

  class { 'gitlabinstall::external_registry':
    # do not export token certificate into PuppetDB - we are on the same server
    registry_cert_export   => $registry_cert_export,
    # mandatory parameters to external registry feature
    registry_host          => $registry_host,
    registry_api_url       => $registry_api_url,
    token_expire_threshold => $default_token_threshold,
    token_map_export       => $token_map_export,
    jwt_gem_version        => $jwt_gem_version,
  }

  include gitlabinstall::params

  class { 'gitlabinstall::gitlab':
    database_password           => $database_password,
    gitlab_package_ensure       => pick($gitlab_package_ensure, $gitlabinstall::params::gitlab_version),
    gitlab_rails_port           => $gitlab_rails_port,
    monitoring                  => $monitoring,
    external_postgresql_service => $external_postgresql_service,
    manage_postgresql_core      => true,
    # use bundled Nginx to check settings
    non_bundled_web_server      => true,
    manage_nginx_core           => $manage_nginx_core,
    manage_cert_data            => $manage_cert_data,
    cert_identity               => $cert_identity,
    ssl_cert                    => $ssl_cert,
    ssl_key                     => $ssl_key,
    external_registry_service   => $external_registry_service,
    repo_sslverify              => 0,
    ldap_enabled                => $ldap_enabled,
    database_max_connections    => 200,
  }
  contain gitlabinstall::gitlab

  if ($token_map_export or $gitlabinstall::external_registry::token_map_setup) and $manage_nginx_core {
    include dockerinstall::registry::gitlab
    include nginx::service
    Class['dockerinstall::registry::gitlab'] ~> Class['nginx::service']
  }
}
