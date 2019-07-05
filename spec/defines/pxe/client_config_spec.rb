require 'spec_helper'

describe 'lsys::pxe::client_config' do
  let(:title) { 'namevar' }
  let(:params) do
    {
      install_server: 'bsys.domain.tld'
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('/var/lib/pxe/namevar.cfg')
          .with_content(%r{^set options='ip=dhcp ksdevice= inst.ks=http://bsys.domain.tld/ks/default.cfg net.ifnames=0 biosdevname=0'$})
      }

      ['6', '7', '6.6', '6.9', '6.10', '7.0.1406', '7.4.1708'].each do |centos|
        context "with CentOS version #{centos}" do
          let(:params) do
            super().merge(
              centos_version: centos
            )
          end

          it { is_expected.to compile }
        end
      end
    end
  end
end
