# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::postfix::client' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_user('postfix')
      }

      it {
        is_expected.to contain_group('postdrop')
      }

      it {
        is_expected.not_to contain_file('/var/spool/postfix/maildrop')
      }

      it {
        is_expected.not_to contain_file('/var/spool/postfix/public')
      }

      if os == 'rocky-8-x86_64'
        it {
          is_expected.to contain_file('/etc/postfix/master.cf')
            .with_content(%r{^127.0.0.1:smtp      inet  n       -       n       -       -       smtpd})
            .with_content(%r{^postlog   unix-dgram n  -       n       -       1       postlogd})
            .with_content(%r{^bounce    unix  -       -       n       -       0       bounce})
        }
      end

      context 'when SGID bits removed from binaries' do
        let(:params) do
          {
            postdrop_nosgid: true,
          }
        end

        it {
          is_expected.to contain_file('/var/spool/postfix/maildrop')
            .with_mode('1733')
        }

        it {
          is_expected.to contain_file('/var/spool/postfix/public')
            .with_mode('0711')
        }
      end

      context 'when Mail Log file defined' do
        let(:params) do
          {
            maillog_file: '/var/log/maillog',
          }
        end

        it {
          is_expected.to contain_augeas("manage postfix 'maillog_file'")
            .with_changes(%r{set maillog_file '/var/log/maillog'})
        }
      end
    end
  end
end
