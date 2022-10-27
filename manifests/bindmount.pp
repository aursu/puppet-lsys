# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   lsys::bindmount { '/share/Sites/www.domain.com':
#     source => '/var/www/www.domain.com',
#   }
#
# Since Linux 2.4.0 it is possible to remount part of the file hierarchy somewhere else. The call is
#        mount --bind olddir newdir
# or shortoption
#        mount -B olddir newdir
# or fstab entry is:
#        /olddir /newdir none bind
define lsys::bindmount (
  Stdlib::Unixpath
          $source,
  Stdlib::Unixpath
          $target         = $name,
  String
          $ensure         = 'mounted',
  Lsys::BindOptions
          $options        = 'bind',
  Boolean $require_target = false,
) {
  # fs/proc_namespace.c
  # static const struct proc_fs_info mnt_info[] = {
  #   { MNT_NOSUID, ",nosuid" },
  #   { MNT_NODEV, ",nodev" },
  #   { MNT_NOEXEC, ",noexec" },
  #   { MNT_NOATIME, ",noatime" },
  #   { MNT_NODIRATIME, ",nodiratime" },
  #   { MNT_RELATIME, ",relatime" },
  #   { 0, NULL }
  # };

  $ordered_options = ['ro', 'nosuid', 'nodev', 'noexec', 'noatime', 'nodiratime', 'relatime']

  # Note that the filesystem mount options will remain the same as those on the
  # original mount point.
  # mount(8) since v2.27 (backported to RHEL7.3) allow to change the options by
  # passing the -o option along with --bind for example:
  #
  #        mount --bind,ro foo foo
  #
  # This feature is not supported by Linux kernel and it is implemented in
  # userspace by additional remount mount(2) syscall
  mount { "${target} ${options}":
    ensure  => $ensure,
    device  => $source,
    name    => $target,
    fstype  => 'none',
    options => $options,
  }

  if $require_target {
    File[$target] -> Mount["${target} ${options}"]
  }

  # This solution is not atomic.
  #
  # The alternative (classic) way to create a read-only bind mount is to use
  # remount operation, for example:
  #
  #        mount --bind olddir newdir
  #        mount -o remount,ro,bind olddir newdir
  #
  # It's  also  possible  to change nosuid, nodev, noexec, noatime, nodiratime
  # and relatime VFS entry flags by "remount,bind" operation
  #
  # we instantly remount mount point to apply additional options
  if $ensure in ['defined', 'present', 'mounted'] and $options =~ /(ro|nosuid|nodev|noexec|noatime|nodiratime|relatime)/ {
    $defined_options = split($options, ',').unique - ['bind']

    # 'noatime' and 'relatime' are mutual exclusive (relatime is default but noatime could override)
    # fs/namespace.c
    # /* Default to relatime unless overriden */
    # if (!(flags & MS_NOATIME))
    # 	mnt_flags |= MNT_RELATIME;
    if 'noatime' in $defined_options {
      $exclude_options = ($ordered_options - $defined_options) + ['relatime']
    }
    else {
      $exclude_options = $ordered_options - $defined_options
    }

    # options which we apply
    $apply_options = $ordered_options - $exclude_options

    # options set for mount command (with remount and bind)
    $mount_options = join((['remount', 'bind'] + $apply_options), ',')

    # options set for grep command
    $check_options = join($apply_options, ',')

    exec { "${target} ${mount_options}":
      command   => "mount -o ${mount_options} ${source} ${target}",
      onlyif    => "mountpoint ${target}",
      unless    => "cat /proc/mounts | grep ${target} | grep ${check_options}",
      subscribe => Mount["${target} ${options}"],
      path      => '/usr/bin:/bin',
    }
  }
}
