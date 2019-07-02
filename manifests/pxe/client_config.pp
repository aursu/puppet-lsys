# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   lsys::pxe::client_config { 'namevar': }
define lsys::pxe::client_config(
  # https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/installation_guide/sect-kickstart-howto
  Stdlib::Fqdn
          $install_server,
  String  $kickstart_filename   = 'default.cfg',
  Stdlib::Fqdn
          $hostname             = $name,
  Optional[Stdlib::Unixpath]
          $kernel               = undef,
  Optional[Stdlib::Unixpath]
          $initimg              = undef,
  # https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-disabling_consistent_network_device_naming
  # https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/
  Boolean $disable_biosdevname  = true,
  Boolean $use_dhcp             = true,
)
{
  # $hostname should match DHCP option host-name or the host declaration name
  # (if one) if use-host-decl-names is on
  file { "/var/lib/pxe/${hostname}.cfg":
    ensure  => file,
    content => template('lsys/pxe/host.cfg.erb'),
  }
}
