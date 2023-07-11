# @summary Web server parameters on local system
#
# Web server parameters on local system
#
# @example
#   include lsys::webserver::params
class lsys::webserver::params {
  # use directory defined by http://nginx.org/packages/
  $user_shell = $facts['os']['family'] ? {
    'RedHat' => '/sbin/nologin',
    default  => '/usr/sbin/nologin',
  }
  $user_home = '/var/www'

  # Try to use static Uid/Gid (official for RedHat is apache/48 and for
  # Debian is www-data/33)
  $user_id = $facts['os']['family'] ? {
    'RedHat' => 48,
    default  => 33,
  }

  $user = $facts['os']['family'] ? {
    'RedHat' => 'apache',
    default  => 'www-data',
  }

  $group_id = $user_id
  $group = $user

  $ssl_settings = {
    'ssl'                         => true,
    'http2'                       => true,
    'ssl_session_timeout'         => '1d',
    'ssl_cache'                   => 'shared:SSL:50m',
    'ssl_session_tickets'         => false,
    'ssl_protocols'               => 'TLSv1.2 TLSv1.3',
    'ssl_ciphers'                 => 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384', # lint:ignore:140chars
    'ssl_prefer_server_ciphers'   => false,
    'ssl_stapling'                => true,
    'ssl_stapling_verify'         => true,
    'ssl_add_header'              => {
      'Strict-Transport-Security' => 'max-age=63072000',
    },
  }
}
