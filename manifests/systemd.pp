# lsys::systemd
#
# systemd resources
#
# @summary Provides resources for basic systemd management
#
# @example
#   include system::systemd
class lsys::systemd {
    if ($::osfamily == 'RedHat' and versioncmp($::operatingsystemmajrelease, '7') == 0)
    or ($::operatingsystem == 'Fedora') {
        exec { 'systemd-reload':
            command => 'systemctl daemon-reload',
            path    => '/bin:/sbin:/usr/bin:/usr/sbin',
            refreshonly => true,
        }
    }
}
