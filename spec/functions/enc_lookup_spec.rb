require 'spec_helper'

describe 'lsys::enc_lookup' do
  context 'with default rspec setup' do
    it {
      is_expected.to run.with_params('hostname.domain.com').and_return({})
    }
  end
end
