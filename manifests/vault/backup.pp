# @summary Consistent Raft snapshots of a Vault running under docker compose
#
# Installs two scripts and a 0600 environment file that together take a
# consistent HashiCorp Vault Raft snapshot from a compose-managed container and
# leave it on disk for a backup tool to consume.
#
# This class is the reusable snapshot *mechanism*. It holds no knowledge of
# restic, of any backup schedule, or of any specific site - the caller pipes
# `$snapshot_script` into whatever it likes, exactly as `lsys::mysql::backup`
# exposes `$dump_command`.
#
# ## Why the container is never named directly
#
# Compose derives a container name as `<project>-<service>-<index>` unless the
# compose file sets `container_name`. Addressing it by a guessed name breaks the
# first time the naming scheme changes or a second replica appears, so the
# scripts resolve it with `docker compose ps -q` instead.
#
# ## Why two scripts and not one
#
# The cleanup half runs from the backup tool's trap on EXIT, so it executes
# whether the backup succeeded or failed. It is therefore deliberately NOT
# `set -e`: a non-zero exit there would mask the real error from the backup.
# Merging the two would force one error policy onto both.
#
# ## Requirements this class does not create
#
# * A token at `$token_file` whose policy grants `read` on
#   `sys/storage/raft/snapshot`. It cannot be created before Vault is
#   initialised, so it is left to the operator.
# * The Vault listener certificate must be valid for the address the CLI uses
#   inside the container - by default `https://127.0.0.1:8200`, which needs an
#   `IP:127.0.0.1` subject alternative name. Missing it produces a TLS error
#   that reads like a connection fault.
#
# @param compose_project  compose project name (`docker compose -p`).
# @param compose_service  service name inside the compose file.
# @param compose_file     path to the compose file on the host.
# @param token_file       host path holding the Vault token used for the snapshot.
# @param snapshot_path    where the snapshot is left on the host for the backup tool.
# @param container_path   scratch path for the snapshot inside the container.
# @param bin_dir          where the two scripts are installed.
# @param config_dir       where the 0600 environment file is written.
# @param manage_bin_dir    create `$bin_dir`. Set false when another class already
#                          declares it - notably `restic`, whose `bin_dir`
#                          defaults to the same path.
# @param manage_config_dir create `$config_dir`. Set false when the caller
#                          already declares it.
#
# @example Take a snapshot and hand it to restic
#   include lsys::vault::backup
#
#   restic::job { 'vault':
#     repository   => 'vault',
#     pre_command  => $lsys::vault::backup::snapshot_script,
#     command      => ['/usr/bin/cat', $lsys::vault::backup::snapshot_path],
#     post_command => $lsys::vault::backup::cleanup_script,
#   }
class lsys::vault::backup (
  String[1]            $compose_project = 'vault',
  String[1]            $compose_service = 'vault-prod',
  Stdlib::Absolutepath $compose_file    = '/var/lib/compose/vault/docker-compose.yml',
  Stdlib::Absolutepath $token_file      = '/etc/vault/snapshot-token',
  Stdlib::Absolutepath $snapshot_path   = '/run/vault-raft.snap',
  Stdlib::Absolutepath $container_path  = '/tmp/raft.snap',
  Stdlib::Absolutepath $bin_dir         = '/opt/backup',
  Stdlib::Absolutepath $config_dir      = '/etc/vault',
  Boolean              $manage_bin_dir    = true,
  Boolean              $manage_config_dir = true,
) {
  $env_file        = "${config_dir}/vault-backup.env"
  $snapshot_script = "${bin_dir}/vault-snapshot"
  $cleanup_script  = "${bin_dir}/vault-snapshot-cleanup"

  # Directory ownership is decided by the caller through parameters, never by
  # `defined()`. That function depends on evaluation order, so a class using it
  # behaves differently according to where it happens to be declared - which is
  # exactly the kind of thing a module someone else depends on must not do.
  if $manage_config_dir {
    file { $config_dir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  if $manage_bin_dir {
    file { $bin_dir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  # Both scripts source this. 0600 because it names the token file; the token
  # itself never lands here.
  file { $env_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp("${module_name}/vault/backup.env.epp", {
        'compose_project' => $compose_project,
        'compose_service' => $compose_service,
        'compose_file'    => $compose_file,
        'token_file'      => $token_file,
        'snapshot_path'   => $snapshot_path,
        'container_path'  => $container_path,
    }),
  }

  file { $snapshot_script:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
    source => "puppet:///modules/${module_name}/vault/vault-snapshot",
  }

  file { $cleanup_script:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
    source => "puppet:///modules/${module_name}/vault/vault-snapshot-cleanup",
  }
}
