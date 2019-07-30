# Resources for Yum repository management
#
# @summary Resources for Yum repository management
#
# @example
#   include lsys::repo
class lsys::repo {
  exec { 'yum-reload-e0c99ff':
    command     => 'yum clean all',
    path        => '/bin:/usr/bin',
    refreshonly => true,
  }
}
