# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::puppet' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_class('puppet::profile::agent')
      }

      context 'when Puppet server' do
        let(:params) do
          {
            puppetserver: true,
            ca_server: 'puppet', # mandatory for puppetserver
          }
        end

        it {
          is_expected.not_to contain_class('puppet::profile::agent')
        }

        it {
          is_expected.not_to contain_cron('r10k-crontab')
        }

        it {
          is_expected.not_to contain_file('/etc/puppetlabs/puppetserver/conf.d/webserver.conf')
        }

        context 'check webserver.conf management' do
          let(:params) do
            super().merge(
              manage_webserver_conf: true,
            )
          end

          it {
            is_expected.to contain_file('/etc/puppetlabs/puppetserver/conf.d/webserver.conf')
              .with_content(%r{ssl-ca-cert: /etc/puppetlabs/puppet/ssl/certs/ca.pem})
          }
        end

        context 'and r10k crontab enabled' do
          let(:params) do
            super().merge(
              r10k_crontab_setup: true,
            )
          end

          it {
            is_expected.to contain_cron('r10k-crontab')
          }
        end
      end
    end
  end
end
