# @summary Postfix mail client installation
#
# Postfix mail client installation
#
# @param relayhost
#  The next-hop destination(s) for non-local mail; overrides non-local domains in recipient addresses
#  http://www.postfix.org/postconf.5.html#relayhost
#
# @example
#   include lsys::postfix::client
class lsys::postfix::client (
  Optional[Variant[Stdlib::Fqdn, Stdlib::IP::Address]]
          $relayhost = undef,
)
{
  if $relayhost {
    $enable_mta = true
  }
  else {
    $enable_mta = false
  }

  class { 'postfix':
    manage_mailx   => false,
    manage_aliases => false,
    mta            => $enable_mta,
    relayhost      => $relayhost,
  }
}
