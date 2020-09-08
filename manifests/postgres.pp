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
  Pattern[/([89]|1[0-2])(\.[0-9]+)+/]
          $package_version            = '12.4',
  String  $ip_mask_allow_all_users    = '0.0.0.0/0',
  String  $listen_addresses           = 'localhost',
  Variant[Integer, Pattern[/^[0-9]+$/]]
          $database_port              = 5432,
  Optional[Integer[0,1]]
          $repo_sslverify             = undef,
){
  if $manage_package_repo {
    class { 'postgresql::globals':
      manage_package_repo => $manage_package_repo,
      version             => $package_version,
    }

    if $repo_sslverify {
      Yumrepo <| title == 'yum.postgresql.org' |> {
        sslverify => $repo_sslverify,
      }
    }
  }

  class { 'postgresql::server':
    ip_mask_allow_all_users => $ip_mask_allow_all_users,
    listen_addresses        => $listen_addresses,
    port                    => $database_port + 0,
  }

  class { 'postgresql::server::contrib': }
}