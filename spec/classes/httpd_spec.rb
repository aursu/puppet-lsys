require 'spec_helper'

describe 'lsys::httpd' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      if os_facts[:os]['family'] == 'RedHat'
        context 'document root configuration' do
          it {
            is_expected.to contain_file('apache_docroot')
              .with_path('/etc/httpd/conf.d/00-docroot.conf')
              .with_content(%r{^DocumentRoot /var/www/html$})
          }
        end

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
