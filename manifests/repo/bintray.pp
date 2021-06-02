# Set of Yum repositories on Bintray with custom software
#
# @summary Set of Yum repositories on Bintray with custom software
#
# @example
#   include lsys::repo::bintray
class lsys::repo::bintray (
  Boolean $php73_enable = false,
  Boolean $php74_enable = false,
  Boolean $php8_enable  = false,
)
{
  include lsys::repo

  if $facts['os']['name'] in ['RedHat', 'CentOS'] and $facts['os']['release']['major'] in ['6', '7', '8'] {
    yumrepo { 'bintray-custom':
      baseurl       => 'https://rpmb.jfrog.io/artifactory/custom/centos/$releasever/',
      descr         => 'PHP dependencies',
      enabled       => '0',
      gpgcheck      => '0',
      repo_gpgcheck => '0',
      sslverify     => '0',
      notify        => Class['lsys::repo'],
    }
    file { '/etc/yum.repos.d/bintray-custom.repo': }

    if $php73_enable {
      yumrepo { 'bintray-php73custom':
        baseurl       => 'https://rpmb.jfrog.io/artifactory/php73custom/centos/$releasever/',
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
        baseurl       => 'https://rpmb.jfrog.io/artifactory/php74custom/centos/$releasever/',
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
        baseurl       => 'https://rpmb.jfrog.io/artifactory/php8custom/centos/$releasever/',
        descr         => 'PHP 8.x packages and extensions',
        enabled       => '0',
        gpgcheck      => '0',
        repo_gpgcheck => '0',
        sslverify     => '0',
        notify        => Class['lsys::repo'],
      }
      file { '/etc/yum.repos.d/bintray-php8custom.repo': }
    }
  }
}
