Puppet::Type.newtype(:dhcp_host) do
  @doc = 'DHCP host declaration for PXE'

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, namevar: true) do
    desc 'DHCP host declaration name'
  end

  newproperty(:mac) do
    desc 'MAC address to send to the host'

    def retrieve
      provider.pxe[:mac]
    end
  end

  newproperty(:ip) do
    desc 'IP address corresponded to mac field'

    def retrieve
      provider.pxe[:ip]
    end
  end

  newproperty(:hostname) do
    desc 'DHCP option host-name'

    defaultto { @resource[:name] }
  end

  newparam(:group) do
    desc 'Name of DHCP group which host belongs to'

    defaultto 'default'
  end

  newproperty(:content) do
    desc 'DHCP host declaration content (read only)'

    def retrieve
      provider.pxe[:content]
    end
  end

  autorequire(:vcsrepo) do
    ['/var/lib/pxe/enc']
  end

  autorequire(:concat_file) do
    ['/etc/dhcp/dhcpd.pools']
  end
end
