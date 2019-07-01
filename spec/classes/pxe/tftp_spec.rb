require 'spec_helper'

describe 'lsys::pxe::tftp' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('/etc/xinetd.d/tftp')
          .with_content(%r{^\s+disable\s+=\s+no$})
      }

      it {
        is_expected.to contain_file('/etc/xinetd.d/tftp')
          .with_content(%r{^\s+server_args\s+=\s+-s /var/lib/tftpboot$})
      }

      context 'when tftp server disabled' do
        let(:params) do
          {
            service_enable: false,
          }
        end

        it {
          is_expected.to contain_file('/etc/xinetd.d/tftp')
            .with_content(%r{^\s+disable\s+=\s+yes$})
        }
      end

      context 'when tftp server disabled' do
        let(:params) do
          {
            verbose: true,
          }
        end

        it {
          is_expected.to contain_file('/etc/xinetd.d/tftp')
            .with_content(%r{^\s+server_args\s+=\s+-s /var/lib/tftpboot --verbose$})
        }
      end
    end
  end
end
