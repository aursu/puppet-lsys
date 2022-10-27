# @summary Disable TCP wrappers
#
# Disable TCP wrappers
#
# @example
#   include lsys::hardening::tcp_wrappers::noop
class lsys::hardening::tcp_wrappers::noop {
  # https://access.redhat.com/solutions/3935901
  # - There is no tcp_wrappers package in RHEL8.
  # - tcp_wrappers has been replaced with firewalld.
  # - There is no reason why the /etc/hosts.{allow,deny} are provided by the
  #   default setup package.
  if  $facts['os']['name'] in ['RedHat', 'CentOS'] and
  $facts['os']['release']['major'] in ['6', '7'] {
    file {
      default:
        ensure => file,
        owner  => root,
        group  => root,
        mode   => '0644',
        ;
      '/etc/hosts.allow': content => file('lsys/hardening/hosts.allow');
      '/etc/hosts.deny':  content => file('lsys/hardening/hosts.deny');
    }
  }
}
