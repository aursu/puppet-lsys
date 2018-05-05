# lsys::systemd
#
# systemd resources
#
# @summary Provides resources for basic systemd management
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
