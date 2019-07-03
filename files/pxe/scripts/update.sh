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

# EPEL
repo=epel
mirrors='https://mirrors.fedoraproject.org/metalink?repo=epel-'$osb'&arch='$osa

curl $mirrors 2>/dev/null |
sed -n '/protocol="rsync"/s/<[^>]*>//gp' |  sed 's/[[:space:]]*//g; s,repodata/repomd.xml,,g' |
while read u; do
    url=
    nop=${u#*//}
    h=${nop%%/*}
    if nmap -p 873 $h | grep ^873 | grep -q open; then
        url=$(echo $u | sed 's,^\(http\|https\|ftp\)://,rsync://,')
    fi
    dst=/diskless/centos/$osv/$repo/$osa/Packages
    if [ ! -d "$dst" ]; then
        mkdir -p $dst
    fi
    if [ ! -z "$url" ]; then
        echo $url
        rsync -avkSH --delete --exclude repodata --exclude repoview --exclude debug --chown=0:0 --chmod=F0644,D2755 $url $dst/
        if [ $? -eq 0 ]; then
            break
        fi
    fi
done

# rpm forge
repo=rpmforge
mirrors='http://mirrorlist.repoforge.org/el'$osb'/mirrors-rpmforge'

rpmforge=(dag rpmforge)
url=
while [ -z "$url" ]; do
    while read u; do
        url=
        nop=${u#*//}
        h=${nop%%/*}
        if nmap -p 873 $h | grep ^873 | grep -q open; then
            url=$(echo $u | sed 's,^\(http\|https\|ftp\)://,rsync://,')
        fi
        dst=/diskless/centos/$osv/rpmforge/$osa
        if [ ! -d "$dst" ]; then
            mkdir -p $dst
        fi
        if [ ! -z "$url" ]; then
            status=
            for r in "${rpmforge[@]}"; do
                echo ${url}/$r
                rsync -avkSH --delete --exclude repodata --exclude repoview --chown=0:0 --chmod=F0644,D2755 ${url}/$r $dst/
                status=$?
            done
            if [ "${status}x" == "0x" ]; then
                break
            fi
        fi
    done < <(curl $mirrors 2>/dev/null |
    sed "s/\$ARCH/$osa/g" | sed 's,/rpmforge$,,g')
done