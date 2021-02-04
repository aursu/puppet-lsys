# @summary Setup permissions on directory
#
# Setup permissions on directory
#
# @example
#   lsys::hardening::chmod_directory { 'namevar': }
define lsys::hardening::chmod_directory (
  Stdlib::Unixpath
          $path = $name,
  Lsys::FileMode
          $mode,
){
  exec { "chmod ${mode} ${path}":
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    onlyif  => "test -d ${path}",
    unless  => "stat ${path} -c %04a | grep ${mode}",
  }
}
