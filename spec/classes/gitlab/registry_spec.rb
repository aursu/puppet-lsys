require 'spec_helper'

describe 'lsys::gitlab::registry' do
  let(:pre_condition) do
    <<-PRECOND
    include dockerinstall
    tlsinfo::certificate { 'f1453246': }
    PRECOND
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(stype: 'web') }
      let(:params) do
        {
          server_name: 'registry.domain.tld',
          gitlab_server_name: 'ci.domain.tld',
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
  end
end
