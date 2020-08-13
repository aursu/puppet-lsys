# lsys::systemd
#
# systemd reload command
#
# @summary Provides Exec resource to reload systemd
#
# @example
#   include lsys::systemd
class lsys::systemd {
  exec { 'systemd-reload':
    command     => 'systemctl daemon-reload',
    path        => '/bin:/sbin:/usr/bin:/usr/sbin',
    refreshonly => true,
  }
}
