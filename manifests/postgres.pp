# @summary PostgreSQL server installation
#
# PostgreSQL server installation
#
# @example
#   include lsys::postgres
class lsys::postgres (
    Boolean $manage_package_repo        = true,
    # https://www.postgresql.org/docs/11/pgupgrade.html
    Pattern[/([89]|1[0-2])(\.[0-9]+)+/]
            $package_version            = '12.4',
    String  $ip_mask_allow_all_users    = '0.0.0.0/0',
    String  $listen_addresses           = 'localhost',
    Variant[Integer, Pattern[/^[0-9]+$/]]
            $database_port              = 5432,
){
    if $manage_package_repo {
        class { 'postgresql::globals':
            manage_package_repo => $manage_package_repo,
            version             => $package_version,
        }
    }

    class { 'postgresql::server':
        ip_mask_allow_all_users => $ip_mask_allow_all_users,
        listen_addresses        => $listen_addresses,
        port                    => $database_port + 0,
    }

    class { 'postgresql::server::contrib': }
}
