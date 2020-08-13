# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include lsys::nginx
class lsys::nginx  (
  String  $package_ensure           = $lsys::params::nginx_version,
  Boolean $manage_user              = true,
  Boolean $manage_user_home         = false,
  String  $daemon_group             = $lsys::webserver::params::user,
  Integer $daemon_group_id          = $lsys::webserver::params::user_id,
  String  $daemon_user              = $lsys::webserver::params::group,
  Integer $daemon_user_id           = $lsys::webserver::params::group_id,
  Optional[String]
          $charset                  = undef,
  Optional[String]
          $charset_types            = undef,
  Optional[Nginx::Time]
          $client_body_timeout      = undef,              # 60s
  Optional[Nginx::Time]
          $client_header_timeout    = undef,              # 60s
  Optional[Stdlib::Unixpath]
          $conf_dir                 = undef,
  Optional[String]
          $default_type             = undef,              # 'text/plain'
  Optional[Nginx::Switch]
          $etag                     = undef,              # 'on'
  # http://nginx.org/en/docs/events.html
  Optional[Nginx::ConnectionProcessing]
          $events_use               = undef,              # 'epoll'
  Optional[Nginx::Size]
          $fastcgi_buffer_size      = undef,              # '4k|8k'
  Optional[Nginx::Buffers]
          $fastcgi_buffers          = undef,              # '8 4k|8 8k'
  Boolean $global_ssl_redirect      = false,
  Optional[Array[String]]
          $gzip_types               = [                   # 'text/html'
                                        'application/javascript',
                                        'application/json',
                                        'application/x-javascript',
                                        'application/xml',
                                        'application/xml+rss',
                                        'text/css',
                                        'text/javascript',
                                        'text/plain',
                                        'text/xml'
                                      ],
  Optional[Stdlib::Unixpath]
          $http_access_log          = undef,
  Optional[String]
          $http_format_log          = undef,
  Variant[
      String,
      Array[String]
  ]       $http_raw_prepend         = [],
  Optional[String]
          $index                    = undef,              # 'index.html'
  Optional[Nginx::Time]
          $keepalive_timeout        = 65,                 # 75s
  Optional[Hash[String, String]]
          $log_format               = undef,
  Boolean $manage_document_root     = false,
  Optional[Integer]
          $names_hash_bucket_size   = 64,                 # 32|64|128
  Optional[Integer]
          $names_hash_max_size      = undef,              # 512
  Stdlib::Unixpath
          $nginx_cache_directory    = $lsys::params::nginx_cachedir,
  Optional[Stdlib::Unixpath]
          $nginx_lib_directory      = $lsys::params::nginx_libdir,
  # only for cases when it is custom
  Optional[Stdlib::Unixpath]
          $nginx_log_directory      = undef,
  Stdlib::Unixpath
          $nginx_proxy_temp_path    = $lsys::params::nginx_proxy_temp_path,
  Optional[Nginx::FileCache]
          $open_file_cache          = undef,              # 'off'
  Integer $open_file_cache_min_uses = 1,                  # 1
  Nginx::Time
          $open_file_cache_valid    = 60,                 # 60s
  Optional[String]
          $package_name             = undef,
  String  $package_source           = 'nginx-mainline',
  Optional[Stdlib::Unixpath]
          $pid_path                 = undef,
  Optional[Boolean]
          $port_in_redirect         = undef,              # 'on'
  Optional[Boolean]
          $proxy_buffering          = undef,              # on
  Optional[String]
          $proxy_cache              = undef,
  Optional[String]
          $proxy_cache_key          = undef,              # $scheme$proxy_host$request_uri
  Optional[Hash]
          $proxy_cache_path         = undef,
  Optional[Stdlib::Unixpath]
          $proxy_temp_path          = undef,
  Optional[Boolean]
          $recursive_error_pages    = undef,              # off
  Optional[String]
          $service_name             = undef,
  Optional[Nginx::Time]
          $send_timeout             = undef,              # 60s
  # to control only few nginx configuration files and
  # to not remove all other
  Boolean $server_purge             = true,
  Optional[Nginx::Size]
          $types_hash_max_size      = undef,              # 1024
  Stdlib::Unixpath
          $nginx_user_home          = $lsys::params::nginx_user_home,
  Stdlib::Unixpath
          $web_server_user_shell    = $lsys::webserver::params::user_shell,
  Optional[Boolean]
          $yum_repo_sslverify       = false,
) inherits lsys::params
{
  include nginx::params

  $nginx_conf_dir = $conf_dir ? {
    Stdlib::Unixpath => $conf_dir,
    default          => $nginx::params::conf_dir,
  }

  $nginx_package_name = $package_name ? {
    String  => $package_name,
    default => $nginx::params::package_name,
  }

  $nginx_pid_path = $pid_path ? {
    Stdlib::Unixpath => $pid_path,
    default          => $nginx::params::pid,
  }

  if $daemon_user == 'root' {
    $resource_owner = undef
    $resource_group = undef
  }
  else {
    $resource_owner = $daemon_user
    $resource_group = $daemon_group
  }

  $runtime_directories = [
    $nginx_cache_directory,
    $nginx_proxy_temp_path,
    $nginx_lib_directory,
    "${nginx_lib_directory}/tmp"
  ].unique

  file { $runtime_directories:
    ensure => directory,
    owner  => $resource_owner,
    mode   => '0700',
  }

  if $manage_user {
    unless $daemon_group in ['root', 'wheel'] {
      group { $daemon_group:
        ensure    => present,
        gid       => $daemon_group_id,
        allowdupe => true,
      }
    }

    unless $daemon_user == 'root' or $daemon_user_id == 0 {
      user { $daemon_user:
        ensure     => present,
        uid        => $daemon_user_id,
        allowdupe  => true,
        gid        => $daemon_group,
        home       => $nginx_user_home,
        managehome => false,
        shell      => $web_server_user_shell,
      }

      unless $daemon_group in ['root', 'wheel'] {
        Group[$daemon_group] -> User[$daemon_user]
      }

      User[$daemon_user] -> Class['nginx']
    }

    if $manage_user_home and !($nginx_user_home in $runtime_directories) {
      file { $nginx_user_home:
        ensure => directory,
        owner  => $resource_owner,
        group  => $resource_group,
      }
    }
  }

  if $nginx_log_directory {
    # nginx::configs class manages default log directory unconditionally
    unless $nginx_log_directory == $nginx::params::log_dir {
      file { $nginx_log_directory:
        ensure  => directory,
        group   => $daemon_group,
        owner   => $daemon_user,
        seltype => 'httpd_log_t',
        recurse => true,
      }
    }

    if $facts['selinux'] {
      selinux::fcontext { "${nginx_log_directory}(/.*)?":
        filetype => 'f',
        seltype  => 'httpd_log_t',
        require  => File[$nginx_log_directory],
        alias    => $nginx_log_directory,
      }

      selinux::exec_restorecon { $nginx_log_directory:
        subscribe => Selinux::Fcontext[$nginx_log_directory]
      }
    }
  }

  if $manage_document_root {
    $document_root = "${nginx_user_home}/html"
    file { $document_root:
      ensure => directory,
      owner  => $daemon_user,
    }
  }

  class { 'nginx':
    charset                  => $charset,
    charset_types            => $charset_types,
    client_body_timeout      => $client_body_timeout,
    client_header_timeout    => $client_header_timeout,
    client_max_body_size     => 0,
    conf_dir                 => $nginx_conf_dir,
    confd_only               => true,
    confd_purge              => true,
    daemon_group             => $daemon_group,
    daemon_user              => $daemon_user,
    default_type             => $default_type,
    etag                     => $etag,
    events_use               => $events_use,
    fastcgi_buffer_size      => $fastcgi_buffer_size,
    fastcgi_buffers          => $fastcgi_buffers,
    gzip                     => true,
    gzip_comp_level          => 5,
    gzip_http_version        => '1.0',
    gzip_min_length          => 256,
    gzip_proxied             => 'any',
    gzip_types               => $gzip_types,
    http_access_log          => $http_access_log,
    http_format_log          => $http_format_log,
    http_raw_prepend         => $http_raw_prepend,
    http_tcp_nodelay         => true,
    http_tcp_nopush          => true,
    index                    => $index,
    keepalive_timeout        => $keepalive_timeout,
    log_format               => $log_format,
    log_group                => $daemon_group,
    log_user                 => $daemon_user,
    manage_repo              => true,
    msie_padding             => false,
    multi_accept             => true,
    names_hash_bucket_size   => $names_hash_bucket_size,
    names_hash_max_size      => $names_hash_max_size,
    open_file_cache          => $open_file_cache,
    open_file_cache_min_uses => $open_file_cache_min_uses,
    open_file_cache_valid    => $open_file_cache_valid,
    package_ensure           => $package_ensure,
    package_name             => $nginx_package_name,
    package_source           => $package_source,
    pid                      => $nginx_pid_path,
    port_in_redirect         => $port_in_redirect,
    proxy_buffering          => $proxy_buffering,
    proxy_cache              => $proxy_cache,
    proxy_cache_key          => $proxy_cache_key,
    proxy_cache_path         => $proxy_cache_path,
    proxy_temp_path          => $proxy_temp_path,
    proxy_connection_upgrade => true,
    recursive_error_pages    => $recursive_error_pages,
    send_timeout             => $send_timeout,
    sendfile                 => true,
    server_purge             => $server_purge,
    server_tokens            => false,
    service_manage           => true,
    service_name             => $service_name,
    # http://nginx.org/en/docs/http/ngx_http_core_module.html#types_hash_max_size
    # http://nginx.org/en/docs/hash.html
    types_hash_max_size      => $types_hash_max_size,
    worker_connections       => 8192,
    yum_repo_sslverify       => $yum_repo_sslverify,
  }

  file{ '/etc/yum.repos.d/nginx-release.repo':
    mode => '0600',
  }

  # avoid conflict with DNF streams
  if $facts['os']['release']['major'] == '8' {
    Package <| title == 'nginx' |> {
      provider => 'dnf',
      install_options => ['--repo', 'nginx-release'],
    }
  }

  if $global_ssl_redirect {
    nginx::resource::server { 'default':
      listen_port           => 80,
      listen_options        => 'default_server',
      ipv6_enable           => true,
      ipv6_listen_options   => 'default_server',
      catch_all_server_name => true,
      ssl_redirect          => true,
      access_log            => absent,
      error_log             => absent,
    }
  }
}
