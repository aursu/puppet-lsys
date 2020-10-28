# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::monit::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('monit_logrotate_script')
          .with_ensure('file')
          .with_path('/etc/logrotate.d/monit')
          .with_content(%r{^/var/log/monit.log})
      }

      case os
      when 'centos-6-x86_64'
        it {
          is_expected.to contain_file('monit_startup_script')
            .with_ensure('file')
            .with_path('/etc/rc.d/init.d/monit')
            .with_content(%r{^CONFIG="/etc/monitrc"$})
            .with_content(%r{^pidfile="/var/run/monit.pid"$})
            .with_content(%r{-x /usr/local/bin/monit})
        }

        it {
          is_expected.to contain_file('monit_logrotate_script')
            .with_ensure('file')
            .with_path('/etc/logrotate.d/monit')
            .with_content(%r{/sbin/service monit condrestart >/dev/null 2>&1 || :})
        }
      when 'centos-7-x86_64'
        it {
          is_expected.to contain_file('monit_startup_script')
            .with_ensure('file')
            .with_path('/etc/systemd/system/monit.service')
            .with_content(%r{^ExecStart=/usr/local/bin/monit -I$})
            .that_notifies('Class[lsys::systemd]')
        }

        it {
          is_expected.to contain_file('monit_logrotate_script')
            .with_ensure('file')
            .with_path('/etc/logrotate.d/monit')
            .with_content(%r{/bin/systemctl reload monit.service >/dev/null 2>&1 || :})
        }
      end
    end
  end
end
