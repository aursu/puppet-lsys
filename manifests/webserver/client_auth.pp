# @summary Enables verification of client certificates
#
# Setup certificates in predefined location
# Provides 2 variables 
#
# @param ssl_client_ca_certs
#   list of certificates' lookup keys to look for in Hiera
#   It will look for these keys with suffix '_certificate'
#
# @example
#   include lsys::webserver::client_auth
class lsys::webserver::client_auth (
  Optional[Array[Stdlib::Fqdn]] $ssl_client_ca_certs = undef,
) {
  include puppet::params
  include lsys::webserver::params

  $localcacert = $puppet::params::localcacert
  $internal_certdir = $lsys::webserver::params::internal_certdir
  $internal_cacert  = $lsys::webserver::params::internal_cacert

  # CA certificate
  # create CA certificate directory
  file { $internal_certdir:
    ensure => directory,
  }

  if $ssl_client_ca_certs {
    $cacertdata = $ssl_client_ca_certs.map |$ca_name| { tlsinfo::lookup($ca_name) }

    file { $internal_cacert:
      ensure  => file,
      content => $cacertdata.join("\n"),
    }
  }
  else {
    file { $internal_cacert:
      ensure => file,
      source => "file://${localcacert}",
    }
  }

  $ssl_cert = $internal_cacert
  # rule to deny non-authenticated users
  $ssl_check = [
    file('lsys/nginx/chunks/enable-client-auth.conf'),
  ]
}
