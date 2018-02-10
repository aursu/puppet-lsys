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
Facter.add(:is_init_systemd) do
  setcode do
    osfamily = Facter.value(:osfamily)
    osname = Facter.value(:operatingsystem)
    osmaj = Facter.value(:operatingsystemmajrelease)
    if osname.casecmp("Fedora") == 0 or (osfamily.casecmp("RedHat") and osmaj.to_i >= 7)
        true
    end
    false
  end
end