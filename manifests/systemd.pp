# system::systemd
#
# systemd management
#
# @summary Provides resources for basic systemd management
#
# @example
#   include system::systemd
class system::systemd {
    if ($::osfamily == 'RedHat' and versioncmp($::operatingsystemmajrelease, '7') == 0)
    or ($::operatingsystem == 'Fedora') {
        exec { 'reload-systemd':
            command => 'systemctl daemon-reload',
            path    => '/bin:/sbin:/usr/bin:/usr/sbin',
            refreshonly => true,
        }
    }
}
