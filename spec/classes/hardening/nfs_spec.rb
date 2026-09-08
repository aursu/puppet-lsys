# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::hardening::nfs' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      # Both units, not just the service: rpcbind.socket is socket-activated, so
      # masking the service alone leaves :111 listening and systemd restarts it.
      it {
        is_expected.to contain_service('rpcbind.service')
          .with(
            ensure: 'stopped',
            enable: 'mask',
          )
      }

      it {
        is_expected.to contain_service('rpcbind.socket')
          .with(
            ensure: 'stopped',
            enable: 'mask',
          )
      }

      context 'with rpcbind left alone, for an NFS client' do
        let(:params) do
          {
            mask_rpcbind: false,
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.not_to contain_service('rpcbind.service')
        }

        it {
          is_expected.not_to contain_service('rpcbind.socket')
        }
      end

      context 'with an extra unit to mask' do
        let(:params) do
          {
            rpcbind_units: [
              'rpcbind.service',
              'rpcbind.socket',
              'rpc-statd.service',
            ],
          }
        end

        it {
          is_expected.to contain_service('rpc-statd.service')
            .with(
              ensure: 'stopped',
              enable: 'mask',
            )
        }
      end

      context 'with an empty unit list' do
        let(:params) do
          {
            rpcbind_units: [],
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.not_to contain_service('rpcbind.service')
        }
      end
    end
  end
end
