# @summary Utilities for managing processes on your system
#
# The psmisc package contains utilities for managing processes on your
# system: pstree, killall, fuser and pslog.  The pstree command displays
# a tree structure of all of the running processes on your system.  The
# killall command sends a specified signal (SIGTERM if nothing is specified)
# to processes identified by name.  The fuser command identifies the PIDs
# of processes that are using specified files or filesystems. The pslog
# command shows the path of log files owned by a given process.
#
# @example
#   include lsys::tools::psmisc
class lsys::tools::psmisc (
  $package_ensure = present,
)
{
  package { 'psmisc':
    ensure => $package_ensure,
  }
}
