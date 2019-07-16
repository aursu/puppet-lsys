Puppet::Type.newtype(:dhcp_host) do
  @doc = 'DHCP host declaration for PXE'

  ensurable

  newparam(:name, namevar: true) do
    desc 'DHCP host declaration name'
  end

  newproperty(:mac) do
    desc 'MAC address to send to the host'

    defaultto { provider.pxe_data[:mac] }
  end

  newproperty(:ip) do
    desc 'IP address corresponded to mac field'

    defaultto { provider.pxe_data[:ip] }
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

    defaultto { provider.pxe_data[:content] }

    munge do |value|
      return nil if @resource[:ensure] == :absent
      value
    end
  end

  autorequire(:vcsrepo) do
    ['/var/lib/pxe/enc']
  end
end
