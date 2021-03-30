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
  Boolean $manage_package_repo        = true,
  # https://www.postgresql.org/docs/11/pgupgrade.html
  Lsys::PGVersion
          $package_version            = '12.5',
  String  $ip_mask_allow_all_users    = '0.0.0.0/0',
  String  $listen_addresses           = 'localhost',
  Variant[Integer, Pattern[/^[0-9]+$/]]
          $database_port              = 5432,
  Optional[Integer[0,1]]
          $repo_sslverify             = undef,
){

  $version_data = split($package_version, '[.]')
  $major_version = $version_data[0]
  $minor_version = $version_data[1]

  $repo_version = $major_version ? {
    '9' => $minor_version ? {
      default => "9.${minor_version}",
    },
    default => $major_version,
  }

  $manage_dnf_module = $facts['os']['name'] ? {
    'CentOS' => $facts['os']['release']['major'] ? {
      '7'     => false,
      default => true,
    }
  }

  # CentOS 8 provides modules postgresql:10, postgresql:12 and postgresql:9.6
  if $manage_dnf_module and $repo_version in ['10', '12', '9.6'] {
    package { 'postgresql dnf module':
      ensure      => $repo_version,
      name        => 'postgresql',
      enable_only => true,
      provider    => 'dnfmodule',
    }
  }

  class { 'postgresql::globals':
    manage_package_repo => $manage_package_repo,
    version             => $repo_version,
  }

  if $manage_package_repo {
    if $repo_sslverify {
      Yumrepo <| title == 'yum.postgresql.org' |> {
        sslverify => $repo_sslverify,
      }
    }

    file { '/etc/yum.repos.d/yum.postgresql.org.repo':
      mode => '0600',
    }

    include lsys::repo
    Yumrepo['yum.postgresql.org'] ~> Class['lsys::repo']
  }

  class { 'postgresql::server':
    package_ensure          => $package_version,
    ip_mask_allow_all_users => $ip_mask_allow_all_users,
    listen_addresses        => $listen_addresses,
    port                    => $database_port + 0,
  }

  class { 'postgresql::server::contrib': }
}
