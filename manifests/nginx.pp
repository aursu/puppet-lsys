# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include lsys::nginx
class lsys::nginx  (
  String  $package_ensure        = '1.17.0-1.el7.ngx',
  Boolean $manage_user           = true,
  Boolean $manage_user_home      = false,
  String  $daemon_user           = 'www-data',
  Integer $daemon_user_id         = 33,
  String  $daemon_group          = 'www-data',
  Integer $daemon_group_id        = 33,
  Optional[String]
          $proxy_cache           = undef,
  Optional[Hash]
          $proxy_cache_path      = undef,
  Stdlib::Unixpath
          $web_server_user_home  = '/var/lib/nginx',
  Stdlib::Unixpath
          $web_server_user_shell = '/sbin/nologin',
  Optional[String]
          $nginx_log_directory   = undef,
  Variant[
      String,
      Array[String]
  ]       $http_raw_prepend      = [],
  Optional[Stdlib::Unixpath]
          $nginx_lib_directory   = undef,
  Boolean $manage_document_root  = true,
  Boolean $global_ssl_redirect   = false,
)
{
    if $manage_user {
      group { $daemon_group:
        ensure    => present,
        gid       => $daemon_group_id,
        allowdupe => true,
      }

      user { $daemon_user:
        ensure    => present,
        uid       => $daemon_user_id,
        allowdupe => true,
        gid       => $daemon_group,
        home      => $web_server_user_home,
        shell     => $web_server_user_shell,
        require   => Group[$daemon_group],
      }

      if $manage_user_home {
        file { $web_server_user_home:
          ensure => directory,
          owner  => $daemon_user,
          group  => $daemon_group,
        }
      }

      User[$daemon_user] -> Class['nginx']
    }

    if $nginx_lib_directory {
      $lib_directories = [
        $nginx_lib_directory,
        "${nginx_lib_directory}/tmp"
      ]

      file { $lib_directories:
        ensure => directory,
        owner  => $daemon_user,
        mode   => '0700',
      }
    }

    if $nginx_log_directory {
      file { $nginx_log_directory:
        ensure  => directory,
        group   => $daemon_group,
        owner   => $daemon_user,
        seltype => 'httpd_log_t',
        recurse => true,
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
        $document_root = "${web_server_user_home}/html"
        file { $document_root:
            ensure => directory,
            owner  => $daemon_user,
        }
    }

    class { 'nginx':
        package_ensure           => $package_ensure,
        manage_repo              => true,
        package_source           => 'nginx-mainline',
        service_manage           => true,
        confd_only               => true,
        server_purge             => true,
        confd_purge              => true,
        daemon_user              => $daemon_user,
        daemon_group             => $daemon_group,
        worker_connections       => 8192,
        multi_accept             => true,
        names_hash_bucket_size   => 64,
        sendfile                 => true,
        server_tokens            => false,
        http_tcp_nopush          => true,
        http_tcp_nodelay         => true,
        keepalive_timeout        => 65,
        gzip                     => true,
        gzip_http_version        => '1.0',
        gzip_comp_level          => 2,
        gzip_proxied             => 'any',
        gzip_types               => [
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
        proxy_connection_upgrade => true,
        proxy_cache              => $proxy_cache,
        proxy_cache_path         => $proxy_cache_path,
        http_access_log          => [],
        http_raw_prepend         => $http_raw_prepend,
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
