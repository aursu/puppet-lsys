# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include lsys::registry::base
class lsys::registry::base (
    String $docker_image = 'registry:2.7.1',
){
    include lsys::registry::params

    # According to documentaton https://docs.docker.com/registry/deploying/
    # we use registry:2 image from docker.io/library repository
    dockerimage { $docker_image:
      ensure => present,
    }

    $registry_compose_service = $lsys::registry::params::registry_compose_service
    dockerinstall::composeservice { $registry_compose_service:
        project_basedir => '/var/lib/build',
        configuration   => template('lsys/services/registry.yaml.erb'),
        require         => Dockerimage[$docker_image],
    }
}
