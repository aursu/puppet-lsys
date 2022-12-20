# VMWare vSphere Perl SDK installation
#
# @summary VMWare vSphere Perl SDK installation
# @example
#   include lsys::vmware::sdk
#
# @param package_ensure
#
class lsys::vmware::sdk (
  String $package_ensure = '6.7.0-8156551.el7.1',
) {
  include lsys::repo::bintray
  include lsys::repo::epel

  if $facts['os']['name'] in ['RedHat', 'CentOS'] and $facts['os']['release']['major'] in ['7'] {
    package { 'VMware-vSphere-Perl-SDK':
      ensure          => $package_ensure,
      install_options => [
        { '--enablerepo' => 'bintray-custom' },
      ],
      require         => [
        Yumrepo['bintray-custom'],
        Package['epel-release'],
      ],
    }
  }
}
