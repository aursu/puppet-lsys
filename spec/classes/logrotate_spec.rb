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

      case os
      when 'rocky-9-x86_64'
        it {
          is_expected.to contain_file('/etc/cron.hourly/logrotate')
            .with_ensure('absent')
        }

        it {
          is_expected.to contain_file('/etc/systemd/system/logrotate-hourly.timer.d/hourly-timer.conf')
            .with_content(%r{OnCalendar=hourly})
        }
      else
        it {
          is_expected.to contain_file('/etc/cron.hourly/logrotate')
            .with_ensure('present')
            .with_mode('0700')
            .with_content(%r{OUTPUT=\$\(/usr/sbin/logrotate /etc/logrotate.d/hourly 2>&1\)})
        }
      end

      case os
      when %r{^centos-}, %r{^rocky-}
        it {
          is_expected.to contain_file('/etc/logrotate.conf')
            .with_content(%r{^dateext})
            .with_content(%r{^compress})
        }
      when %r{ubuntu-}
        it {
          is_expected.to contain_file('/etc/logrotate.conf')
            .with_content(%r{^su root adm})
        }
      end
    end
  end
end
