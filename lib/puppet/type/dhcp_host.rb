Puppet::Type.newtype(:dhcp_host) do
  @doc = 'DHCP host declaration for PXE'

  newproperty(:name, namevar: true) do
    desc 'DHCP host declaration name'
  end

  newproperty(:mac) do
    desc 'MAC address to send to the host'
  end

  newproperty(:ip) do
    desc 'IP address corresponded to mac field'
  end

  newproperty(:hostname) do
    desc 'DHCP option host-name'
  end

  newparam(:group) do
    desc 'Name of DHCP group which host belongs to'

    defaultto { 'general' }
  end

  newproperty(:content) do
    desc 'DHCP host declaration content (read only)'
  end

  autorequire(:vcsrepo) do
    ['/var/lib/pxe/enc']
  end

  autorequire(:concat_file) do
    ['/etc/dhcp/dhcpd.pools']
  end
end
