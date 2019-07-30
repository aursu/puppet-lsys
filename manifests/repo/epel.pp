# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include lsys::repo::epel
class lsys::repo::epel {

  include lsys::repo

  package { 'epel-release':
    ensure => 'present',
    notify => Exec['yum-reload-e0c99ff'],
  }
}
