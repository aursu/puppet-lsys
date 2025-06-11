require 'spec_helper'

describe 'lsys::gitlab::registry' do
  let(:params) do
    {
      server_name: 'registry.example.com',
    }
  end

  it { is_expected.to compile }
  it { is_expected.to contain_class('dockerinstall::registry::base') }
  it { is_expected.to contain_class('dockerinstall::profile::registry') }

  context 'with auth_token_enable => true' do
    let(:params) do
      super().merge(auth_token_enable: true)
    end

    it { is_expected.to contain_class('dockerinstall::registry::auth_token').with(enable: true, gitlab: true) }
  end
end