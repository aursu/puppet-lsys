# puppet-lsys
Different Puppet helpers (custom types, defined types, facts, profiles etc)

## Nginx core

```
include lsys::nginx
```

## Apache core

```
include lsys::httpd
```

## Yum cache cleanup

Via notify event send to Class['lsys::repo']

```
  package { 'epel-release':
    ensure => 'present',
    notify => Class['lsys::repo'],
  }
```

## Keycloak

Single-node Keycloak on loopback behind a local reverse proxy, PostgreSQL on
the same host (declare `lsys_postgresql` on the node). The release archive is
verified against a mandatory SHA-256 before the keycloak module unpacks it.

```
include lsys_postgresql

class { 'lsys::keycloak':
  archive_sha256 => '<sha256 of keycloak-26.8.2.tar.gz>',
  hostname       => 'https://sso.example.com',
  admin_password => Sensitive('...'),
  db_password    => Sensitive('...'),
}
```
