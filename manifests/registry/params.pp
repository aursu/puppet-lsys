# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include lsys::registry::params
class lsys::registry::params {
    include tlsinfo::params

    # use directory defined by http://nginx.org/packages/
    $web_server_user_shell = $facts['os']['family'] ? {
        'RedHat' => '/sbin/nologin',
        default  => '/usr/sbin/nologin',
    }
    $web_server_user_home = '/var/lib/nginx'

    # Try to use static Uid/Gid (official for RedHat is apache/48 and for
    # Debian is www-data/33)
    $web_server_user_id = $facts['os']['family'] ? {
        'RedHat' => 48,
        default  => 33,
    }

    $web_server_user = $facts['os']['family'] ? {
        'RedHat' => 'apache',
        default  => 'www-data',
    }

    $web_server_group_id = $web_server_user_id
    $web_server_group = $web_server_user

    # we use default settings defined by Docker Registry v2 project
    # it is port 5000 for registry service on localhost
    $nginx_upstream_members = {
        'localhost:5000' => {
            server => 'localhost',
            port   => 5000,
        }
    }

    # we use Docker Compose to start registry
    # Docker registyr service is Dockerinstall::Composeservice
    # resource title (<project>/<service name>)
    # <service name> is Docker compose service and must be present inside
    # docker-compose.yaml configuration file
    $registry_compose_service = 'registry/registry'

    # data directory
    # this reflectded in docker compose file files/services/registry.yaml
    $data_directory = '/var/lib/registry'

    # Client authentication
    $internal_certdir = "${tlsinfo::params::certbase}/internal"
    $internal_cacert = "${internal_certdir}/ca.pem"
}
