# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::cron' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'with default settings' do
        it { is_expected.to contain_class('cron') }

        # by default we manage package cronie for all supported by lsys module
        # CentOS versions
        it { is_expected.to contain_package('cron').with('name' => 'cronie') }

        it { is_expected.to contain_service('crond') }

        it {
          is_expected.to contain_file('/etc/cron.d').with(
            'mode'    => '0750',
            'recurse' => true,
            'purge'   => true,
          ).that_requires('Package[cron]')
        }

        it {
          is_expected.to contain_file('/etc/cron.d/0hourly').with_ensure('present')
        }
      end
    end
  end
end
