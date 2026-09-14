# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::vault::backup' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'with default parameters' do
        it { is_expected.to contain_class('lsys::vault::backup') }

        it {
          is_expected.to contain_file('/etc/vault')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
        }

        it {
          is_expected.to contain_file('/opt/backup')
            .with_ensure('directory')
            .with_mode('0755')
        }

        # The environment file names the token file but must never hold the
        # token itself, hence 0600 and the content assertions below.
        it {
          is_expected.to contain_file('/etc/vault/vault-backup.env')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0600')
        }

        it {
          is_expected.to contain_file('/etc/vault/vault-backup.env')
            .with_content(%r{^COMPOSE_PROJECT=vault$})
            .with_content(%r{^COMPOSE_SERVICE=vault-prod$})
            .with_content(%r{^COMPOSE_FILE=/var/lib/compose/vault/docker-compose\.yml$})
            .with_content(%r{^TOKEN_FILE=/etc/vault/snapshot-token$})
            .with_content(%r{^SNAPSHOT_PATH=/run/vault-raft\.snap$})
            .with_content(%r{^CONTAINER_PATH=/tmp/raft\.snap$})
        }

        it {
          is_expected.to contain_file('/opt/backup/vault-snapshot')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0700')
            .with_source('puppet:///modules/lsys/vault/vault-snapshot')
        }

        it {
          is_expected.to contain_file('/opt/backup/vault-snapshot-cleanup')
            .with_ensure('file')
            .with_mode('0700')
            .with_source('puppet:///modules/lsys/vault/vault-snapshot-cleanup')
        }
      end

      # Directory ownership is decided by parameters rather than by `defined()`,
      # so that the class behaves the same wherever it is declared. These two
      # contexts are what that promise means in practice.
      context 'when the caller owns the bin directory' do
        let(:params) { { manage_bin_dir: false } }

        it { is_expected.to compile }
        it { is_expected.not_to contain_file('/opt/backup') }
        it { is_expected.to contain_file('/opt/backup/vault-snapshot') }
      end

      context 'when the caller owns the config directory' do
        let(:params) { { manage_config_dir: false } }

        it { is_expected.to compile }
        it { is_expected.not_to contain_file('/etc/vault') }
        it { is_expected.to contain_file('/etc/vault/vault-backup.env') }
      end

      context 'when both directories are owned elsewhere' do
        let(:params) do
          {
            manage_bin_dir: false,
            manage_config_dir: false,
          }
        end

        it { is_expected.to compile }
        it { is_expected.not_to contain_file('/opt/backup') }
        it { is_expected.not_to contain_file('/etc/vault') }
      end

      context 'with a second Vault on the same host' do
        let(:params) do
          {
            compose_project: 'vault-transit',
            compose_service: 'vault-transit-prod',
            compose_file: '/var/lib/compose/vault-transit/docker-compose.yml',
            token_file: '/etc/vault-transit/snapshot-token',
            snapshot_path: '/run/vault-transit.snap',
            container_path: '/tmp/transit.snap',
            bin_dir: '/usr/local/sbin',
            config_dir: '/etc/vault-transit',
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_file('/etc/vault-transit/vault-backup.env')
            .with_content(%r{^COMPOSE_PROJECT=vault-transit$})
            .with_content(%r{^COMPOSE_SERVICE=vault-transit-prod$})
            .with_content(%r{^COMPOSE_FILE=/var/lib/compose/vault-transit/docker-compose\.yml$})
            .with_content(%r{^TOKEN_FILE=/etc/vault-transit/snapshot-token$})
            .with_content(%r{^SNAPSHOT_PATH=/run/vault-transit\.snap$})
            .with_content(%r{^CONTAINER_PATH=/tmp/transit\.snap$})
        }

        it { is_expected.to contain_file('/usr/local/sbin/vault-snapshot').with_mode('0700') }
        it { is_expected.to contain_file('/usr/local/sbin/vault-snapshot-cleanup').with_mode('0700') }
        it { is_expected.to contain_file('/etc/vault-transit').with_ensure('directory') }
      end

      # The token is the one thing that must never be rendered into a file this
      # class manages - it is read at run time from the path named here.
      context 'the environment file never contains a token' do
        it {
          is_expected.to contain_file('/etc/vault/vault-backup.env')
            .without_content(%r{VAULT_TOKEN})
            .without_content(%r{hvs\.})
        }
      end

      context 'with a path that is not absolute' do
        let(:params) { { compose_file: 'docker-compose.yml' } }

        it { is_expected.to compile.and_raise_error(%r{Stdlib::Absolutepath}) }
      end
    end
  end
end
