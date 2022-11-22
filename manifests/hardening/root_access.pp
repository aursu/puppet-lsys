# @summary CONTROLLING ROOT ACCESS
#
# CONTROLLING ROOT ACCESS
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-controlling_root_access
#
# @example
#   include lsys::hardening::root_access
#
# @param protecting_symbolic_links
# @param manage_password
# @param password_hash
#
class lsys::hardening::root_access (
  Boolean $protecting_symbolic_links = true,
  Boolean $manage_password = false,
  Optional[String] $password_hash = undef,
) {
  # 4.2.6. Protecting Hard and Symbolic Links
  if $protecting_symbolic_links {
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
