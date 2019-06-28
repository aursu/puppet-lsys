require 'spec_helper'

describe 'lsys::registry' do
  let(:facts) do
    {
      'stype' => 'web'
    }
  end

  let(:pre_condition) do
    <<-PRECOND
    tlsinfo::certificate { 'f1453246': }
    PRECOND
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        super().merge(os_facts)
      end

      let(:params) do
        {
          'server_name' => 'registry.domain.tld'
        }
      end

      it { is_expected.to compile }
    end
  end
end
