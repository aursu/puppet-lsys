require 'spec_helper'

describe 'lsys::fqdn_rand_array' do
  context 'with array provided' do
    it {
      allow(Socket).to receive(:gethostname).and_return('rapi4b')

      is_expected.to run
        .with_params(['debug', { 'ndots' => 2 }, 'timeout:20', 'rotate'])
        .and_return([{ 'ndots' => 2 }, 'timeout:20', 'debug', 'rotate'])
    }
  end
end
