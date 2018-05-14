# Fact: is_init_systemd
#
# Purpose: check if OS init system is systemd
#
# Resolution:
#   Supports only RedHat (initially). Check OS type and version and return
#   Boolean result
#
# Caveats:
#   none
#
# Notes:
#   None
osfamily = Facter.value(:osfamily).to_s
osname = Facter.value(:operatingsystem).to_s
osmaj = Facter.value(:operatingsystemmajrelease).to_i
osrel = Facter.value(:operatingsystemrelease).to_s

status = osname.casecmp('Fedora').zero? ||
         (osfamily.casecmp('RedHat').zero? && osmaj >= 7) ||
         (osname.casecmp('Ubuntu').zero? && Puppet::Util::Package.versioncmp(osrel, '15.04') >= 0)

Facter.add(:is_init_systemd) do
  setcode do
    status
  end
end
