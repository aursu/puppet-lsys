Puppet::Type.newtype(:dhcp_host) do
  @doc = 'DHCP host declaration for PXE'

  ensurable

  newparam(:name, namevar: true) do
    desc 'DHCP host declaration name'
  end

  newproperty(:mac) do
    desc 'MAC address to send to the host'

    defaultto {
      warning _("newproperty :mac defaultto: #{caller}")
      provider.mac
    }

    def retrieve
      warning _("newproperty :mac retrieve: #{caller}")
      super
    end

    def insync?(is)
      warning _("newproperty :mac insync?(is=#{is}): #{caller}")
      super(is)
    end
  end

  newproperty(:ip) do
    desc 'IP address corresponded to mac field'

    defaultto { provider.ip }
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
  end

  autorequire(:vcsrepo) do
    ['/var/lib/pxe/enc']
  end
end
