require 'spec_helper'

describe 'lsys::config' do
  let(:title) { '/etc/GeoIP.conf' }
  let(:params) do
    {
      'data' => {
        'LicenseKey' => '000000000000',
        'UserId'     => '0',
        'ProductIds' => 'GeoLite2-City GeoLite2-Country',
      },
      'key_val_separator' => ' ',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
