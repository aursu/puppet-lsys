# PXE environment parameters
#
# @summary PXE environment parameters
#
# @example
#   include lsys::pxe::params
class lsys::pxe::params {
  $storage_directory = lookup('lsys::pxe::params::storage_directory', Stdlib::Unixpath, 'first', '/diskless')

  $centos6_current_version = '6.10'
  $centos7_current_version = '7.6.1810'
}
