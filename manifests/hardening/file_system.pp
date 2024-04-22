# @summary File system hardening
#
# File system hardening
#
# @example
#   include lsys::hardening::file_system
#
# @param proc_mode
#
# @param manage_vardb
#   Whether to manage folder /var/db or not
#
# @param manage_sbin
#   Whather to manage folder /usr/sbin or not
#
class lsys::hardening::file_system (
  Lsys::FileMode $proc_mode = '0551',
  Boolean $manage_vardb     = true,
  Boolean $manage_sbin      = true,
) {
  lsys::hardening::chmod_directory {
    default: mode => '0711';
    '/': ;
    '/boot': mode => '0550';
    '/dev':  mode => '0751';
    '/etc': ;
    '/home': ;
    '/media': ;
    '/mnt': ;
    '/opt': ;
    '/proc': mode => $proc_mode;
    '/root': mode => '0700';
    '/run':  mode => '0751';
    '/var': ;
  }

  file {
    '/var/spool':     mode => '0711';
    '/var/spool/lpd': mode => '0750';
    '/var/tmp':       mode => '1773';
    '/tmp':           mode => '1773';
  }

  if $manage_vardb {
    file { '/var/db':
      mode => '0750';
    }
  }

  if $manage_sbin {
    # users should have access to sendmail binary
    file { '/usr/sbin':
      mode => '0711';
    }
  }

  file {
    default: mode => 'o=';
    # chkconfig
    '/etc/alternatives':      mode => '0751';
    '/etc/chkconfig.d': ;
    '/etc/rc.d/init.d':       mode => '0711';
    '/etc/rc.d':              mode => '0710';
    '/etc/rc.d/rc0.d':        mode => '0711';
    '/etc/rc.d/rc1.d':        mode => '0711';
    '/etc/rc.d/rc2.d':        mode => '0711';
    '/etc/rc.d/rc3.d':        mode => '0711';
    '/etc/rc.d/rc4.d':        mode => '0711';
    '/etc/rc.d/rc5.d':        mode => '0711';
    '/etc/rc.d/rc6.d':        mode => '0711';
    # filesystem
    '/etc/bash_completion.d': ;
    '/etc/opt': ;
    '/etc/pki':               mode => '0751';
    '/etc/pm': ;
    # dbus
    '/etc/dbus-1': ;
    # glibc-common
    '/etc/default': ;
    # kmod
    '/etc/depmod.d': ;
    '/etc/modprobe.d': ;
    # dhcp-common
    '/etc/dhcp': ;
    # dracut
    '/etc/dracut.conf.d':     mode => '0750';
    # libgcrypt
    '/etc/gcrypt': ;
    # gnupg2
    '/etc/gnupg': ;
    # util-linux
    '/etc/mtab': ;
    # NetworkManager
    '/etc/NetworkManager': ;
    # openldap
    '/etc/openldap':          mode => '0750';
    # pam
    '/etc/pam.d':             mode => '0750';
    '/etc/security':          mode => '0750';
    # p11-kit
    '/etc/pkcs11': ;
    # polkit
    '/etc/polkit-1': ;
    # popt
    '/etc/popt.d': ;
    # prelink
    '/etc/prelink.conf.d': ;
    # setup
    '/etc/profile.d': ;
    '/etc/puppetlabs':        mode => '0750';
    # rpm
    '/etc/rpm': ;
    # initscripts
    '/etc/rwtab.d': ;
    '/etc/sasl2': ;
    '/etc/selinux': ;
    '/etc/setuptool.d': ;
    '/etc/skel': ;
    '/etc/ssl':               mode => 'o=x';
    '/etc/statetab.d': ;
    '/etc/terminfo': ;
    '/etc/udev': ;
    '/etc/X11': ;
    '/etc/xdg': ;
    '/run/lock':              mode => '0750';
    '/usr/bin':               mode => '0711';
    '/usr/include':           mode => '0750';
    '/usr/lib64':             mode => '0751';
    '/usr/lib':               mode => '0751';
    '/usr/lib/modules': ;
    '/usr/share/doc':         mode => '0711';
    '/usr/share':             mode => '0711';
    '/usr/src':               mode => '0750';
    '/var/account':           mode => '0750';
    '/var/cache':             mode => '0750';
    '/var/cache/yum':         mode => '0750';
    '/var/crash':             mode => '0750';
    '/var/empty':             mode => '0750';
    '/var/games':             mode => '0750';
    '/var/lib':               mode => '0711';
    '/var/lib/rpm':           mode => '0750';
    '/var/lib/yum':           mode => '0750';
    '/var/local':             mode => '0750';
    '/var/log':               mode => '0751';
    '/var/log/sa':            mode => '0700';
    '/var/nis':               mode => '0750';
    '/var/opt':               mode => '0750';
    '/var/preserve':          mode => '0750';
  }

  file {
    default: mode => 'o=';
    '/etc/centos-release':     mode => '0640';
    '/etc/issue': ;
    '/etc/issue.net': ;
    '/etc/system-release-cpe': mode => '0640';
    '/etc/libuser.conf':       mode => '0640';

    # dracut
    '/etc/dracut.conf':        mode => '0640';

    # setup
    '/etc/exports': ;
    '/etc/filesystems': ;
    '/etc/fstab': ;
    '/etc/group':              mode => '0644';
    '/etc/gshadow':            mode => '0000';
    '/etc/hosts':              mode => '0640';
    '/etc/passwd':             mode => '0644';
    '/etc/shadow':             mode => '0000';

    # kexec-tools
    '/etc/kdump.conf':         mode => '0640';

    # krb5-libs
    '/etc/krb5.conf':          mode => '0640';

    # glibc
    '/etc/ld.so.conf':         mode => '0640';

    # audit-libs
    '/etc/libaudit.conf':      mode => '0640';

    # mailx
    '/etc/mail.rc': ;

    # e2fsprogs
    '/etc/mke2fs.conf':        mode => '0640';

    # policycoreutils
    '/etc/sestatus.conf':      mode => '0640';

    # systemd
    '/etc/sysctl.conf':        mode => '0600';

    # coreutils
    '/usr/bin/arch': ;
    '/usr/bin/df': ;
    '/usr/bin/groups': ;
    '/usr/bin/mkfifo': ;
    '/usr/bin/mknod': ;
    '/usr/bin/stty': ;
    '/usr/bin/sync': ;
    '/usr/bin/tty': ;
    '/usr/bin/users': ;

    # util-linux
    '/usr/bin/dmesg': ;
    '/usr/bin/isosize': ;
    '/usr/bin/last': ;
    '/usr/bin/logger': ;
    '/usr/bin/lsblk': ;
    '/usr/bin/lscpu': ;
    '/usr/bin/mesg': ;
    '/usr/bin/mount': ;
    '/usr/bin/umount': ;
    '/usr/bin/wall': ;
    '/usr/bin/whereis': ;
    '/usr/sbin/readprofile': ;

    # glibc-common
    '/usr/bin/gencat': ;
    '/usr/bin/getconf': ;
    '/usr/bin/getent': ;
    '/usr/bin/ldd': ;
    '/usr/bin/locate': ;
    '/usr/sbin/iconvconfig': ;
    '/usr/sbin/zdump': ;

    # passwd
    '/usr/bin/passwd': ;

    # rpm
    '/usr/bin/rpm': ;

    # vim
    '/usr/bin/vim': ;
    '/usr/bin/vi': ;

    # cracklib
    '/usr/sbin/create-cracklib-dict': ;

    # libselinux-utils
    '/usr/sbin/getenforce':    mode => '0750';
    '/usr/sbin/setenforce':    mode => '0750';

    # grubby
    '/usr/sbin/grubby':        mode => '0750';

    # grub2-tools
    '/usr/sbin/grub2-install': mode => '0750';

    # logrotate
    '/usr/sbin/logrotate': ;

    # kmod
    '/usr/sbin/lsmod': ;

    # pciutils
    '/usr/sbin/lspci': ;

    # e2fsprogs
    '/usr/sbin/mklost+found': ;

    # tcp_wrappers
    '/usr/sbin/safe_finger': ;
    '/usr/sbin/tcpd': ;
    '/usr/sbin/try-from': ;

    '/var/log/lastlog':        mode => '0600';
    '/var/log/wtmp': ;
  }
}
