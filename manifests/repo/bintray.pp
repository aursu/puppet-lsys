# Set of Yum repositories on Bintray with custom software
#
# @summary Set of Yum repositories on Bintray with custom software
#
# @example
#   include lsys::repo::bintray
class lsys::repo::bintray (
  Boolean $php82_enable = false,
  Boolean $php83_enable  = false,
) {
  include lsys::repo

  if $facts['os']['family'] == 'RedHat' and $facts['os']['release']['major'] in ['8', '9'] {
    $ospath = $facts['os']['name'] ? {
      'Rocky' => 'rocky',
      default => 'centos'
    }

    yumrepo { 'bintray-custom':
      baseurl       => "https://rpmb.jfrog.io/artifactory/custom/${ospath}/\$releasever/",
      descr         => 'PHP dependencies',
      enabled       => '0',
      gpgcheck      => '0',
      repo_gpgcheck => '0',
      sslverify     => '0',
      notify        => Class['lsys::repo'],
    }
    file { '/etc/yum.repos.d/bintray-custom.repo': }

    if $php82_enable {
      yumrepo { 'bintray-php82custom':
        baseurl       => "https://rpmb.jfrog.io/artifactory/php82custom/${ospath}/\$releasever/",
        descr         => 'PHP 8.2 packages and extensions',
        enabled       => '0',
        gpgcheck      => '0',
        repo_gpgcheck => '0',
        sslverify     => '0',
        notify        => Class['lsys::repo'],
      }
      file { '/etc/yum.repos.d/bintray-php82custom.repo': }
    }

    if $php83_enable {
      yumrepo { 'bintray-php83custom':
        baseurl       => "https://rpmb.jfrog.io/artifactory/php83custom/${ospath}/\$releasever/",
        descr         => 'PHP 8.3 packages and extensions',
        enabled       => '0',
        gpgcheck      => '0',
        repo_gpgcheck => '0',
        sslverify     => '0',
        notify        => Class['lsys::repo'],
      }
      file { '/etc/yum.repos.d/bintray-php83custom.repo': }
    }
  }
}
