# EPEL Yum repository installation
#
# @summary EPEL Yum repository installation
#
# @example
#   include lsys::repo::epel
class lsys::repo::epel {

  include lsys::repo

  package { 'epel-release':
    ensure => 'present',
    notify => Class['lsys::repo'],
  }
}
