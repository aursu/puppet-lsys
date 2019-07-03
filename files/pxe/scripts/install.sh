#!/bin/bash

# script for downloading and syncing CentOS repositories to local host into
# path /diskless/centos

osb="7"
osv="7"
osa="x86_64"

# sync os data
centos=(os updates extras)
for r in "${centos[@]}"; do
    repo=$r
    mirrors='http://mirrorlist.centos.org/?release='$osv'&arch='$osa'&repo='$r
    echo $mirrors

    curl $mirrors 2>/dev/null | tac |
    while read u; do
        url=
        nop=${u#*//}
        h=${nop%%/*}
        if nmap -p 873 $h 2>/dev/null | grep ^873 | grep -q open; then
            url=$(echo $u | sed 's,^\(http\|https\|ftp\)://,rsync://,')
        fi
        dst=/diskless/centos/$osv/$repo/$osa
        if [ ! -d "$dst" ]; then
            mkdir -p $dst
        fi
        if [ ! -z "$url" ]; then
            echo $url
            rsync -avkSH --delete $url --exclude drpms --chown=0:0 --chmod=F0644,D2755 $dst
            if [ $? -eq 0 ]; then
                break
            fi
        fi
    done
done