# @summary Monit installation using pre-built binaries
#
# Monit installation using pre-built binaries
#
# @param version
#   - Monit version to download from https://mmonit.com/monit/dist/binary/
#
# @param binary_path
#   - installation path to install Monit binary to
#
# @example
#   include lsys::monit::prebuilt_binary
class lsys::monit::prebuilt_binary (
  String $version = $lsys::params::monit_version,
  Stdlib::Unixpath $binary_path = $lsys::params::monit_binary_path,
  Boolean $manage_dependencies = true,
) inherits lsys::params {
  # e.g. https://mmonit.com/monit/dist/binary/5.32.0/monit-5.32.0-linux-x64.tar.gz
  $download_name    = "monit-${version}-linux-x64.tar.gz"
  $download_url     = "https://mmonit.com/monit/dist/binary/${version}/${download_name}"
  $checksum_url     = "${download_url}.sha256"
  $extracted_binary = "/usr/local/monit-${version}/bin/monit"

  $osfam = $lsys::params::osfam
  $osmaj = $lsys::params::osmaj

  if $manage_dependencies {
    if $osfam == 'RedHat' and $osmaj == '8' {
      package { 'libnsl': ensure => 'installed' }
    }
  }

  archive { 'monit':
    ensure        => present,
    path          => "/usr/local/${download_name}",
    extract       => true,
    extract_path  => '/usr/local',
    source        => $download_url,
    checksum_url  => $checksum_url,
    checksum_type => 'sha256',
    creates       => $extracted_binary,
    cleanup       => true,
  }

  file { 'monit_binary':
    ensure    => file,
    path      => $binary_path,
    source    => "file://${extracted_binary}",
    mode      => '0755',
    owner     => 'root',
    group     => 'root',
    subscribe => Archive['monit'],
  }
}
