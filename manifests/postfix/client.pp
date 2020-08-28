# @summary Postfix mail client installation
#
# Postfix mail client installation
#
# @example
#   include lsys::postfix::client
class lsys::postfix::client {
  class { 'postfix':
    manage_mailx   => false,
    manage_aliases => false,
  }
}
