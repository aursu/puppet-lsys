# dhcpd.conf group declaration
#
# @summary dhcpd.conf group declaration
#
# @example
#   lsys::dhcp::group { 'namevar': }
#
# @param host_decl_names
#   Whether to add dhcpd parameter 'use-host-decl-names on' into group. Valid
#   values are `true`, `false`. Default to `false`.
#   See "The use-host-decl-names statement" on
#   https://kb.isc.org/docs/isc-dhcp-41-manual-pages-dhcpdconf
#
# @param pxe_settings
#   Whether to enable DHCPD PXE settings for group. Valid values are `true`,
#   `false`. Default to `false`.
#
# @param next_server
#   Whether to add dhcp parameter "next-server" into group PXE setings. Default
#   to undef. See "The next-server statement" on
#   https://kb.isc.org/docs/isc-dhcp-41-manual-pages-dhcpdconf
#
# @param tftp_server_name
#   If set to true will add DHCP option "tftp-server-name" additionally to
#   parameter "next-server". It depends on parameter next_server above
#   See "option tftp-server-name" on
#   https://kb.isc.org/docs/isc-dhcp-44-manual-pages-dhcp-options
#
# @param pxe_filename
#
#   Whether to add dhcp parameter "filename" into group PXE setings.
#   See "The filename statement" on
#   https://kb.isc.org/docs/isc-dhcp-41-manual-pages-dhcpdconf
#
define lsys::dhcp::group(
  Boolean $host_decl_names  = false,
  Boolean $pxe_settings     = false,
  Optional[Stdlib::Host]
          $next_server      = undef,
  Boolean $tftp_server_name = true,
  Optional[String]
          $pxe_filename     = undef,
  Optional[String]
          $comment          = undef,
  Hash[
    Stdlib::Host,
    Lsys::Dhcp::Host
  ]       $host             = {},
)
{
  include dhcp::params

  $dhcp_dir = $dhcp::params::dhcp_dir

  concat::fragment { "dhcp_group_${name}":
    target  => "${dhcp_dir}/dhcpd.hosts",
    content => template('lsys/dhcp/dhcpd.group.erb'),
    order   => '20',
  }
}
