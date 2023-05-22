# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::logrotate::default' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      case os
      when 'redhat-8-x86_64', 'centos-8-x86_64', 'rocky-8-x86_64'
        it {
          is_expected.not_to contain_logrotate__rule('syslog-default')
        }

        it {
          is_expected.to contain_logrotate__rule('syslog')
        }

        it {
          is_expected.to contain_file('/etc/logrotate.d/syslog')
            .with_content(%r{^/var/log/cron /var/log/maillog /var/log/messages /var/log/secure /var/log/spooler\s*\{})
            .with_content(%r{\s+missingok$})
            .with_content(%r{\s+sharedscripts$})
            .with_content(%r{\s+postrotate$})
            .with_content(%r{\s+/usr/bin/systemctl kill -s HUP rsyslog\.service >/dev/null 2>&1 || true$})
        }
      when %r{ubuntu-}
        it {
          is_expected.to contain_logrotate__rule('rsyslog-default')
        }

        it {
          is_expected.to contain_file('/etc/logrotate.d/rsyslog-default')
            .with_content(%r{^/var/log/syslog\s+\{})
            .with_content(%r{\s+rotate 7$})
            .with_content(%r{\s+missingok$})
            .with_content(%r{\s+notifempty$})
            .with_content(%r{\s+delaycompress$})
            .with_content(%r{\s+compress$})
            .with_content(%r{\s+postrotate$})
            .with_content(%r{\s+/usr/lib/rsyslog/rsyslog-rotate$})
        }

        it {
          is_expected.to contain_logrotate__rule('rsyslog')
        }

        it {
          is_expected.to contain_file('/etc/logrotate.d/rsyslog')
            .with_content(%r{^(/var/log/mail.(info|warn|err|log) ){4}(/var/log/(daemon|kern|auth|user|lpr|cron).log ){6}/var/log/debug /var/log/messages\s*\{})
        }
      end

      context 'More aggressive rules' do
        let(:params) do
          {
            syslog_config: {
              rotate: 7,
              hourly: true,
              missingok: true,
              notifempty: true,
              compress: true,
              postrotate: true,
              size: '100M',
            },
          }
        end

        it { is_expected.to compile.with_all_deps }

        case os
        when 'redhat-8-x86_64', 'centos-8-x86_64', 'rocky-8-x86_64'
          it {
            is_expected.to contain_file('/etc/logrotate.d/syslog')
              .with_ensure(:absent)
          }

          it {
            is_expected.to contain_file('/etc/logrotate.d/hourly/syslog')
              .with_content(%r{^/var/log/cron /var/log/maillog /var/log/messages /var/log/secure /var/log/spooler\s*\{})
              .with_content(%r{\s+rotate 7$})
              .with_content(%r{\s+missingok$})
              .with_content(%r{\s+notifempty$})
              .with_content(%r{\s+compress$})
              .with_content(%r{\s+size 100M$})
              .with_content(%r{\s+postrotate$})
              .with_content(%r{\s+/usr/bin/systemctl kill -s HUP rsyslog\.service >/dev/null 2>&1 || true$})
          }
        when %r{ubuntu-}
          it {
            is_expected.to contain_file('/etc/logrotate.d/rsyslog')
              .with_ensure(:absent)
          }

          it {
            is_expected.to contain_file('/etc/logrotate.d/hourly/rsyslog')
              .with_content(%r{^(/var/log/mail.(info|warn|err|log) ){4}(/var/log/(daemon|kern|auth|user|lpr|cron).log ){6}/var/log/debug /var/log/messages\s*\{})
              .with_content(%r{\s+rotate 7$})
              .with_content(%r{\s+missingok$})
              .with_content(%r{\s+notifempty$})
              .with_content(%r{\s+compress$})
              .with_content(%r{\s+size 100M$})
              .with_content(%r{\s+postrotate$})
              .with_content(%r{\s+/usr/bin/systemctl kill -s HUP rsyslog\.service >/dev/null 2>&1 || true$})
          }
        end
      end
    end
  end
end
