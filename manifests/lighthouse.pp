# @summary Google Lighthouse
#
# Google Lighthouse
# https://developers.google.com/web/tools/lighthouse#cli
#
# @example
#   include lsys::lighthouse
class lsys::lighthouse {
  include lsys::tools::google_chrome
  include lsys::nodejs

  package { 'lighthouse':
    ensure   => 'present',
    provider => 'npm',
  }

  # lsys::nodejs -> nodejs -> nodejs::install
  Class['nodejs::install'] -> Package['lighthouse']
}
