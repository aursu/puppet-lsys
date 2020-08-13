require 'spec_helper'

describe 'lsys::httpd' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      if ['redhat-7-x86_64', 'centos-7-x86_64'].include?(os)
        context 'with default parameters check user/group management' do
          it {
            is_expected.to contain_user('apache')
          }

          it {
            is_expected.to contain_group('apache')
          }
        end

        context 'when user management disabled' do
          let(:params) do
            {
              manage_user: false,
            }
          end

          it {
            is_expected.not_to contain_user('apache')
          }
        end

        context 'when group management disabled' do
          let(:params) do
            {
              manage_group: false,
            }
          end

          it {
            is_expected.not_to contain_group('apache')
          }
        end
      end
    end
  end
end
