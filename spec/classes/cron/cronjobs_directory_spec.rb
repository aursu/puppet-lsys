# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::cron::cronjobs_directory' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('/etc/cron.d').with(
          'mode'    => '0750',
          'recurse' => true,
          'purge'   => true,
        )
      }

      it {
        is_expected.to contain_file('/etc/cron.d/0hourly').with_ensure('file')
      }
    end
  end
end
