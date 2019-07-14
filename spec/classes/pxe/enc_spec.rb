require 'spec_helper'

describe 'lsys::pxe::enc' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          repo_source: 'https://github.com/aursu/control-enc.git',
        }
      end


      it { is_expected.to compile }
    end
  end
end
