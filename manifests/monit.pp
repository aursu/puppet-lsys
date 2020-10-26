# @summary Monit installation and setup
#
# Monit installation and setup
#
# @example
#   include lsys::monit
class lsys::monit (
  String  $download_version = $lsys::params::monit_version,
  Stdlib::Unixpath
          $binary_path      = $lsys::params::monit_binary_path,
) inherits lsys::params
{
  # e.g. https://mmonit.com/monit/dist/binary/5.27.1/monit-5.27.1-linux-x64.tar.gz
  $download_name    = "monit-${download_version}-linux-x64.tar.gz"
  $download_url     = "https://mmonit.com/monit/dist/binary/${download_version}/${download_name}"
  $checksum_url     = "${download_url}.sha256"
  $extracted_binary = "/usr/local/monit-${download_version}/bin/monit"

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

  file { 'monit':
    path      => $binary_path,
    ensure    => file,
    source    => "file://${extracted_binary}",
    mode      => '0755',
    owner     => 'root',
    group     => 'root',
    subscribe => Archive['monit'],
  }
}
