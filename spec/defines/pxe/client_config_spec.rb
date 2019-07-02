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
        is_expected.to contain_file('/var/lib/tftpboot/boot/install/namevar.cfg')
          .with_content(%r{^set options='ip=dhcp ksdevice= inst.ks=http://bsys.domain.tld/ks/default.cfg net.ifnames=0 biosdevname=0'$})
      }
    end
  end
end
