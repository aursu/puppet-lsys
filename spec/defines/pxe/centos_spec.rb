require 'spec_helper'

describe 'lsys::pxe::centos' do
  let(:title) { '7.6.1810' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      ['6', '7', '6.6', '6.9', '6.10', '7.0.1406', '7.4.1708'].each do |centos|
        context "with CentOS version #{centos}" do
          let(:title) { centos }

          it { is_expected.to compile }
        end
      end
    end
  end
end
