# @summary PostgreSQL server installation
#
# PostgreSQL server installation
#
# @example
#   include lsys::postgres
#
# @param ip_mask_allow_all_users
#   Overrides PostgreSQL defaults for remote connections. By default, PostgreSQL
#   does not allow database user accounts to connect via TCP from remote
#   machines. If you'd like to allow this, you can override this setting. Set to
#   '0.0.0.0/0' to allow database users to connect from any remote machine, or
#   '192.168.0.0/1' to allow connections from any machine on your local '192.168'
#   subnet. Default value: '127.0.0.1/32'.
#
class lsys::postgres (
  Boolean $manage_dnf_module = true,
  Boolean $manage_package_repo = $lsys::params::postgres_manage_repo,
  # https://www.postgresql.org/docs/11/pgupgrade.html
  Lsys::PGVersion $package_version = $lsys::params::postgres_version,
  String $ip_mask_allow_all_users = '0.0.0.0/0',
  String $listen_addresses = 'localhost',
  Variant[Integer, Pattern[/^[0-9]+$/]] $database_port = 5432,
  Optional[Integer[0,1]] $repo_sslverify = undef,
) inherits lsys::params {
  include bsys::params
  include lsys::repo

  if $package_version {
    $version_data = split($package_version, '[.]')
    $major_version = $version_data[0]
    $minor_version = $version_data[1]

    $repo_version = $major_version ? {
      '9' => $minor_version ? {
        default => "9.${minor_version}",
      },
      default => $major_version,
    }
  }
  else {
    $repo_version = undef
  }

  # we can not use maintainer's repo on CentOS 8+ due to issue:
  # All matches were filtered out by modular filtering for argument
  # Therefore we use postgresql:12 dnf module stream
  $_manage_dnf_module = $bsys::params::osfam ? {
    'RedHat' => $bsys::params::manage_dnf_module,
    default => false,
  }

  # if DNF system and we want to manage DNF module it and it is manageable
  if $_manage_dnf_module and $manage_dnf_module {
    class { 'postgresql::globals':
      manage_package_repo => $manage_package_repo,
      manage_dnf_module   => true,
      version             => $repo_version,
      service_provider    => 'systemd',
    }
  }
  else {
    class { 'postgresql::globals':
      manage_package_repo => $manage_package_repo,
      version             => $repo_version,
      service_provider    => 'systemd',
    }
  }

  if $manage_package_repo {
    if $repo_sslverify {
      Yumrepo <| title == 'yum.postgresql.org' |> {
        sslverify => $repo_sslverify,
      }

      Yumrepo <| title == 'pgdg-common' |> {
        sslverify => $repo_sslverify,
      }
    }

    file {
      default: mode => '0600';
      '/etc/yum.repos.d/yum.postgresql.org.repo': ;
      '/etc/yum.repos.d/pgdg-common.repo': ;
    }

    case $facts['os']['family'] {
      'RedHat': {
        Class['postgresql::repo::yum_postgresql_org'] ~> Class['lsys::repo']
      }
      'Debian': {
        Class['postgresql::repo::apt_postgresql_org'] ~> Class['lsys::repo']
      }
      default: {}
    }
  }
  else {
    # remove unmanaged repositories
    file {
      default:
        ensure => 'absent',
        notify => Class['lsys::repo'],
        ;
      '/etc/yum.repos.d/yum.postgresql.org.repo': ;
      '/etc/yum.repos.d/pgdg-common.repo': ;
    }
  }

  class { 'postgresql::server':
    package_ensure          => $package_version,
    ip_mask_allow_all_users => $ip_mask_allow_all_users,
    listen_addresses        => $listen_addresses,
    port                    => $database_port + 0,
  }

  class { 'postgresql::server::contrib': }
}
