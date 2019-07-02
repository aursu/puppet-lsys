#!/bin/bash

echo Content-type: text/html
echo ""

TFTPROOT=/var/lib/tftpboot
CONFDIR=boot/install
CONFSUFF=.cfg
DISSUFF=.disable

if [ -z "$QUERY_STRING" ]; then
    echo "Empty QUERY_STRING variable" >&2
    exit 0
fi

echo "QUERY_STRING is: \"$QUERY_STRING\"" >&2

HOSTCONF="$TFTPROOT/$CONFDIR/${QUERY_STRING}$CONFSUFF"

if [ -f "$HOSTCONF" ]; then
    mv "$HOSTCONF" "${HOSTCONF}$DISSUFF"
    echo "Moved \"${HOSTCONF}\" to \"${HOSTCONF}$DISSUFF\" with status: $?" >&2
elif [ -f "${HOSTCONF}$DISSUFF" ]; then
    mv "${HOSTCONF}$DISSUFF" "$HOSTCONF"
    echo "Moved \"${HOSTCONF}$DISSUFF\" to \"${HOSTCONF}\" with status: $?" >&2
else
    echo "Configuration file for host \"$QUERY_STRING\" does not exist" >&2
fi

exit 0