# Set of Yum repositories on Bintray with custom software
#
# @summary Set of Yum repositories on Bintray with custom software
#
# @example
#   include lsys::repo::bintray
class lsys::repo::bintray (
  Boolean $php5_enable  = false,
  Boolean $php71_enable = false,
  Boolean $php73_enable = false,
)
{
  include lsys::repo

  if $facts['os']['name'] in ['RedHat', 'CentOS'] and $facts['os']['release']['major'] in ['6', '7'] {
    yumrepo { 'bintray-custom':
      baseurl       => 'https://dl.bintray.com/aursu/custom/centos/$releasever/',
      descr         => 'PHP dependencies',
      enabled       => '0',
      gpgcheck      => '0',
      repo_gpgcheck => '0',
      sslverify     => '0',
      notify        => Exec['yum-reload-e0c99ff'],
    }

    if $php5_enable {
      yumrepo { 'bintray-php5custom':
        baseurl       => 'https://dl.bintray.com/aursu/php5custom/centos/$releasever/',
        descr         => 'PHP 5.6 packages and extensions',
        enabled       => '0',
        gpgcheck      => '0',
        repo_gpgcheck => '0',
        sslverify     => '0',
        notify        => Exec['yum-reload-e0c99ff'],
      }
    }

    if $php71_enable {
      yumrepo { 'bintray-php71custom':
        baseurl       => 'https://dl.bintray.com/aursu/php71custom/centos/$releasever/',
        descr         => 'PHP 7.1 packages and extensions',
        enabled       => '0',
        gpgcheck      => '0',
        repo_gpgcheck => '0',
        sslverify     => '0',
        notify        => Exec['yum-reload-e0c99ff'],
      }
    }

    if $php73_enable {
      yumrepo { 'bintray-php73custom':
        baseurl       => 'https://dl.bintray.com/aursu/php73custom/centos/$releasever/',
        descr         => 'PHP 7.3 packages and extensions',
        enabled       => '0',
        gpgcheck      => '0',
        repo_gpgcheck => '0',
        sslverify     => '0',
        notify        => Exec['yum-reload-e0c99ff'],
      }
    }
  }
}
