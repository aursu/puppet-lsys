# @summary Google Chrome repo
#
# Google Chrome repo
#
# @example
#   include lsys::repo::google_chrome
class lsys::repo::google_chrome {
  case $facts['os']['name'] {
    'RedHat', 'CentOS': {
      yumrepo { 'google-chrome':
        ensure   => 'present',
        descr    => 'google-chrome',
        baseurl  => 'http://dl.google.com/linux/chrome/rpm/stable/x86_64',
        enabled  => '1',
        gpgcheck => '1',
        gpgkey   => 'https://dl.google.com/linux/linux_signing_key.pub',
      }

      file { '/etc/yum.repos.d/google-chrome.repo':
        mode => '0640',
      }

      $key_package_name = 'gpg-pubkey-d38b4796-570c8cd3'
      $google_gpg_key = "/etc/pki/rpm-gpg/${key_package_name}"

      file { $google_gpg_key:
        content => file("lsys/repo/${key_package_name}"),
      }

      exec { "rpm --import ${google_gpg_key}":
        path    => '/bin:/usr/bin',
        unless  => "rpm -q ${key_package_name}",
        onlyif  => "test -f ${google_gpg_key}",
        require => File[$google_gpg_key],
      }
    }
    default: {}
  }
}
