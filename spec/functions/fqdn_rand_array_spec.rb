require 'spec_helper'

describe 'lsys::fqdn_rand_array' do
  context 'with array provided' do
    let(:facts) do
      {
        hostname: 'rapi4b',
      }
    end

    it {
      is_expected.to run
        .with_params(['debug', { 'ndots' => 2 }, 'timeout:20', 'rotate'])
        .and_return([{ 'ndots' => 2 }, 'timeout:20', 'debug', 'rotate'])
    }
  end
end
