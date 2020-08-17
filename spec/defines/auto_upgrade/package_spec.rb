# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::auto_upgrade::package' do
  let(:title) { 'namevar' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_package('namevar')
          .with_ensure('latest')
          .with_install_options([])
          .without_provider
      }

      context 'with corporate repo set' do
        let(:params) do
          super().merge(
            corporate_repo: 'corp',
          )
        end

        if ['redhat-8-x86_64', 'centos-8-x86_64'].include?(os)
          context 'when CentOS 8' do
            it {
              is_expected.to contain_package('namevar')
                .with_ensure('latest')
                .with_install_options(['--repo', 'corp'])
                .with_provider('dnf')
            }
          end
        elsif ['redhat-7-x86_64', 'centos-7-x86_64'].include?(os)
          context 'when CentOS 7' do
            it {
              is_expected.to contain_package('namevar')
                .with_ensure('latest')
                .with_install_options(['--disablerepo', '*', '--enablerepo', 'corp'])
                .with_provider('yum')
            }
          end
        end
      end
    end
  end
end
