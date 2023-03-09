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

      context 'when SGID bits removed from binaries' do
        let(:params) do
          {
            postdrop_nosgid: true,
          }
        end

        it {
          is_expected.not_to contain_file('/var/spool/postfix/maildrop')
            .with_mode('1733')
        }
  
        it {
          is_expected.not_to contain_file('/var/spool/postfix/public')
          .with_mode('0711')
        }
      end
    end
  end
end
