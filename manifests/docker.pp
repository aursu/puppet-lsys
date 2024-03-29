# @summary Docker installation
#
# Docker installation
#
# @example
#   include lsys::docker
#
# @param repo_gpgcheck
#   This tells yum whether or not it should perform a GPG signature check on packages
#
# @param repo_sslverify
#   Should yum verify SSL certificates/hosts at all
#
# @param dockerd_version
#   Ability to setup exact version of Docker daemon
#
# @param daemon_enable
#   Whether to perform Docker daemon setup and start. Including TLS setup,
#   daemon configuration file setup, systemd settings and Docker Compose
#
# @param tls_users_access
#   Whether to allow access to Docker TLS assets to system users
#
class lsys::docker (
  Boolean $repo_gpgcheck = true,
  Boolean $repo_sslverify = true,
  Optional[String] $dockerd_version = undef,
  Boolean $daemon_enable = true,
  Boolean $tls_users_access = false,
) {
  include dockerinstall

  class { 'dockerinstall::repos':
    gpgcheck  => $repo_gpgcheck,
    sslverify => $repo_sslverify,
  }

  class { 'dockerinstall::profile::install':
    dockerd_version  => $dockerd_version,
    tls_users_access => $tls_users_access,
  }

  if $daemon_enable {
    class { 'dockerinstall::profile::daemon':
      tls_users_access => $tls_users_access,
    }
  }
}
