# @summary Disable unused NFS client RPC services
#
# `rpcbind` is the RPC portmapper. It is pulled in by NFS client tooling and, on
# most distributions, is enabled and started as soon as that tooling is
# installed - whether or not anything mounts an NFS share. It binds `0.0.0.0:111`
# and `[::]:111`, answers to anyone who can reach it, and reports the RPC program
# map, which enumerates the RPC services a host runs. It is also a long-standing
# participant in reflection and amplification attacks.
#
# On a host that mounts nothing over NFS and registers no RPC program of its own,
# the portmapper is a listener with no consumer. Firewalling it leaves the service
# running and the map available to anything inside the filter; stopping and
# masking removes it.
#
# @example Disable it
#   include lsys::hardening::nfs
#
# @example Keep rpcbind, because this host is an NFS client
#   class { 'lsys::hardening::nfs':
#     mask_rpcbind => false,
#   }
#
# ⚠ Do not include this on a host that mounts NFS shares, exports them, or runs
# any other RPC service - NIS/`ypbind`, `rpc.statd`, `rpc.quotad`. Those need the
# portmapper to register with, and they fail without it. Check `mount -t nfs,nfs4`,
# `/etc/fstab` and `rpcinfo -p` before enabling it anywhere.
#
# @param mask_rpcbind
#   Whether to stop and mask the rpcbind units. Default `true` - including this
#   class is a statement that the host does not need RPC.
#
# @param rpcbind_units
#   The systemd units to act on. Defaults to both the service and its socket, and
#   ⚠ **both are required**: `rpcbind.socket` is socket-activated, so stopping only
#   `rpcbind.service` leaves the socket listening on `:111` and systemd starts the
#   service again on the next connection. Masking the service alone produces a host
#   that still answers on the port.
#
class lsys::hardening::nfs (
  Boolean $mask_rpcbind = true,
  Array[String[1]] $rpcbind_units = ['rpcbind.service', 'rpcbind.socket'],
) {
  if $mask_rpcbind {
    # The provider is named explicitly because Puppet's default on Debian is
    # `debian`, which wraps update-rc.d, has no `maskable` feature and fails
    # outright on `enable => mask`. A `.socket` is a systemd unit and nothing
    # else can manage one on the platforms this module supports.
    service { $rpcbind_units:
      ensure   => stopped,
      enable   => mask,
      provider => systemd,
    }
  }
}
