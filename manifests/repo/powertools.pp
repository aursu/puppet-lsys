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
  Stdlib::HTTPUrl
          $mirrorlist = $lsys::params::repo_powertools_mirrorlist,
  String  $os_name    = $lsys::params::repo_os_name,
) inherits lsys::params {
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

  # Notice: /Stage[main]/Lsys::Repo::Powertools/Yumrepo[powertools]/descr: descr changed 'CentOS Stream $releasever - PowerTools' to 'CentOS Linux $releasever - PowerTools'
  # Notice: /Stage[main]/Lsys::Repo::Powertools/Yumrepo[powertools]/mirrorlist: mirrorlist changed 'http://mirrorlist.centos.org/?release=$stream&arch=$basearch&repo=PowerTools&infra=$infra' to 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=PowerTools&infra=$infra'

  if $facts['os']['name'] in ['RedHat', 'CentOS'] and $facts['os']['release']['major'] in ['8'] {
    yumrepo { 'powertools':
      *        => $source,
      ensure   => 'present',
      descr    => "${os_name} \$releasever - PowerTools",
      enabled  => '1',
      gpgcheck => '1',
      gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
    }
  }
}
