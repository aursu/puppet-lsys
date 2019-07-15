require 'erb'

Puppet::Type.newtype(:dhcp_group) do
  @doc = <<-DOC
    @summary
      Generates a file with content from DHCP hosts fragments sharing common group.

    @example

      dhcp_group { 'vlan400':
        host_decl_names  => true,
        pxe_settings     => true,
        next_server      => '10.100.20.10',
        tftp_server_name => false,
        pxe_filename     => 'boot/grub/i386-pc/core.0'
      }

      dhcp_host { 'webserv.domain.tld':
        group => 'vlan400',
      }

    @param host_decl_names
      Whether to add dhcpd parameter 'use-host-decl-names on' into group. Valid
      values are `true`, `false`. Default to `false`.
      See "The use-host-decl-names statement" on
      https://kb.isc.org/docs/isc-dhcp-41-manual-pages-dhcpdconf

    @param pxe_settings
      Whether to enable DHCPD PXE settings for group. Valid values are `true`,
      `false`. Default to `false`.

    @param next_server
      Whether to add dhcp parameter "next-server" into group PXE setings. Default
      to undef. See "The next-server statement" on
      https://kb.isc.org/docs/isc-dhcp-41-manual-pages-dhcpdconf

    @param tftp_server_name
      If set to true will add DHCP option "tftp-server-name" additionally to
      parameter "next-server". It depends on parameter next_server above
      See "option tftp-server-name" on
      https://kb.isc.org/docs/isc-dhcp-44-manual-pages-dhcp-options

    @param pxe_filename

      Whether to add dhcp parameter "filename" into group PXE setings.
      See "The filename statement" on
      https://kb.isc.org/docs/isc-dhcp-41-manual-pages-dhcpdconf

  DOC

  ensurable do
    desc <<-DOC
      Specifies whether the destination file should exist. Setting to 'absent' tells Puppet to delete the destination file if it exists, and
      negates the effect of any other parameters.
    DOC

    defaultvalues

    defaultto { :present }
  end

  def exists?
    self[:ensure] == :present
  end

  newparam(:name, namevar: true) do
    desc <<-DOC
      Group name. By default is equal to Dhcp_group resource title
    DOC
  end

  newparam(:target) do
    desc <<-DOC
      Optional. Default is /etc/dhcp/dhcpd.pools. Specifies the destination file of the
      generated Contact_fragment resources.
    DOC

    defaultto '/etc/dhcp/dhcpd.pools'

    validate do |value|
      raise ArgumentError, _('Target must be a full path') unless Puppet::Util.absolute_path?(value)
    end
  end

  newparam(:order) do
    desc <<-DOC
      Order of generated Contact_fragment within the destination file.
    DOC

    defaultto '20'

    munge do |val|
      val.to_i.to_s
    end

    validate do |val|
      raise Puppet::ParseError, _('$order is not a string or integer.') unless val.is_a?(String) || val.is_a?(Integer)
      raise Puppet::ParseError, _('Order is not a numerical value') if val.to_s !~ %r{[0-9]+}
    end
  end

  autorequire(:dhcp_host) do
    found = catalog.resources.select do |resource|
      next unless resource.is_a?(Puppet::Type.type(:dhcp_host))

      resource[:group] == self[:name] || resource[:group] == title ||
        (title == 'default' && resource[:group].nil?)
    end

    if found.empty?
      warning "Target Dhcp_host with group '#{title}' not found in the catalog"
    end
  end

  autorequire(:concat_file) do
    [self[:target]]
  end

  def fragments
    # @fragments ||= catalog.resources.map { |resource|
    #   next unless resource.is_a?(Puppet::Type.type(:dhcp_host))

    #   if resource[:group] == self[:name] || resource[:group] == title ||
    #      (title == 'default' && resource[:group].nil?)
    #     resource
    #   end
    # }.compact

    @fragments ||= Puppet::Type.type(:dhcp_host).instances.
      select { |resource|
        resource[:group] == self[:name] || resource[:group] == title ||
          (title == 'default' && resource[:group].nil?)
      }
  end

  def should_content
    return @generated_content if @generated_content

    @generated_content = ''

    content_fragments = []
    fragments.each do |r|
      content_fragments << [r[:name], r[:content]]
    end

    sorted = content_fragments.sort_by { |a| a[0] }

    newline = Puppet::Util::Platform.windows? ? "\r\n" : "\n"
    hosts = sorted.map { |cf| cf[1] }.join(newline)

    host_decl_names = false
    pxe_settings = false
    next_server = nil
    tftp_server_name = true
    pxe_filename = nil

    @generated_content = ERB.new(<<-EOF).result(binding)
group {
<% if host_decl_names %>
  use-host-decl-names on;
<% end %>
<% if pxe_settings %>
  if ( substring (option vendor-class-identifier, 0, 9) = "PXEClient" ) {
<%   if next_server %>
    next-server <%= next_server %>;
<%     if tftp_server_name %>
    option tftp-server-name "<%= next_server %>";
<%     end %>
<%   end %>
<%   if pxe_filename %>
    filename "<%= pxe_filename %>";
<%   end %>
  }

<% end %>
<%= hosts %>
}
EOF

    @generated_content
  end

  def generate
    return [] if self[:ensure] == :absent

    concat_fragment_opts = {
      name: "dhcp_group_#{title}",
      target: self[:target],
      order: self[:order],
      content: should_content
    }

    metaparams = Puppet::Type.metaparams
    excluded_metaparams = [:before, :notify, :require, :subscribe, :tag]

    metaparams.reject! { |param| excluded_metaparams.include? param }

    metaparams.each do |metaparam|
      concat_fragment_opts[metaparam] = self[metaparam] unless self[metaparam].nil?
    end

    [Puppet::Type.type(:concat_fragment).new(concat_fragment_opts)]
  end

  def eval_generate
    [catalog.resource("Concat_fragment[dhcp_group_#{title}]")]
  end
end
