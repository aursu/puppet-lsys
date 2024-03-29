# @summary Manage CentOS  8 PowerTools repo
#
# Manage CentOS 8 PowerTools repo
#
# @example
#   include lsys::repo::powertools
#
# @param enabled
# @param baseurl
#
class lsys::repo::powertools (
  Boolean $enabled = true,
  # baseurl=http://mirror.centos.org/$contentdir/$releasever/PowerTools/$basearch/os/
  Optional[Stdlib::HTTPUrl] $baseurl = undef,
) inherits lsys::params {
  # Notice: /Stage[main]/Lsys::Repo::Powertools/Yumrepo[powertools]/descr: descr changed 'CentOS Stream $releasever - PowerTools' to 'CentOS Linux $releasever - PowerTools'
  # Notice: /Stage[main]/Lsys::Repo::Powertools/Yumrepo[powertools]/mirrorlist: mirrorlist changed 'http://mirrorlist.centos.org/?release=$stream&arch=$basearch&repo=PowerTools&infra=$infra' to 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=PowerTools&infra=$infra'
  if $facts['os']['family'] == 'RedHat' and $facts['os']['release']['major'] == '8' {
    $os_name = $lsys::params::repo_os_name

    if $baseurl {
      $source = {
        'baseurl' => $baseurl,
      }
    }
    else {
      $source = {
        'mirrorlist' => $lsys::params::repo_powertools_mirrorlist,
      }
    }

    yumrepo { 'powertools':
      *        => $source,
      ensure   => 'present',
      descr    => "${os_name} \$releasever - PowerTools",
      enabled  => '1',
      gpgcheck => '1',
      gpgkey   => $lsys::params::repo_gpgkey,
    }
  }
}
