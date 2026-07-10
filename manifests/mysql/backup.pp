# @summary Credentials + command for MySQL/MariaDB logical backups
#
# Writes a 0600 MySQL option file (usable as `--defaults-extra-file`) for a
# backup user, does OS-aware socket detection, and exposes the dump command
# prefix so callers can pipe it to any backup tool (restic, tar/gzip, …). This
# class is the reusable MySQL/MariaDB backup *mechanism*; it holds no knowledge
# of restic or of any specific site.
#
# @param password       backup user password (kept out of the process args).
# @param user           backup database user.
# @param defaults_file  path of the generated option file (0600, root:root).
# @param remote         connect over TCP (host) instead of the local socket.
# @param host           database host when `remote` (defaults to localhost).
# @param socket         local socket path; auto-detected per-OS when undef.
# @param dump_binary    path to the dump binary (mariadb-dump / mysqldump).
# @param dump_options   extra flags appended to the dump command.
#
# @example
#   class { 'lsys::mysql::backup': password => $pw }
#   # then: [ *$lsys::mysql::backup::dump_command, $database ]
class lsys::mysql::backup (
  Variant[String, Sensitive[String]] $password,
  String                             $user          = 'backup',
  Stdlib::Absolutepath               $defaults_file = '/root/mariadb-backup.cnf',
  Boolean                            $remote        = false,
  Optional[Stdlib::Host]             $host          = undef,
  Optional[Stdlib::Unixpath]         $socket        = undef,
  Stdlib::Absolutepath               $dump_binary   = '/usr/bin/mariadb-dump',
  Array[String]                      $dump_options  = ['--single-transaction', '--quick'],
) {
  # OS-aware socket default (override via $socket)
  $default_socket = $facts['os']['name'] ? {
    'Ubuntu' => '/var/run/mysqld/mysqld.sock',
    default  => '/var/lib/mysql/mysql.sock',
  }
  $my_socket = pick($socket, $default_socket)

  # local backup uses the socket; remote uses TCP (host)
  $cnf_socket = $remote ? { true => undef, default => $my_socket }
  $cnf_host   = $remote ? { true => pick($host, 'localhost'), default => undef }

  $pass = $password =~ Sensitive ? {
    true    => $password.unwrap,
    default => $password,
  }

  file { $defaults_file:
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0600',
    show_diff => false,
    content   => Sensitive(epp('lsys/mysql/backup.cnf.epp', {
          user     => $user,
          password => $pass,
          socket   => $cnf_socket,
          host     => $cnf_host,
    })),
  }

  # Dump command prefix; callers append the database name, e.g.
  #   [ *$lsys::mysql::backup::dump_command, 'mydb' ]
  $dump_command = [$dump_binary, "--defaults-extra-file=${defaults_file}"] + $dump_options
}
