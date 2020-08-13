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
}
