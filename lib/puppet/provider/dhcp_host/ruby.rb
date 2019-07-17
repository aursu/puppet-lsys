require 'erb'

Puppet::Type.type(:dhcp_host).provide(:ruby, parent: Puppet::Provider) do
  DHCP_KEYS = [:mac, :ip, :name, :hostname, :group, :content].freeze

  # Need this to create getter/setter methods automagically
  # This command creates methods that return @property_hash[:value]
  mk_resource_methods

  def create
    @property_hash[:ensure] = :present
  end

  def destroy
    @property_hash[:ensure] = :absent
  end

  def dhcp_config_data(file_name)
    return @dhcp_hosts if @dhcp_hosts

    @dhcp_hosts = {}

    host = {}
    if File.exist?(file_name)
      File.open(file_name).each do |line|
        line.strip!
        # rubocop:disable Performance/RegexpMatch
        if %r{^host (?<name>\S+) \{$} =~ line
          host = { name: name }
          next
        end

        next unless host.include?(:name)

        if %r{^hardware ethernet (?<mac>\S+);$} =~ line
          host[:mac] = mac
        elsif %r{^fixed-address (?<ip>\S+);$} =~ line
          host[:ip] = ip
        elsif %r{^option host-name "(?<hostname>\S+)";$} =~ line
          host[:hostname] = hostname
        elsif %r{^\}$} =~ line
          @dhcp_hosts[host[:hostname]] = host if host.include?(:hostname)
          host = {}
        end
        # rubocop:enable Performance/RegexpMatch
      end
    end
    @dhcp_hosts
  end

  def dhcp_data
    return @dhcp if @dhcp

    target = @resource[:target] || '/etc/dhcp/dhcpd.hosts'
    hostname = @resource[:name]

    # lookup Hash for entities with :name or :hostname equal to
    # current @resource[:name]
    dhcp =  dhcp_config_data(target)
            .map { |_k, v| [v, v[:name], v[:hostname]] }
            .select { |d| d.include?(hostname) }
            .map { |d| [hostname, d[0]] }.to_h

    # return empty Hash if nothing found in DHCP config file
    return @dhcp = {} if dhcp.empty?
    @dhcp = dhcp[hostname]
  end

  # Read ENC data for given hostname
  # @api public
  # @return [Hash]
  def enc_data
    return @enc if @enc

    hostname = @resource[:name]

    Dir.glob("/var/lib/pxe/enc/#{hostname}.{eyaml,yaml,yml}").each do |file_name|
      @enc ||= self.class.enc_data(file_name)
    end

    # if file does not exists - set to only-hostname Hash and return
    @enc ||= { hostname: hostname }
  end

  # Generate PXE data based on read ENC data
  # @api public
  # @return [Hash]
  def pxe_data
    @pxe ||= self.class.pxe_data(enc_data)
  end

  # Generate DHCP host declaration based on provided PXE data
  # @api public
  # @return [String]
  def host_content(pxe)
    self.class.host_content(pxe)
  end

  def self.instances
    instances = []

    # read ENC data
    Dir.glob('/var/lib/pxe/enc/*.{eyaml,yaml,yml}').each do |file_name|
      enc = enc_data(file_name)
      pxe = pxe_data(enc)

      instance_hash = pxe.select { |k, _v| DHCP_KEYS.include?(k) }

      next unless instance_hash[:content]

      instance_hash[:ensure] = :present
      instance_hash[:provider] = name

      instances << new(instance_hash)
    end

    instances
  end

  private

  def self.enc_data(file_name)
    data = File.read(file_name)
    enc = YAML.safe_load(data).map { |k, v| [k.to_sym, v] }.to_h

    enc[:hostname] = %r{(?<hostname>[^/]+)\.e?ya?ml$}.match(file_name)[:hostname]

    enc
  end

  # @param enc [Hash] host data from ENC catalog
  # @return [Hash] hash of host parameters for dhcp_host resource initialization
  #                or an empty hash if we failed to parse ENC
  # @api private
  def self.pxe_data(enc)
    # mac  and ip are  mandatory parameters in ENC
    pxe = {}
    if enc.include?(:pxe) && enc[:pxe].is_a?(Hash)
      pxe = enc[:pxe].map { |k, v| [k.to_sym, v] }.to_h
    end

    # allow to use direct mac, ip parameters (but those inside "pxe" section
    # have higher priority).
    pxe[:mac] ||= enc[:mac]
    pxe[:ip] ||= enc[:ip]

    # IP mapping if any specified
    #
    # ip_map is Array of network MAC to IP mapping for DHCP client host
    # Element with index 0 is PXE interface
    ip_map = []
    if pxe[:mac] && pxe[:ip]
      # default DHCP group for PXE interface
      pxe[:group] = 'pxe' unless pxe.include?(:group)

      # it is required to support IP mapping
      # pxe key could contain mapping for up to 9 network interfaces, e.g.
      # pxe:
      #   mac1: xx:xx:xx:xx:xx:xx
      #   ip1: XX.XX.XX.XX
      #   group1: vlanXXX
      (0..9).each do |i|
        j = (i > 0) ? i : nil # rubocop:disable Style/NumericPredicate
        map_keys = ["mac#{j}", "ip#{j}", "group#{j}"].map(&:to_sym)
        next_map = [:mac, :ip, :group].zip(map_keys.map { |k| pxe[k] }).to_h

        # we are strict: if either mac<N> or ip<N> missed - ignore any
        # other mac<N+1> or ip<N+1>
        break unless next_map[:mac] && next_map[:ip]

        next_map[:group] = 'default' unless next_map[:group]

        ip_map[i] = next_map
      end
    end

    pxe[:name] = enc[:hostname]
    pxe[:hostname] = enc[:hostname]

    pxe.reject! { |k, v| !DHCP_KEYS.include?(k) || v.nil? }

    pxe[:content] = host_content(pxe)
    pxe[:ip_map] = ip_map unless ip_map.empty?

    pxe
  end

  def self.host_content(pxe)
    [:name, :mac, :ip, :hostname].each do |k|
      return nil unless pxe.include?(k)
    end

    name     = pxe[:name]
    mac      = pxe[:mac]
    ip       = pxe[:ip]
    hostname = pxe[:hostname]

    ERB.new(<<-EOF).result(binding).strip
host <%= name %> {
  hardware ethernet <%= mac %>;
  fixed-address <%= ip %>;
  option host-name "<%= hostname %>";
}
EOF
  end
end
