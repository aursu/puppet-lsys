# @summary CVE-2021-4034 mitigation
#
# It is possible to mitigate the problem by applying the configuration setting
# chmod 0755 /usr/bin/pkexec
#
# @example
#   include lsys::hardening::polkit
class lsys::hardening::polkit {
  file { '/usr/bin/pkexec':
    mode => '0750',
  }
}
