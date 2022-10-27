# @summary Graylog server installation
#
# Graylog server installation
#
# @example
#   include lsys::graylog
class lsys::graylog (
  String  $root_password,
  String[64]
          $password_secret,
  String  $mongodb_password,
  Optional[Array[Stdlib::IP::Address]]
          $elastic_seed_hosts   = undef,
  Optional[String]
          $elastic_network_host = undef,
  Boolean $elastic_master_only  = false,
  Optional[Stdlib::IP::Address]
          $cluster_network      = undef,

  Boolean $is_master            = false,
  Boolean $enable_web           = true,
  Boolean $manage_web_user      = true,
  Optional[Stdlib::Fqdn]
          $http_server          = undef,
) {
  if $enable_web and $http_server {
    class { 'lsys::nginx':
      manage_user => $manage_web_user,
    }

    Class['lsys::nginx'] -> Class['grayloginstall::server']
  }

  class { 'grayloginstall::server':
    root_password        => $root_password,
    password_secret      => $password_secret,
    mongodb_password     => $mongodb_password,
    elastic_seed_hosts   => $elastic_seed_hosts,
    elastic_network_host => $elastic_network_host,
    elastic_master_only  => $elastic_master_only,
    cluster_network      => $cluster_network,
    repo_sslverify       => 0,

    is_master            => $is_master,
    enable_web           => $enable_web,
    http_server          => $http_server,
  }
}
