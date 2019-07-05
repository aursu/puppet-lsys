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
    $real_version = $centos_version ? {
      /^6/ => $centos6_current_version,
      /^7/ => $centos7_current_version,
    }
  }
  else {
    $real_version = undef
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
      default                             => "default-${centos_version}-${arch}.cfg",
    }
  }
  else {
    $ks_filename = 'default.cfg'
  }

  if $kernel {
    $boot_kernel = $kernel
  }
  elsif $centos and $real_version {
    $boot_kernel = "/var/lib/tftpboot/boot/centos/${real_version}/os/${arch}/images/pxeboot/vmlinuz"
  }
  else {
    $boot_kernel = undef
  }

  if $initimg {
    $boot_initimg = $initimg
  }
  elsif $centos and $real_version {
    $boot_initimg = "/var/lib/tftpboot/boot/centos/${real_version}/os/${arch}/images/pxeboot/initrd.img"
  }
  else {
    $boot_initimg = undef
  }

  # $hostname should match DHCP option host-name or the host declaration name
  # (if one) if use-host-decl-names is on
  file { "/var/lib/pxe/${hostname}.cfg":
    ensure  => file,
    content => template('lsys/pxe/host.cfg.erb'),
    notify  => Exec["/var/lib/tftpboot/boot/install/${hostname}.cfg"],
  }

  exec { "/var/lib/tftpboot/boot/install/${hostname}.cfg":
    command     => "rm -f /var/lib/tftpboot/boot/install/${hostname}.cfg",
    refreshonly => true,
    path        => '/usr/bin:/bin',
    onlyif      => "test -f /var/lib/tftpboot/boot/install/${hostname}.cfg",
  }
}
