# Apache Web server installation and basic configuration
#
# @summary A short summary of the purpose of this class
#
# @example
#   include lsys::httpd
class lsys::httpd (
  Stdlib::Port
          $listen_port = 80,
  String  $servername  = 'localhost',
)
{
    class { 'apache':
        apache_version         => '2.4',
        mpm_module             => false,
        default_mods           => [],
        use_systemd            => true,
        default_vhost          => false,
        default_ssl_vhost      => false,
        server_signature       => 'Off',
        trace_enable           => 'Off',
        servername             => $servername,
        timeout                => 60,
        keepalive              => 'On',
        max_keepalive_requests => 100,
        keepalive_timeout      => 5,
        root_directory_secured => true,
        docroot                => '/var/www/html',
        default_charset        => 'UTF-8',
        conf_template          => 'lsys/httpd.conf.erb',
        mime_types_additional  => undef,
        service_restart        => true,
    }

    class { 'apache::mod::prefork':
        startservers        => '5',
        minspareservers     => '5',
        maxspareservers     => '10',
        serverlimit         => '256',
        maxclients          => '256',
        maxrequestsperchild => '0',
        notify              => Class['Apache::Service'],
    }

    apache::listen { "${listen_port}": # lint:ignore:only_variable_string
        notify  => Class['Apache::Service'],
    }

    # apache::mod::mime included by SSL module
    class { 'apache::mod::ssl':
        ssl_compression            => false,
        ssl_cipher                 => 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256', # lint:ignore:140chars
        ssl_protocol               => [ 'all', '-SSLv3', '-TLSv1', '-TLSv1.1' ],
        ssl_random_seed_bytes      => '1024',
        ssl_mutex                  => 'default',
        ssl_stapling               => true,
        ssl_stapling_return_errors => false,
        notify                     => Class['Apache::Service'],
    }

    class { 'apache::mod::dir':
        indexes => [ 'index.html' ],
        notify  => Class['Apache::Service'],
    }

    class { 'apache::mod::mime_magic':
        magic_file => 'conf/magic',
        notify     => Class['Apache::Service'],
    }

    include apache::mod::headers
    include apache::mod::rewrite
    include apache::mod::alias
}
