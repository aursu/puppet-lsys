require 'socket'
require 'securerandom'
require 'digest/md5'

Puppet::Functions.create_function(:'lsys::fqdn_rand_array') do
  dispatch :fqdn_rand_array do
    param 'Array[Any]', :data
    optional_param 'Integer', :rand_max
  end

  def rand_int(max, *args)
    hostname = Facter.value(:hostname)
    seed = Digest::MD5.hexdigest([hostname, max, *args].join(':')).hex
    Random.new(seed).rand(max)
  end

  # 4 bytes unnsigned int maximum
  def fqdn_rand_array(data, rand_max = 2**32)
    data.sort_by { |e| rand_int(rand_max, e.to_s) }
  end
end
