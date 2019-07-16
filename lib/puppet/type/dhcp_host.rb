Puppet::Type.newtype(:dhcp_host) do
  @doc = 'DHCP host declaration for PXE'

  ensurable do
    defaultvalues

    def retrieve
      return :present if provider.dhcp_data[:hostname] == @resource[:name] ||
        provider.dhcp_data[:name] == @resource[:name]
      :absent
    end
  end

  newparam(:name, namevar: true) do
    desc 'DHCP host declaration name'
  end

  newproperty(:mac) do
    desc 'MAC address to send to the host'

    defaultto { provider.pxe_data[:mac] }

    def retrieve
      provider.dhcp_data[:mac]
    end
  end

  newproperty(:ip) do
    desc 'IP address corresponded to mac field'

    defaultto { provider.pxe_data[:ip] }

    def retrieve
      provider.dhcp_data[:ip]
    end
  end

  newproperty(:hostname) do
    desc 'DHCP option host-name'

    defaultto { @resource[:name] }

    def retrieve
      provider.dhcp_data[:hostname]
    end
  end

  newparam(:group) do
    desc 'Name of DHCP group which host belongs to'

    defaultto 'default'
  end

  newproperty(:content) do
    desc 'DHCP host declaration content (read only)'

    defaultto { provider.pxe_data[:content] || resource.host_content }

    munge do |value|
      return nil if @resource[:ensure] == :absent
      value
    end

    def retrieve
      provider.dhcp_data[:content]
    end
  end

  newparam(:target) do
    desc 'Path to DHCP file where configuration should be located'

    defaultto '/etc/dhcp/dhcpd.hosts'
  end

  autorequire(:vcsrepo) do
    ['/var/lib/pxe/enc']
  end

  def host_content
    provider.host_content(
      mac: self[:mac],
      ip: self[:ip],
      name: self[:name],
      hostname: self[:hostname],
    )
  end
end
