# @summary Rsyslog upstream repo
#
# Rsyslog upstream repo
# https://www.rsyslog.com/rhelcentos-rpms/
#
# @example
#   include lsys::repo::rsyslog
class lsys::repo::rsyslog {
  include lsys::repo

  case $facts['os']['name'] {
    'RedHat', 'CentOS', 'Rocky': {
      yumrepo { 'rsyslog_v8':
        ensure    => 'present',
        descr     => 'Adiscon CentOS-$releasever - local packages for $basearch',
        baseurl   => 'http://rpms.adiscon.com/v8-stable/epel-$releasever/$basearch',
        enabled   => '0',
        gpgcheck  => '1',
        gpgkey    => 'https://rpms.adiscon.com/RPM-GPG-KEY-Adiscon',
        sslverify => '0',
        notify    => Class['lsys::repo'],
      }

      file { '/etc/yum.repos.d/rsyslog_v8.repo':
        mode => '0640',
      }

      $key_package_name = 'gpg-pubkey-e00b8985-512dde96'
      $rsyslog_gpg_key = '/etc/pki/rpm-gpg/RPM-GPG-KEY-Adiscon'

      file { $rsyslog_gpg_key:
        content => file('lsys/repo/RPM-GPG-KEY-Adiscon'),
      }

      exec { "rpm --import ${rsyslog_gpg_key}":
        path    => '/bin:/usr/bin',
        unless  => "rpm -q ${key_package_name}",
        onlyif  => "test -f ${rsyslog_gpg_key}",
        require => File[$rsyslog_gpg_key],
      }
    }
    default: {}
  }
}
