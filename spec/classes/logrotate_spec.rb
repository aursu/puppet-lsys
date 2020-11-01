# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::logrotate' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('/etc/logrotate.d/hourly')
          .with_ensure('directory')
          .with_mode('0755')
      }

      it {
        is_expected.to contain_file('/etc/cron.hourly/logrotate')
          .with_ensure('present')
          .with_mode('0700')
          .with_content(%r{OUTPUT=\$\(/usr/sbin/logrotate /etc/logrotate.d/hourly 2>&1\)})
      }
    end
  end
end
