# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::keycloak' do
  let(:pre_condition) { 'include lsys_postgresql' }
  let(:sha) { 'dd124787283918bc597628887168333465ee2a811a389e0003569e52be7e487f' }
  let(:base_params) do
    {
      archive_sha256: sha,
      hostname: 'https://sso.example.com',
      admin_password: sensitive('admin-secret'),
      db_password: sensitive('db-secret'),
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with defaults' do
        let(:params) { base_params }

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_archive('/var/cache/keycloak/keycloak-26.8.2.tar.gz')
            .with(
              source: 'https://github.com/keycloak/keycloak/releases/download/26.8.2/keycloak-26.8.2.tar.gz',
              checksum: sha,
              checksum_type: 'sha256',
              checksum_verify: true,
              extract: false,
            )
            .that_comes_before('Class[keycloak]')
        }

        it {
          is_expected.to contain_class('keycloak')
            .with(
              version: '26.8.2',
              package_url: '/var/cache/keycloak/keycloak-26.8.2.tar.gz',
              hostname: 'https://sso.example.com',
              http_host: '127.0.0.1',
              http_port: 8080,
              proxy_headers: 'xforwarded',
              manage_db: false,
              manage_db_server: false,
              db: 'postgres',
              db_url_host: '127.0.0.1',
              db_url_database: 'keycloak',
              db_username: 'keycloak',
              java_opts: '-Xms512m -Xmx2g',
            )
        }

        it {
          is_expected.to contain_lsys_postgresql__database('keycloak')
            .with_user('keycloak')
            .with_client_addresses(['127.0.0.1/32'])
            .that_comes_before('Class[keycloak]')
        }

        it {
          is_expected.to contain_file('/opt/keycloak-26.8.2/conf/keycloak.conf')
            .with_content(%r{^cache=local$})
            .with_content(%r{^http-host=127\.0\.0\.1$})
            .with_content(%r{^http-management-host=127\.0\.0\.1$})
            .with_content(%r{^http-management-port=9000$})
            .with_content(%r{^health-enabled=true$})
            .with_content(%r{^metrics-enabled=true$})
            .with_content(%r{^hostname=https://sso\.example\.com$})
        }

        it {
          is_expected.to contain_systemd__dropin_file('hardening.conf')
            .with_ensure('present')
            .with_unit('keycloak.service')
            .with_content(%r{^\[Service\]$})
            .with_content(%r{^NoNewPrivileges=yes$})
            .with_content(%r{^ProtectSystem=full$})
            .with_content(%r{^CapabilityBoundingSet=$})
        }

        it { is_expected.not_to contain_systemd__dropin_file('hardening.conf').with_content(%r{MemoryDenyWriteExecute}) }

        if os_facts[:os]['family'] == 'Debian'
          it {
            is_expected.to contain_class('java')
              .with_package('openjdk-21-jre-headless')
              .with_java_home('/usr/lib/jvm/java-21-openjdk-amd64')
          }
        end
      end

      context 'without database management and without hardening' do
        let(:params) do
          base_params.merge(
            manage_database: false,
            service_hardening: {},
          )
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_lsys_postgresql__database('keycloak') }
        it { is_expected.to contain_systemd__dropin_file('hardening.conf').with_ensure('absent') }
      end

      context 'without server_name' do
        let(:params) { base_params }

        it { is_expected.not_to contain_nginx__resource__server('keycloak') }
      end

      context 'with the nginx front' do
        let(:facts) { os_facts.merge(stype: 'web') }
        let(:params) do
          base_params.merge(
            http_port: 8180,
            server_name: 'sso.example.com',
            listen_ip: '10.0.0.13',
            cert_identity: 'registry.domain.tld',
            manage_certificate: false,
            manage_nginx_core: true,
            management_allow: ['10.0.1.0/24'],
          )
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_nginx__resource__server('keycloak')
            .with(
              listen_ip: '10.0.0.13',
              listen_port: 80,
              ssl: true,
              ssl_port: 443,
              ssl_redirect: true,
              server_name: ['sso.example.com'],
              ssl_protocols: 'TLSv1.2 TLSv1.3',
              ssl_stapling: 'off',
            )
            .with_ssl_cert(%r{\.pem$})
            .with_ssl_key(%r{\.key$})
        }

        it {
          is_expected.to contain_nginx__resource__location('keycloak-root')
            .with(
              server: 'keycloak',
              location: '/',
              ssl_only: true,
              proxy: 'http://127.0.0.1:8180',
            )
            .with_proxy_set_header(%r{X-Forwarded-Proto \$scheme})
        }

        ['health', 'metrics'].each do |path|
          it {
            is_expected.to contain_nginx__resource__location("keycloak-management-#{path}")
              .with(
                location: "/#{path}",
                proxy: 'http://127.0.0.1:9000',
                location_allow: ['10.0.1.0/24'],
                location_deny: ['all'],
              )
          }
        end

        it { is_expected.not_to contain_tlsinfo__certpair('registry.domain.tld') }

        it {
          is_expected.to contain_nginx__resource__location('keycloak-root')
            .with_proxy_hide_header(['Strict-Transport-Security'])
        }
      end

      context 'with backup' do
        let(:params) do
          base_params.merge(
            backup_password: 'restic-secret',
            backup_offsite_repository: 's3:https://s3.example.com/backup/host/keycloak',
            backup_offsite_env: { 'AWS_ACCESS_KEY_ID' => 'id', 'AWS_SECRET_ACCESS_KEY' => 'secret' },
          )
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_restic__repository('keycloak')
            .with_repository('/var/backups/restic/keycloak')
        }

        it {
          is_expected.to contain_lsys_postgresql__backup('keycloak')
            .with(
              repository: 'keycloak',
              minute: '47',
              keep: { 'hourly' => 24, 'daily' => 7 },
            )
        }

        it { is_expected.to contain_restic__job('postgres-keycloak') }

        it {
          is_expected.to contain_restic__repository('keycloak-offsite')
            .with(
              repository: 's3:https://s3.example.com/backup/host/keycloak',
              init: false,
            )
        }

        it {
          is_expected.to contain_restic__copy('keycloak-offsite')
            .with(
              source_repository: 'keycloak',
              dest_repository: 'keycloak-offsite',
              keep: { 'daily' => 14 },
              minute: '45',
              hour: '3',
            )
        }
      end

      context 'without backup_password' do
        let(:params) { base_params }

        it { is_expected.not_to contain_restic__repository('keycloak') }
        it { is_expected.not_to contain_lsys_postgresql__backup('keycloak') }
      end

      context 'with server_name but no cert_identity' do
        let(:params) { base_params.merge(server_name: 'sso.example.com') }

        it { is_expected.to compile.and_raise_error(%r{cert_identity is required}) }
      end

      context 'with an invalid digest' do
        let(:params) { base_params.merge(archive_sha256: 'not-a-digest') }

        it { is_expected.to compile.and_raise_error(%r{archive_sha256}) }
      end
    end
  end
end
