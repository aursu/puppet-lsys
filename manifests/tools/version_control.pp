# @summary VCS tools setup
#
# VCS tools setup
#
# @example
#   include lsys::tools::version_control
class lsys::tools::version_control {
  package { 'git':
    ensure => 'present',
  }
}
