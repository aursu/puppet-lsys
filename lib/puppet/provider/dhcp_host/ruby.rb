require 'erb'

Puppet::Type.type(:dhcp_host).provide(:ruby, parent: Puppet::Provider) do
  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  # Need this to create getter/setter methods automagically
  # This command creates methods that return @property_hash[:value]
  mk_resource_methods

  # Prefetching is necessary to use @property_hash inside any setter methods.
  # self.prefetch uses self.instances to gather an array of pxe_dhcp instances
  # on the system, and then populates the @property_hash instance variable
  # with attribute data for the specific instance in question (i.e. it
  # gathers the 'is' values of the resource into the @property_hash instance
  # variable so you don't have to read from the system every time you need
  # to gather the 'is' values for a resource. The downside here is that
  # populating this instance variable for every resource on the system
  # takes time and front-loads your Puppet run.
  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov
      end
    end
  end

  def self.instances
    instances = []

    # DHCP data
    dhcp_hosts = {}
    host = {}
    if File.exist?('/etc/dhcp/dhcpd.pools')
      File.open('/etc/dhcp/dhcpd.pools').each do |line|
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
          dhcp_hosts[host[:hostname]] = host if host.include?(:hostname)
          host = {}
        end
        # rubocop:enable Performance/RegexpMatch
      end
    end

    # read ENC data
    Dir.glob('/var/lib/pxe/enc/*.{eyaml,yaml,yml}').each do |name|
      hostname = %r{(?<hostname>[^/]+)e?ya?ml$}.match(name)[:hostname]
      data = File.read(name)

      enc = YAML.safe_load(data).map { |k, v| [k.to_sym, v] }.to_h
      enc[:hostname] = hostname

      pxe = merge_host_data(enc, dhcp_hosts[hostname])
      if pxe[:mac] && pxe[:ip]
        instances << new(pxe)
      end
    end

    instances
  end

  private

  # @param enc [Hash] host data from ENC catalog
  # @param dhcp [Hash] host data from DHCPd config
  # @return [Hash] hash of host parameters for dhcp_host resource initialization
  # or an empty hash if we failed to parse
  # @api private
  def self.merge_host_data(enc, dhcp)
    dhcp = {} if dhcp.nil?
    dhcp_keys = [:mac, :ip, :name, :hostname, :group]

    # mac  and ip are  mandatory parameters in ENC
    pxe = {}
    if enc.include?(:pxe)
      pxe = enc[:pxe].map { |k, v| [k.to_sym, v] }.to_h
    end

    # allow to use direct mac, ip parameters
    pxe[:mac] ||= enc[:mac]
    pxe[:ip] ||= enc[:ip]

    pxe[:name] = dhcp[:name] || enc[:hostname]
    pxe[:hostname] = enc[:hostname]

    pxe.reject! { |k, v| !dhcp_keys.include?(k) || v.nil? }

    pxe[:content] = generate_content(pxe)
    warning _("Information about host: #{pxe}")

    pxe[:provider] = name

    pxe
  end

  def self.generate_content(pxe)
    [:name, :mac, :ip, :hostname].each do |k|
      return nil unless pxe.include?(k)
    end

    name     = pxe[:name]
    mac      = pxe[:mac]
    ip       = pxe[:ip]
    hostname = pxe[:hostname]

    ERB.new(<<-EOF).result(binding)
  host <%= name %> {
    hardware ethernet <%= mac %>;
    fixed-address <%= ip %>;
    option host-name "<%= hostname %>";
  }
  EOF
  end
end
