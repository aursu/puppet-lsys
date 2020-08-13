# Yum cache cleanup
#
# @summary Resources for Yum cache cleanup
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
