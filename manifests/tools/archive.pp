# @summary Archive / compression CLI tools
#
# Archive / compression utilities. Each tool is off by default (`ensure => false`)
# and enabled per-tool via its `*_ensure` parameter — the same menu convention as
# `lsys::tools::diagnostic`. Handy e.g. to satisfy restic's archive install, which
# unpacks the upstream `.bz2` release binary with `bunzip2`.
#
# @example
#   class { 'lsys::tools::archive':
#     bzip2_ensure => true,
#   }
#
# @param bzip2_ensure
#   bzip2 (provides the `bzip2` / `bunzip2` commands). The package is named
#   `bzip2` on both RHEL and Debian/Ubuntu, so no per-OS name mapping is needed.
#
class lsys::tools::archive (
  Bsys::PackageVersion $bzip2_ensure = false,
) {
  # bzip2 / bunzip2 — same package name on RHEL and Debian/Ubuntu.
  bsys::tools::package { 'bzip2': ensure => $bzip2_ensure }
}
