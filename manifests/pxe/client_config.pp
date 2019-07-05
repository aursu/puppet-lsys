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
  Stdlib::Fqdn
          $hostname             = $name,
  Optional[Stdlib::Unixpath]
          $kernel               = undef,
  Optional[Stdlib::Unixpath]
          $initimg              = undef,

  # https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-disabling_consistent_network_device_naming
  # https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/
  Boolean $disable_biosdevname  = true,

  # Kickstart settings
  Boolean $centos               = true,
  Optional[Lsys::Pxe::Centos_version]
          $centos_version       = undef,
  Enum['x86_64', 'i386']
          $arch                 = 'x86_64',
  Optional[String]
          $kickstart_filename   = undef,
)
{
  include lsys::pxe::params
  $centos7_current_version = $lsys::pxe::params::centos7_current_version
  $centos6_current_version = $lsys::pxe::params::centos6_current_version

  if $centos and $centos_version {
    $major_version = $centos_version ? {
      /^6/ => 6,
      /^7/ => 7,
    }
  }
  else {
    $major_version = undef
  }

  if $kickstart_filename {
    $ks_filename = $kickstart_filename
  }
  elsif $centos_version {
    $ks_filename = "${centos_version}-${arch}" ? {
      '6-x86_64'                          => 'default-6-x86_64.cfg',
      "${centos6_current_version}-x86_64" => 'default-6-x86_64.cfg',
      '7-x86_64'                          => 'default.cfg',
      "${centos7_current_version}-x86_64" => 'default.cfg',
      default                             => "default-${centos_version}-${arch}",
    }
  }
  else {
    $ks_filename = 'default.cfg'
  }

  if $kernel {
    $boot_kernel = $kernel
  }
  elsif $centos and $major_version {
    $boot_kernel = "/var/lib/tftpboot/boot/centos/${major_version}/os/${arch}/images/pxeboot/vmlinuz"
  }
  else {
    $boot_kernel = undef
  }

  if $initimg {
    $boot_initimg = $initimg
  }
  elsif $centos and $major_version {
    $boot_initimg = "/var/lib/tftpboot/boot/centos/${major_version}/os/${arch}/images/pxeboot/initrd.img"
  }
  else {
    $boot_initimg = undef
  }

  # $hostname should match DHCP option host-name or the host declaration name
  # (if one) if use-host-decl-names is on
  file { "/var/lib/pxe/${hostname}.cfg":
    ensure  => file,
    content => template('lsys/pxe/host.cfg.erb'),
  }
}
