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
