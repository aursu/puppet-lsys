# @summary CONTROLLING ROOT ACCESS
#
# CONTROLLING ROOT ACCESS
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-controlling_root_access
#
# @example
#   include lsys::hardening::root_access
#
# @param unprotect_symbolic_links
#   Set to true to disable the kernel's symlink protection
#   (`fs.protected_symlinks = 0`). Takes effect on RedHat release 8 only: 9 and
#   later keep the protection, deliberately.
#
# @param manage_password
# @param password_hash
#
class lsys::hardening::root_access (
  Boolean $unprotect_symbolic_links = true,
  Boolean $manage_password = false,
  Optional[String] $password_hash = undef,
) {
  if $unprotect_symbolic_links {
    # Reference
    # [4.2.6. Protecting Hard and Symbolic Links]
    #   (https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/security_guide/sec-controlling_root_access#sec-Protecting_Hard_and_Symbolic_Links)
    # [RHEL 8 must enable kernel parameters to enforce discretionary access control on symlinks]
    #   (https://www.stigviewer.com/stig/red_hat_enterprise_linux_8/2021-06-14/finding/V-230267)
    #
    # Release 8 only. On 9 and later the protection stays on whatever this says:
    # it is what stops a symlink race in a world-writable sticky directory
    # such as /tmp, no server type there has been shown to need it off, and
    # extending the switch would weaken every EL9/EL10 node that inherits it.
    if $facts['os']['family'] == 'RedHat' and
    $facts['os']['release']['major'] == '8' {
      sysctl { 'fs.protected_symlinks':
        value => '0',
      }
    }
  }

  # openssl passwd -6
  if $manage_password and $password_hash {
    user { 'root':
      password => $password_hash,
    }
  }
}
