Puppet::Functions.create_function(:'lsys::enc_lookup') do
  dispatch :enc_lookup do
    param 'Stdlib::Fqdn', :hostname
  end

  def certpath(hostname)
    Puppet.settings
  end
end