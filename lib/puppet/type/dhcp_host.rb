Puppet::Type.newtype(:dhcp_host) do
  @doc = 'DHCP host declaration for PXE'

  ensurable

  def exists?
    [:hostname, :name].select { |k| provider.dhcp_data[k] == self[:name] }.any?
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

    defaultto { provider.pxe_data[:group] }
  end

  newproperty(:content) do
    desc 'DHCP host declaration content (read only)'

    defaultto { resource.host_content || provider.pxe_data[:content] }

    munge do |value|
      return nil if @resource[:ensure] == :absent
      value
    end

    # content property is autogenarated therefore always in sync
    def insync?(_is)
      true
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
      group: self[:group],
    )
  end
end
