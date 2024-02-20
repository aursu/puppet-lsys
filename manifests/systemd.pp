# lsys::systemd
#
# systemd reload command
#
# @summary Provides Exec resource to reload systemd
#
# @example
#   include lsys::systemd
class lsys::systemd {
  contain bsys::systemctl::daemon_reload
}
