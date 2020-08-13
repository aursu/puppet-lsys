# @summary Local system parameters
#
# Local system parameters
#
# @example
#   include lsys::params
class lsys::params {
  include lsys::webserver::params

  $nginx_libdir          = '/var/lib/nginx'
  $nginx_cachedir        = '/var/cache/nginx'
  $nginx_proxy_temp_path = "${nginx_cachedir}/proxy_temp"
  $nginx_user_home       = '/var/lib/nginx'

  $nginx_version = $facts['os']['release']['major'] ? {
    '6'     => '1.19.0-1.el6.ngx',
    '8'     => '1.19.0-1.el8.ngx',
    default => '1.19.0-1.el7.ngx',
  }
}