# @summary CONTROLLING ROOT ACCESS
#
# CONTROLLING ROOT ACCESS
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-controlling_root_access
#
# @example
#   include lsys::hardening::root_access
#
# @param unprotect_symbolic_links
#   Set to true to override the default settings and disable the protection for symbolic links
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
    if  $facts['os']['name'] in ['RedHat', 'CentOS'] and
    $facts['os']['release']['major'] in ['7', '8'] {
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
