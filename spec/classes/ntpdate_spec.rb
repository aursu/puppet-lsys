# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::ntpdate' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      case os
      when %r{^rocky}
        it { is_expected.not_to contain_package('ntpdate') }
      end

      case os
      when 'centos-7-x86_64'
        it {
          is_expected.to contain_package('ntpdate')
            .with_ensure('latest')
        }

        it {
          is_expected.to contain_file('/etc/sysconfig/ntpdate')
            .with_content(%r{OPTIONS="-p 2"})
            .with_content(%r{SYNC_HWCLOCK=no})
        }
      end
    end
  end
end
