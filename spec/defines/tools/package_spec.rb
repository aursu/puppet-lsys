# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::tools::package' do
  let(:title) { 'sudo' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.not_to contain_package('sudo') }

      context 'check boolean ensure => false' do
        let(:params) { { ensure: false } }

        it { is_expected.not_to contain_package('sudo') }
      end

      context 'check boolean ensure => true' do
        let(:params) { { ensure: true } }

        it { is_expected.to contain_package('sudo').with_ensure('installed') }
      end

      context 'check string ensure => latest' do
        let(:params) { { ensure: 'latest' } }

        it { is_expected.to contain_package('sudo').with_ensure('latest') }

        it {
          is_expected.to contain_package('sudo')
            .with_ensure('latest')
            .with_install_options([])
        }
      end

      context 'check string ensure => numeric' do
        let(:params) { { ensure: '1.8.23-10.el7_9.1' } }

        it { is_expected.to contain_package('sudo').with_ensure('1.8.23-10.el7_9.1') }
      end

      context 'install options is set to single repo' do
        let(:params) do
          {
            ensure: 'latest',
            corporate_repo: 'corp',
          }
        end

        if ['redhat-8-x86_64', 'centos-8-x86_64'].include?(os)
          context 'when CentOS 8' do
            it {
              is_expected.to contain_package('sudo')
                .with_ensure('latest')
                .with_install_options(['--repo', 'corp'])
                .with_provider('dnf')
            }
          end
        elsif ['redhat-7-x86_64', 'centos-7-x86_64'].include?(os)
          context 'when CentOS 7' do
            it {
              is_expected.to contain_package('sudo')
                .with_ensure('latest')
                .with_install_options(['--disablerepo', '*', '--enablerepo', 'corp'])
                .with_provider('yum')
            }
          end
        end

        context 'and not only corporate repos' do
          let(:params) do
            super().merge(
              corporate_repo_only: false,
            )
          end

          if ['redhat-8-x86_64', 'centos-8-x86_64'].include?(os)
            context 'when CentOS 8' do
              it {
                is_expected.to contain_package('sudo')
                  .with_ensure('latest')
                  .with_install_options(['--enablerepo', 'corp'])
                  .with_provider('dnf')
              }
            end
          elsif ['redhat-7-x86_64', 'centos-7-x86_64'].include?(os)
            context 'when CentOS 7' do
              it {
                is_expected.to contain_package('sudo')
                  .with_ensure('latest')
                  .with_install_options(['--enablerepo', 'corp'])
                  .with_provider('yum')
              }
            end
          end
        end
      end

      context 'install options is set to multiple repo' do
        let(:params) do
          {
            ensure: 'latest',
            corporate_repo: ['corp', 'intern'],
          }
        end

        if ['redhat-8-x86_64', 'centos-8-x86_64'].include?(os)
          context 'when CentOS 8' do
            it {
              is_expected.to contain_package('sudo')
                .with_ensure('latest')
                .with_install_options(['--repo', 'corp', '--repo', 'intern'])
                .with_provider('dnf')
            }
          end
        elsif ['redhat-7-x86_64', 'centos-7-x86_64'].include?(os)
          context 'when CentOS 7' do
            it {
              is_expected.to contain_package('sudo')
                .with_ensure('latest')
                .with_install_options(['--disablerepo', '*', '--enablerepo', 'corp', '--enablerepo', 'intern'])
                .with_provider('yum')
            }
          end
        end
      end
    end
  end
end
