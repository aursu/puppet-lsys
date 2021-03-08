# @summary Manage CentOS  8 PowerTools repo
#
# Manage CentOS 8 PowerTools repo
#
# @example
#   include lsys::repo::powertools
class lsys::repo::powertools (
  Boolean $enabled    = true,
  # baseurl=http://mirror.centos.org/$contentdir/$releasever/PowerTools/$basearch/os/
  Optional[Stdlib::HTTPUrl]
          $baseurl    = undef,
  Optional[Stdlib::HTTPUrl]
          $mirrorlist = 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=PowerTools&infra=$infra',
)
{
  if $baseurl {
    $source = {
      'baseurl' => $baseurl,
    }
  }
  elsif $mirrorlist {
    $source = {
      'mirrorlist' => $mirrorlist,
    }
  }

  if $facts['os']['name'] in ['RedHat', 'CentOS'] and $facts['os']['release']['major'] in ['8'] {
    yumrepo { 'powertools':
      *        => $source,
      ensure   => 'present',
      descr    => 'CentOS Linux $releasever - PowerTools',
      enabled  => $enabled,
      gpgcheck => '1',
      gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
    }
  }
}
