Puppet::Type.newtype(:dhcp_host) do
  @doc = 'DHCP host declaration for PXE'

  ensurable

  def exists?
    [:hostname, :name].select { |k| provider.dhcp_data[k] == self[:name] }.any?
  end

  newparam(:name, namevar: true) do
    desc 'DHCP host declaration name'

    validate do |val|
      fail Puppet::ParseError, _('dhcp_host :name must be a string') unless val.is_a?(String)
      fail Puppet::ParseError, _('dhcp_host :name must be a valid hostname') unless resource.validate_hostname(val)
    end

    munge do |val|
      val.downcase
    end
  end

  newproperty(:mac) do
    desc 'MAC address to send to the host'

    defaultto { provider.pxe_data[:mac] }

    validate do |val|
      fail Puppet::ParseError, _('dhcp_host :mac must be a string') unless val.is_a?(String)
      fail Puppet::ParseError, _('dhcp_host :mac must be a valid MAC address') unless provider.validate_mac(val)
    end

    munge do |val|
      val.downcase.tr('-', ':')
    end

    def retrieve
      provider.dhcp_data[:mac]
    end
  end

  newproperty(:ip) do
    desc 'IP address corresponded to mac field'

    defaultto { provider.pxe_data[:ip] }

    validate do |val|
      fail Puppet::ParseError, _('dhcp_host :ip must be a string') unless val.is_a?(String)
      fail Puppet::ParseError, _('dhcp_host :ip must be a valid IPv4 address') unless provider.validate_ip(val)
    end

    def retrieve
      provider.dhcp_data[:ip]
    end
  end

  newproperty(:hostname) do
    desc 'DHCP option host-name'

    defaultto { @resource[:name] }

    validate do |val|
      fail Puppet::ParseError, _('dhcp_host :hostname must be a string') unless val.is_a?(String)
      fail Puppet::ParseError, _('dhcp_host :hostname must be a valid hostname') unless resource.validate_hostname(val)
    end

    munge do |val|
      # this is a trick - we accept only hostname in form of FQDN
      return nil unless provider.validate_domain(val)
      val.downcase
    end

    def retrieve
      provider.dhcp_data[:hostname]
    end
  end

  newparam(:group) do
    desc 'Name of DHCP group which host belongs to'

    defaultto { provider.pxe_data[:group] }

    munge do |val|
      # default group for wrong values is 'default'
      return 'default' unless val.is_a?(String)
      val.downcase.gsub(%r{[^a-z0-9]}, '_')
    end
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
    desc 'Path to DHCP file where configuration should be looked for'

    defaultto '/etc/dhcp/dhcpd.hosts'

    validate do |value|
      raise ArgumentError, _('Target must be a full path') unless Puppet::Util.absolute_path?(value)
    end
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

  def validate_hostname(host)
    return nil unless host
    %r{^([a-z0-9]+(-[a-z0-9]+)*\.?)+[a-z0-9]{2,}$} =~ host.downcase
  end
end
