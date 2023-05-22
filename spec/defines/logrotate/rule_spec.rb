# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::logrotate::rule' do
  let(:title) { 'namevar' }
  let(:params) do
    {
      path: '/var/log/messages',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'when postrotate is set to true' do
        let(:params) do
          super().merge(
            config: {
              postrotate: true,
            },
          )
        end

        case os
        when %r{^centos-}, %r{^rocky-}
          it {
            is_expected.to contain_file('/etc/logrotate.d/namevar')
              .with_content(%r{^\s+/usr/bin/systemctl kill -s HUP rsyslog\.service >/dev/null 2>&1 || true$})
          }
        when %r{^ubuntu-}
          it {
            is_expected.to contain_file('/etc/logrotate.d/namevar')
              .with_content(%r{^\s+/usr/lib/rsyslog/rsyslog-rotate$})
          }
        end
      end

      context 'when postrotate is set to specific value' do
        let(:params) do
          super().merge(
            config: {
              postrotate: '/path/to/logrotate/reload/script',
            },
          )
        end

        it {
          is_expected.to contain_file('/etc/logrotate.d/namevar')
            .with_content(%r{^\s+/path/to/logrotate/reload/script$})
        }
      end

      context 'when postrotate is set to false' do
        let(:params) do
          super().merge(
            config: {
              postrotate: false,
            },
          )
        end

        it {
          is_expected.to contain_file('/etc/logrotate.d/namevar')
            .without_content(%r{postrotate})
        }
      end

      context 'when sharedscripts is set to true' do
        let(:params) do
          super().merge(
            config: {
              sharedscripts: true,
              postrotate: true,
            },
          )
        end

        it {
          is_expected.to contain_file('/etc/logrotate.d/namevar')
            .with_content(%r{^\s+sharedscripts$})
        }
      end

      context 'when sharedscripts is set to false' do
        let(:params) do
          super().merge(
            config: {
              sharedscripts: false,
              postrotate: true,
            },
          )
        end

        it {
          is_expected.to contain_file('/etc/logrotate.d/namevar')
            .with_content(%r{^\s+nosharedscripts$})
        }
      end

      context 'when multiple paths and postrotate and no sharedscripts specified' do
        let(:params) do
          {
            path: ['/var/log/messages', '/var/log/debug'],
            config: {
              postrotate: true,
            }
          }
        end

        it {
          is_expected.to contain_file('/etc/logrotate.d/namevar')
            .with_content(%r{^\s+sharedscripts$})
        }
      end

      context 'when multiple paths and postrotate and sharedscripts disabled' do
        let(:params) do
          {
            path: ['/var/log/messages', '/var/log/debug'],
            config: {
              postrotate: true,
              sharedscripts: false,
            }
          }
        end

        it {
          is_expected.to contain_file('/etc/logrotate.d/namevar')
            .with_content(%r{^\s+nosharedscripts$})
        }
      end
    end
  end
end
