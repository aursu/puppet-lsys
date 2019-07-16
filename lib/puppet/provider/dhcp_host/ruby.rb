require 'erb'

Puppet::Type.type(:dhcp_host).provide(:ruby, parent: Puppet::Provider) do
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
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  # Does the given ENC PXE settings already exist?
  #
  # @api public
  # @return [Boolean]
  def exists?
    @property_hash[:ensure] == :present
  end

  def enc_data(file_name)
    return @enc if @enc

    hostname = @resource[:name]

    Dir.glob("/var/lib/pxe/enc/#{hostname}.{eyaml,yaml,yml}").each do |file_name|
      @enc ||= self.class.enc_data(file_name)
    end

    @enc
  end

  def pxe_data(enc)
    @pxe ||= self.class.pxe_data(pxe)
  end

  def self.instances
    instances = []

    # read ENC data
    Dir.glob('/var/lib/pxe/enc/*.{eyaml,yaml,yml}').each do |file_name|
      enc = enc_data(file_name)
      instance_hash = pxe_data(enc)
      if instance_hash[:content]
        instance_hash[:provider] = name
        instances << new(instance_hash)
      end
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
  #                or an empty hash if we failed to parse
  # @api private
  def self.pxe_data(enc)
    dhcp_keys = [:mac, :ip, :name, :hostname, :group]

    # mac  and ip are  mandatory parameters in ENC
    pxe = {}
    if enc.include?(:pxe)
      pxe = enc[:pxe].map { |k, v| [k.to_sym, v] }.to_h
    end

    # allow to use direct mac, ip parameters
    pxe[:mac] ||= enc[:mac]
    pxe[:ip] ||= enc[:ip]

    pxe[:name] = enc[:hostname]
    pxe[:hostname] = enc[:hostname]

    pxe.reject! { |k, v| !dhcp_keys.include?(k) || v.nil? }

    pxe[:content] = host_content(pxe)

    if pxe[:content]
      pxe[:ensure] = :present
      warning _("Information about host: #{pxe}")
    end

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

    ERB.new(<<-EOF).result(binding)
  host <%= name %> {
    hardware ethernet <%= mac %>;
    fixed-address <%= ip %>;
    option host-name "<%= hostname %>";
  }
EOF
  end
end
