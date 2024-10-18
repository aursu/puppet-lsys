## Some useful commands

### check if SSH server is up and running

```
systemctl start sshd
```

### run testing plan

```
bolt plan run lsys_tests::server -t puppetservers
```

### look for changed files

```
find / \( -path /sys \
  -o -path /dev \
  -o -path /proc \
  -o -path /run \
  -o -path /tmp \
  -o -path /var/cache \
  -o -path /var/lib/dnf \
  -o -path /var/lib/rpm \
  -o -path /var/log \
  -o -path /opt/puppetlabs \
  -o -path /root/puppet \) -prune -o -type f -mmin -10 -print
```