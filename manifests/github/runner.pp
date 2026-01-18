# @summary GitHub Actions Runner service
#
# Manages GitHub Actions self-hosted runner as a Docker Compose service
#
# @example Basic usage
#   lsys::github::runner { 'runner1':
#     runner_image => 'ghcr.io/aursu/rockylinux:10-actions-runner-2.320.0',
#     runner_name  => 'github-actions-runner-001',
#     secrets      => {
#       'GITHUB_TOKEN' => 'ghp_xxxxx',
#     },
#   }
#
# @param runner_image
#   Docker image for GitHub Actions runner
#
# @param runner_name
#   Unique name for the runner instance
#
# @param project_name
#   Docker Compose project name (default: 'github')
#
# @param env_name
#   Environment name for secrets file (default: 'jwt')
#
# @param secrets
#   Hash of secret environment variables
#
# @param environment
#   Hash of environment variables
#
# @param docker_volumes
#   Array of volume mounts
#
# @param docker_command
#   Command to run in the container
#
# @param github_app_key_path
#   Path to GitHub App private key inside container
#
# @param docker_host
#   Docker host connection string
#
# @param docker_cert_path
#   Path to Docker TLS certificates
#
define lsys::github::runner (
  String $url = 'https://github.com/rpmbsys',
  # token auth (either registration or removal)
  Optional[String] $registration_token = undef,
  Optional[String] $remove_token = undef,
  # personal access token auth
  String $pat = '',
  # github app auth
  String $client_id = '',
  Optional[String] $app_key = undef,
  # runner settings
  String $runner_name = "github-actions-runner-${name}",
  String $runner_volume = 'githubrunner',
  String $project_name = 'github',
  String $env_name = 'jwt',
  Hash $environment = {},
  Array[String] $docker_volumes = [],
  String $docker_command = '/usr/local/runner/runner.py',
) {
  # constants
  $runner_repo    = 'ghcr.io/aursu/rockylinux'
  $runner_os      = '10.1.20251126'
  $runner_version = '2.331.0'
  $runner_image   = "${runner_repo}:${runner_os}-actions-runner-${runner_version}"

  $docker_cert_path = '/certs/client'
  $docker_host = 'tcp://localhost:2376'
  $docker_access_volumes = [
    '/etc/docker/certs.d:/etc/docker/certs.d',
    '/var/run/docker.sock:/var/run/docker.sock',
    "/etc/docker/tls:${docker_cert_path}",
  ]
  $docker_access_environment = {
    'DOCKER_TLS_CERTDIR'    => '/certs',
    'DOCKER_CERT_PATH'      => $docker_cert_path,
    'DOCKER_TLS_VERIFY'     => '1',
    'DOCKER_HOST'           => $docker_host,
  }

  if $registration_token {
    $token = $registration_token
  }
  elsif $remove_token {
    $token = $remove_token
  }
  else {
    $token = ''
  }

  if $app_key {
    $project_secrets = {
      'name'     => 'github_key',
      'type'     => 'file',
      'setup'    => true,
      'value'    => $app_key,
      'filename' => 'private-key.pem',
    }
    $docker_secret = ['github_key']
    $runner_environment = {
      'RUNNER_NAME'         => $runner_name,
      'GITHUB_APP_KEY_PATH' => '/run/secrets/github_key',
    }
  }
  else {
    $project_secrets = {}
    $docker_secret = []
    $runner_environment = {
      'RUNNER_NAME' => $runner_name,
    }
  }

  $runner_env_secrets = {
    'GITHUB_URL'       => $url,
    'GITHUB_TOKEN'     => $token,
    'GITHUB_PAT'       => $pat,
    'GITHUB_CLIENT_ID' => $client_id,
  }

  $runner_volumes = [
    "${runner_volume}:/home/runner",
  ]

  dockerinstall::webservice { $runner_name:
    docker_image    => $runner_image,
    manage_image    => true,
    docker_command  => $docker_command,
    project_name    => $project_name,
    service_name    => 'githubrunner',
    environment     => $runner_environment + $docker_access_environment,
    docker_volume   => $docker_access_volumes + $runner_volumes + $docker_volumes,
    # app key setup
    project_secrets => $project_secrets,
    docker_secret   => $docker_secret,
    # runner secrets
    env_name        => $env_name,
    secrets         => $runner_env_secrets,
  }
}
