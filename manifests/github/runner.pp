# @summary GitHub Actions Runner service
#
# Manages GitHub Actions self-hosted runner as a Docker Compose service
#
# @example Basic usage with token
#   lsys::github::runner { 'runner1':
#     url                => 'https://github.com/myorg',
#     registration_token => 'ABCD1234567890',
#   }
#
# @example Using GitHub App authentication
#   lsys::github::runner { 'runner2':
#     url       => 'https://github.com/myorg',
#     client_id => '123456',
#     app_key   => $github_app_private_key,
#   }
#
# @param url
#   GitHub URL (organization or repository)
#
# @param registration_token
#   GitHub runner registration token
#
# @param remove_token
#   GitHub runner removal token
#
# @param pat
#   Personal Access Token for GitHub API
#
# @param client_id
#   GitHub App Client ID
#
# @param app_key
#   GitHub App private key content
#
# @param runner_name
#   Unique name for the runner instance
#
# @param runner_volume
#   Docker volume name for runner data
#
# @param project_name
#   Docker Compose project name
#
# @param env_name
#   Environment name for secrets file
#
# @param environment
#   Additional environment variables
#
# @param docker_volumes
#   Additional volume mounts
#
# @param docker_command
#   Command to run in the container
#
define lsys::github::runner (
  String $url = 'https://github.com/rpmbsys',
  # token auth (either registration or removal)
  Optional[String] $registration_token = undef,
  Optional[String] $remove_token = undef,
  # personal access token auth
  Optional[String] $pat = undef,
  # github app auth
  Optional[String] $client_id = undef,
  Optional[String] $app_key = undef,
  # runner settings
  String $runner_name = "github-actions-runner-${name}",
  String $runner_volume = 'githubrunner',
  String $project_name = 'github',
  String $env_name = 'jwt',
  Hash[String, String] $environment = {},
  String $runner_labels = 'self-hosted,linux,x64',
  Array[String] $docker_volumes = [],
  String $docker_command = '/usr/local/runner/runner.py',
  Boolean $manage_image = false,
  String $docker_host = 'tcp://localhost:2376',
  String $runner_os = '10.1.20251126',
  String $runner_version = '2.331.0',
) {
  # constants
  $runner_repo    = 'ghcr.io/aursu/rockylinux'
  $runner_image   = "${runner_repo}:${runner_os}-actions-runner-${runner_version}"

  $docker_cert_path = '/certs/client'
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
    $project_secrets = [
      {
        'name'     => 'github_key',
        'type'     => 'file',
        'setup'    => true,
        'value'    => $app_key,
        'filename' => 'private-key.pem',
      },
    ]
    $docker_secret = ['github_key']
    $runner_auth_environment = {
      'GITHUB_APP_KEY_PATH' => '/run/secrets/github_key',
    }
  }
  else {
    $project_secrets = undef
    $docker_secret = undef
    $runner_auth_environment = {}
  }

  $runner_env_secrets = {
    'GITHUB_URL'       => $url,
    'GITHUB_TOKEN'     => $token,
    'GITHUB_PAT'       => $pat ? { undef => '', default => $pat },
    'GITHUB_CLIENT_ID' => $client_id ? { undef => '', default => $client_id },
  }

  $runner_environment = {
    'RUNNER_NAME'   => $runner_name,
    'RUNNER_LABELS' => $runner_labels,
  } + $runner_auth_environment

  $runner_volumes = [
    "${runner_volume}:/home/runner",
  ]

  dockerinstall::webservice { $runner_name:
    docker_image    => $runner_image,
    manage_image    => $manage_image,
    docker_command  => $docker_command,
    project_name    => $project_name,
    service_name    => 'githubrunner',
    environment     => $runner_environment + $docker_access_environment,
    docker_volume   => $docker_access_volumes + $runner_volumes + $docker_volumes,
    project_volumes => [
      {
        $runner_volume => { 'name' => $runner_volume, }
      },
    ],
    # app key setup
    project_secrets => $project_secrets,
    docker_secret   => $docker_secret,
    # runner secrets
    env_name        => $env_name,
    secrets         => $runner_env_secrets,
  }
}
