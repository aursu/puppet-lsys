# @summary Allow to use crontabs to specified user
#
# Running cron jobs can be allowed or disallowed for different users. For this
# purpose, use the cron.allow and cron.deny files. If the cron.allow file
# exists, a user must be listed in it to be allowed to use cron. If the
# cron.allow file does not exist but the cron.deny file does exist, then a user
# must not be listed in the cron.deny file in order to use cron. If neither of
# these files exists, only the super user is allowed to use cron.
#
# @example
#   include lsys::hardening::cron
#
# @param users_allow
#
class lsys::hardening::cron (
  Array[String] $users_allow = ['root'],
) {
  $content = join($users_allow, "\n")

  file { '/etc/cron.allow':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0640',
    content => "${content}\n",
  }

  file { '/etc/cron.deny':
    ensure => absent,
  }
}
