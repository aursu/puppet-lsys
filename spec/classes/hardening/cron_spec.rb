# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::hardening::cron' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('/etc/cron.allow')
          .with_content("root\n")
      }

      context 'with few users allowed to use crontab' do
        let(:params) do
          {
            users_allow: [
              'admin',
              'deploy',
              'root',
            ],
          }
        end

        it {
          is_expected.to contain_file('/etc/cron.allow')
            .with_content("admin\ndeploy\nroot\n")
        }
      end
    end
  end
end
