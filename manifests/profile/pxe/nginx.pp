# Basic Nginx setup to proxy requests to Apache
#
# @summary Basic Nginx setup to proxy requests to Apache
#
# @example
#   class { 'lsys::profile::pxe::nginx":
#     server_name => 'install.domain.tld',
#     resolver    => ['192.168.1.1', '8.8.8.8', '1.1.1.1'],
#   }
class lsys::profile::pxe::nginx (
  Stdlib::Fqdn
          $server_name,
  Array[Stdlib::IP::Address]
          $resolver,
)
{
  $location_proxy_handler = {
    proxy_set_header  => [
      'Host $host',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
    ],
    proxy_pass_header => [
      'Server'
    ],
    proxy             => "http://\$server_addr:8080",  # lint:ignore:variables_not_enclosed
  }

  nginx::resource::server { 'pxe':
    server_name => [ $server_name ],

    error_log   => '/var/log/nginx/pxe.error_log info',
    access_log  => {
      '/var/log/nginx/pxe.access_log' => 'combined',
    },

    resolver    => $resolver,

    locations   => {
      'pxe-default' => { location  => '/' } + $location_proxy_handler,
    }
  }
}
