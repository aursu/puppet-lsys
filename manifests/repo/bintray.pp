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
  Boolean $php74_enable = false,
  Boolean $php8_enable = false,
)
{
  include lsys::repo

  if $facts['os']['name'] in ['RedHat', 'CentOS'] and $facts['os']['release']['major'] in ['6', '7', '8'] {
    yumrepo { 'bintray-custom':
      baseurl       => 'https://dl.bintray.com/aursu/custom/centos/$releasever/',
      descr         => 'PHP dependencies',
      enabled       => '0',
      gpgcheck      => '0',
      repo_gpgcheck => '0',
      sslverify     => '0',
      notify        => Class['lsys::repo'],
    }
    file { '/etc/yum.repos.d/bintray-custom.repo': }

    if $php5_enable {
      yumrepo { 'bintray-php5custom':
        baseurl       => 'https://dl.bintray.com/aursu/php5custom/centos/$releasever/',
        descr         => 'PHP 5.6 packages and extensions',
        enabled       => '0',
        gpgcheck      => '0',
        repo_gpgcheck => '0',
        sslverify     => '0',
        notify        => Class['lsys::repo'],
      }
      file { '/etc/yum.repos.d/bintray-php5custom.repo': }
    }

    if $php71_enable {
      yumrepo { 'bintray-php71custom':
        baseurl       => 'https://dl.bintray.com/aursu/php71custom/centos/$releasever/',
        descr         => 'PHP 7.1 packages and extensions',
        enabled       => '0',
        gpgcheck      => '0',
        repo_gpgcheck => '0',
        sslverify     => '0',
        notify        => Class['lsys::repo'],
      }
      file { '/etc/yum.repos.d/bintray-php71custom.repo': }
    }

    if $php73_enable {
      yumrepo { 'bintray-php73custom':
        baseurl       => 'https://dl.bintray.com/aursu/php73custom/centos/$releasever/',
        descr         => 'PHP 7.3 packages and extensions',
        enabled       => '0',
        gpgcheck      => '0',
        repo_gpgcheck => '0',
        sslverify     => '0',
        notify        => Class['lsys::repo'],
      }
      file { '/etc/yum.repos.d/bintray-php73custom.repo': }
    }

    if $php74_enable {
      yumrepo { 'bintray-php74custom':
        baseurl       => 'https://dl.bintray.com/aursu/php74custom/centos/$releasever/',
        descr         => 'PHP 7.4 packages and extensions',
        enabled       => '0',
        gpgcheck      => '0',
        repo_gpgcheck => '0',
        sslverify     => '0',
        notify        => Class['lsys::repo'],
      }
      file { '/etc/yum.repos.d/bintray-php74custom.repo': }
    }

    if $php8_enable {
      yumrepo { 'bintray-php8custom':
        baseurl       => 'https://dl.bintray.com/aursu/php8custom/centos/$releasever/',
        descr         => 'PHP 8.x packages and extensions',
        enabled       => '0',
        gpgcheck      => '0',
        repo_gpgcheck => '0',
        sslverify     => '0',
        notify        => Class['lsys::repo'],
        file { '/etc/yum.repos.d/bintray-php8custom.repo': }
      }
    }
  }
}
