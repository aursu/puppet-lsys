#!/bin/bash

echo Content-type: text/html
echo ""

PXELIBDIR=/var/lib/pxe
TFTPROOT=/var/lib/tftpboot
CONFDIR=boot/install

if [ -z "$QUERY_STRING" ]; then
    echo "Empty QUERY_STRING variable" >&2
    exit 0
fi

echo "QUERY_STRING is: \"$QUERY_STRING\"" >&2

# host configuration file (hostname.cfg)
CONFNAME="${QUERY_STRING}.cfg"

HOSTCONF="$PXELIBDIR/$CONFNAME"
INSTCONF="$TFTPROOT/$CONFDIR/$CONFNAME"

if [ -f $INSTCONF ]; then
    rm $INSTCONF
    echo "Removed \"${INSTCONF}\" with status: $?" >&2
elif [ -f $HOSTCONF ]; then
    cp $HOSTCONF $INSTCONF
    echo "Copied \"${HOSTCONF}\" to \"${INSTCONF}\" with status: $?" >&2
else
    echo "Configuration file for host \"$QUERY_STRING\" does not exist" >&2
fi

exit 0