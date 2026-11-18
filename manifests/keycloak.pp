# @summary Keycloak as a native service behind a local reverse proxy
#
# Wraps the `keycloak` class of treydock-keycloak with safe defaults for a
# single-node Keycloak that listens on loopback only, uses a PostgreSQL
# database on the same host and is published by a reverse proxy (TLS ends at
# the proxy):
#
# * the release archive is downloaded by this class and **verified against a
#   mandatory SHA-256**; the keycloak module only unpacks the verified local
#   file (it does not check a digest itself);
# * HTTP and the management interface (health, metrics) bind to `http_host`,
#   127.0.0.1 by default; `proxy-headers` is set for the proxy;
# * local cache (`cache=local`), no cluster ports;
# * explicit JVM heap limits instead of a percentage of the host RAM;
# * the database, its login role and a loopback pg_hba line come from
#   `lsys_postgresql::database` (the keycloak module's own database management
#   is switched off);
# * a systemd drop-in hardens the unit shipped by the keycloak module.
#
# The PostgreSQL server itself must be declared on the node (`lsys_postgresql`)
# when `manage_database` is true.
#
# @example
#   class { 'lsys::keycloak':
#     archive_sha256 => 'dd124787283918bc597628887168333465ee2a811a389e0003569e52be7e487f',
#     hostname       => 'https://sso.example.com',
#     admin_password => Sensitive('...'),
#     db_password    => Sensitive('...'),
#   }
#
# @param archive_sha256
#   SHA-256 of `keycloak-<version>.tar.gz`. Mandatory: a version change without
#   a new digest fails the download.
#
# @param admin_password
#   Password of the bootstrap admin of the `master` realm (also used by the
#   keycloak module's kcadm wrapper for its resource types).
#
# @param db_password
#   Password of the database login role.
#
# @param version
#   Keycloak version.
#
# @param base_url
#   Where release archives are downloaded from: `<base_url>/<version>/keycloak-<version>.tar.gz`.
#
# @param download_dir
#   Directory that keeps the verified archives.
#
# @param hostname
#   Keycloak `hostname` option: the public URL (recommended, e.g.
#   `https://sso.example.com`) or host name. It becomes part of the token issuer.
#
# @param http_host
#   Address HTTP and the management interface listen on.
#
# @param http_port
#   HTTP port.
#
# @param management_port
#   Port of the management interface (`/health`, `/metrics`).
#
# @param proxy_headers
#   Which forwarding headers of the reverse proxy Keycloak trusts.
#
# @param admin_user
#   Name of the bootstrap admin.
#
# @param manage_database
#   Create the database, role and pg_hba line through `lsys_postgresql::database`.
#
# @param db_name
#   Database name.
#
# @param db_user
#   Database login role.
#
# @param db_host
#   Database host as Keycloak connects to it.
#
# @param db_port
#   Database port.
#
# @param db_client_addresses
#   pg_hba addresses for the role (see `lsys_postgresql::database`).
#
# @param heap_min
#   JVM `-Xms`.
#
# @param heap_max
#   JVM `-Xmx`.
#
# @param java_package
#   Java package for the keycloak module's `java` class. Defaults to the
#   headless JRE 21 on Debian/Ubuntu; module default elsewhere.
#
# @param java_home
#   JAVA_HOME for that package.
#
# @param java_alternative
#   Name of the Java alternative.
#
# @param java_alternative_path
#   Path the `java` alternative must point to.
#
# @param service_hardening
#   `[Service]` settings of the hardening drop-in. An empty hash removes the
#   drop-in. `MemoryDenyWriteExecute` is deliberately absent: the JVM JIT needs
#   writable and executable memory.
#
# @param extra_configs
#   Further `keycloak.conf` options (strings, booleans or arrays), merged last.
#
# @param server_name
#   Public host name of the nginx front. When set, an nginx server block
#   publishes Keycloak over HTTPS (and redirects HTTP); when undef, no nginx
#   resources are declared. nginx itself must be declared on the node, or set
#   `manage_nginx_core`.
#
# @param listen_ip
#   Address(es) nginx listens on for this server. All addresses when undef.
#
# @param cert_identity
#   tlsinfo identity of the certificate for `server_name` (required with it).
#
# @param manage_certificate
#   Declare `tlsinfo::certpair` for `cert_identity`. Set false when the node
#   already declares that certificate pair.
#
# @param manage_nginx_core
#   `include lsys_nginx` from this class.
#
# @param ssl_stapling
#   OCSP stapling. Off by default: Let's Encrypt certificates carry no OCSP
#   responder URL any more, and nginx would only log a warning.
#
# @param management_allow
#   Addresses (CIDR) allowed to reach `/health` and `/metrics` of the management
#   interface through nginx. Empty: these paths are not published.
#
# @param backup_password
#   restic repository password. When set, the database is backed up: a
#   `pg_dump` (`lsys_postgresql::backup`) into a local restic repository, and,
#   with `backup_offsite_repository`, a daily `restic copy` to it. Keep this
#   password outside the host as well - without it the backups are unreadable.
#
# @param backup_repository
#   Local restic repository (path).
#
# @param backup_minute
#   Minute of the hourly dump.
#
# @param backup_keep
#   Retention of the local repository.
#
# @param backup_offsite_repository
#   restic URL of the off-site copy, e.g. `s3:https://s3.example.com/bucket/host/keycloak`.
#
# @param backup_offsite_env
#   Environment for the off-site repository (S3 credentials, region).
#
# @param backup_offsite_keep
#   Retention of the off-site repository.
#
# @param backup_offsite_minute
#   Minute of the daily copy.
#
# @param backup_offsite_hour
#   Hour of the daily copy.
#
class lsys::keycloak (
  Pattern[/\A[0-9a-f]{64}\z/] $archive_sha256,
  Variant[String[1], Sensitive[String[1]]] $admin_password,
  Variant[String[1], Sensitive[String[1]]] $db_password,
  String[1] $version = '26.8.2',
  Stdlib::HTTPSUrl $base_url = 'https://github.com/keycloak/keycloak/releases/download',
  Stdlib::Absolutepath $download_dir = '/var/cache/keycloak',
  Variant[Stdlib::Host, Stdlib::HTTPUrl, Stdlib::HTTPSUrl] $hostname = $facts['networking']['fqdn'],
  Stdlib::IP::Address $http_host = '127.0.0.1',
  Stdlib::Port $http_port = 8080,
  Stdlib::Port $management_port = 9000,
  Enum['forwarded', 'xforwarded'] $proxy_headers = 'xforwarded',
  String[1] $admin_user = 'admin',
  Boolean $manage_database = true,
  String[1] $db_name = 'keycloak',
  String[1] $db_user = 'keycloak',
  Stdlib::Host $db_host = '127.0.0.1',
  Stdlib::Port $db_port = 5432,
  Array[Postgresql::Pg_hba_rule_address] $db_client_addresses = ['127.0.0.1/32'],
  Pattern[/\A[0-9]+[kmg]\z/] $heap_min = '512m',
  Pattern[/\A[0-9]+[kmg]\z/] $heap_max = '2g',
  Optional[String[1]] $java_package = undef,
  Optional[Stdlib::Absolutepath] $java_home = undef,
  Optional[String[1]] $java_alternative = undef,
  Optional[Stdlib::Absolutepath] $java_alternative_path = undef,
  Hash[String[1], String] $service_hardening = {
    'NoNewPrivileges'         => 'yes',
    'PrivateTmp'              => 'yes',
    'PrivateDevices'          => 'yes',
    'ProtectSystem'           => 'full',
    'ProtectHome'             => 'yes',
    'ProtectKernelTunables'   => 'yes',
    'ProtectKernelModules'    => 'yes',
    'ProtectKernelLogs'       => 'yes',
    'ProtectControlGroups'    => 'yes',
    'ProtectClock'            => 'yes',
    'ProtectHostname'         => 'yes',
    'RestrictSUIDSGID'        => 'yes',
    'RestrictRealtime'        => 'yes',
    'RestrictNamespaces'      => 'yes',
    'LockPersonality'         => 'yes',
    'RestrictAddressFamilies' => 'AF_UNIX AF_INET AF_INET6',
    'SystemCallArchitectures' => 'native',
    'CapabilityBoundingSet'   => '',
    'AmbientCapabilities'     => '',
    'UMask'                   => '0027',
  },
  Hash[String[1], Variant[String[1], Boolean, Array]] $extra_configs = {},
  Optional[Stdlib::Fqdn] $server_name = undef,
  Optional[Variant[Stdlib::IP::Address::Nosubnet, Array[Stdlib::IP::Address::Nosubnet, 1]]] $listen_ip = undef,
  Optional[String[1]] $cert_identity = undef,
  Boolean $manage_certificate = true,
  Boolean $manage_nginx_core = false,
  Boolean $ssl_stapling = false,
  Array[Stdlib::IP::Address] $management_allow = [],
  Optional[Variant[String[1], Sensitive[String[1]]]] $backup_password = undef,
  Stdlib::Absolutepath $backup_repository = '/var/backups/restic/keycloak',
  String[1] $backup_minute = '47',
  Hash[Enum['last', 'hourly', 'daily', 'weekly', 'monthly', 'yearly'], Integer] $backup_keep = {
    'hourly' => 24,
    'daily'  => 7,
  },
  Optional[String[1]] $backup_offsite_repository = undef,
  Hash[String[1], String] $backup_offsite_env = {},
  Hash[Enum['last', 'hourly', 'daily', 'weekly', 'monthly', 'yearly'], Integer] $backup_offsite_keep = {
    'daily' => 14,
  },
  String[1] $backup_offsite_minute = '45',
  String[1] $backup_offsite_hour = '3',
) {
  # the keycloak module takes these as plain strings
  $_admin_password = $admin_password ? {
    Sensitive => $admin_password.unwrap,
    default   => $admin_password,
  }
  $_db_password = $db_password ? {
    Sensitive => $db_password.unwrap,
    default   => $db_password,
  }

  # Debian/Ubuntu: the headless JRE 21; the alternative is normally already set,
  # so the java class's update-java-alternatives exec stays idle
  if $facts['os']['family'] == 'Debian' {
    $arch = $facts['os']['architecture']
    $_java_package = pick($java_package, 'openjdk-21-jre-headless')
    $_java_home = pick($java_home, "/usr/lib/jvm/java-21-openjdk-${arch}")
    $_java_alternative = pick($java_alternative, "java-1.21.0-openjdk-${arch}")
    $_java_alternative_path = pick($java_alternative_path, "${_java_home}/bin/java")
  }
  else {
    $_java_package = $java_package
    $_java_home = $java_home
    $_java_alternative = $java_alternative
    $_java_alternative_path = $java_alternative_path
  }

  # verified archive
  $archive_file = "${download_dir}/keycloak-${version}.tar.gz"

  file { $download_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  archive { $archive_file:
    ensure          => present,
    source          => "${base_url}/${version}/keycloak-${version}.tar.gz",
    checksum        => $archive_sha256,
    checksum_type   => 'sha256',
    checksum_verify => true,
    extract         => false,
    cleanup         => false,
    require         => File[$download_dir],
    before          => Class['keycloak'],
  }

  if $manage_database {
    lsys_postgresql::database { $db_name:
      user             => $db_user,
      password         => $db_password,
      client_addresses => $db_client_addresses,
      before           => Class['keycloak'],
    }
  }

  class { 'keycloak':
    version               => $version,
    package_url           => $archive_file,
    java_declare_method   => 'class',
    java_package          => $_java_package,
    java_home             => $_java_home,
    java_alternative      => $_java_alternative,
    java_alternative_path => $_java_alternative_path,
    java_opts             => "-Xms${heap_min} -Xmx${heap_max}",
    hostname              => $hostname,
    http_enabled          => true,
    http_host             => $http_host,
    http_port             => $http_port,
    proxy_headers         => $proxy_headers,
    admin_user            => $admin_user,
    admin_user_password   => $_admin_password,
    manage_db             => false,
    manage_db_server      => false,
    db                    => 'postgres',
    db_url_host           => $db_host,
    db_url_port           => $db_port,
    db_url_database       => $db_name,
    db_username           => $db_user,
    db_password           => $_db_password,
    configs               => {
      'cache'                => 'local',
      'health-enabled'       => true,
      'metrics-enabled'      => true,
      'http-management-port' => $management_port,
    },
    extra_configs         => { 'http-management-host' => $http_host } + $extra_configs,
  }

  # not a selector on {}: a hash case option matches any hash that contains its
  # keys, so {} would match every value
  $hardening_ensure = $service_hardening.empty ? {
    true    => 'absent',
    default => 'present',
  }

  systemd::dropin_file { 'hardening.conf':
    ensure  => $hardening_ensure,
    unit    => 'keycloak.service',
    content => epp('lsys/keycloak/hardening.conf.epp', { 'settings' => $service_hardening }),
  }

  # nginx front: TLS ends here, Keycloak stays on loopback
  if $server_name {
    unless $cert_identity {
      fail('lsys::keycloak: cert_identity is required when server_name is set')
    }

    if $manage_nginx_core {
      include lsys_nginx
    }

    include lsys::webserver::params

    if $manage_certificate {
      tlsinfo::certpair { $cert_identity:
        identity => true,
        notify   => Class['nginx::service'],
      }
    }

    $certdata = tlsinfo::lookup($cert_identity)
    $stapling = $ssl_stapling ? {
      true    => 'on',
      default => 'off',
    }
    $ssl_settings = $lsys::webserver::params::ssl_settings + {
      'ssl_cert'            => tlsinfo::certpath($certdata),
      'ssl_key'             => tlsinfo::keypath($certdata),
      'ssl_stapling'        => $stapling,
      'ssl_stapling_verify' => $stapling,
    }

    nginx::resource::server { 'keycloak':
      *                    => $ssl_settings,
      listen_ip            => $listen_ip,
      listen_port          => 80,
      ssl_port             => 443,
      ssl_redirect         => true,
      server_name          => [$server_name],
      use_default_location => false,
      access_log           => "/var/log/nginx/${server_name}.access_log",
      error_log            => "/var/log/nginx/${server_name}.error_log",
    }

    # Keycloak behind a proxy: forwarded host, proto and port (proxy-headers
    # xforwarded); larger buffers for its token-heavy responses and cookies
    $proxy_headers_set = [
      'Host $host',
      'X-Real-IP $remote_addr',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'X-Forwarded-Proto $scheme',
      'X-Forwarded-Host $host',
      'X-Forwarded-Port $server_port',
    ]
    $proxy_buffers = {
      'proxy_buffer_size'       => '128k',
      'proxy_buffers'           => '4 256k',
      'proxy_busy_buffers_size' => '256k',
    }

    nginx::resource::location { 'keycloak-root':
      server              => 'keycloak',
      location            => '/',
      ssl                 => true,
      ssl_only            => true,
      proxy               => "http://${http_host}:${http_port}",
      proxy_set_header    => $proxy_headers_set,
      # nginx sends its own HSTS (ssl_add_header); Keycloak's would be a second one
      proxy_hide_header   => ['Strict-Transport-Security'],
      location_cfg_append => $proxy_buffers,
    }

    unless $management_allow.empty {
      ['/health', '/metrics'].each |$path| {
        nginx::resource::location { "keycloak-management${regsubst($path, '/', '-', 'G')}":
          server           => 'keycloak',
          location         => $path,
          ssl              => true,
          ssl_only         => true,
          proxy            => "http://${http_host}:${management_port}",
          proxy_set_header => $proxy_headers_set,
          location_allow   => $management_allow,
          location_deny    => ['all'],
        }
      }
    }
  }

  # database backup: hourly pg_dump into a local restic repository, daily copy off-site
  if $backup_password {
    restic::repository { 'keycloak':
      repository   => $backup_repository,
      password     => $backup_password,
      prune_minute => '35',
      prune_hour   => '4',
    }

    lsys_postgresql::backup { $db_name:
      repository => 'keycloak',
      minute     => $backup_minute,
      keep       => $backup_keep,
    }

    if $backup_offsite_repository {
      restic::repository { 'keycloak-offsite':
        repository   => $backup_offsite_repository,
        password     => $backup_password,
        env          => $backup_offsite_env,
        init         => false,
        prune_minute => '50',
        prune_hour   => '4',
      }

      restic::copy { 'keycloak-offsite':
        source_repository => 'keycloak',
        dest_repository   => 'keycloak-offsite',
        keep              => $backup_offsite_keep,
        minute            => $backup_offsite_minute,
        hour              => $backup_offsite_hour,
      }
    }
  }
}
