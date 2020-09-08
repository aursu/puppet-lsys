require 'spec_helper'

describe 'lsys::nginx' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      case os
      when 'redhat-8-x86_64', 'centos-8-x86_64'
        it {
          is_expected.to contain_package('nginx')
            .with_ensure(%r{\.el8})
            .with_provider('dnf')
            .with_install_options(['--repo', 'nginx-release'])
        }
      end
    end
  end
end
