# @summary Setup permissions on directory
#
# Setup permissions on directory
#
# @example
#   lsys::hardening::chmod_directory { 'namevar': }
#
# @param mode
# @param path
#
define lsys::hardening::chmod_directory (
  Lsys::FileMode $mode,
  Stdlib::Unixpath $path = $name,
) {
  exec { "chmod ${mode} ${path}":
    path   => '/usr/bin:/usr/sbin:/bin:/sbin',
    onlyif => "test -d ${path}",
    unless => "stat ${path} -c %04a | grep ${mode}",
  }
}
