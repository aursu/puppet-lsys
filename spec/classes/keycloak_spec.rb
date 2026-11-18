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

      context 'with an invalid digest' do
        let(:params) { base_params.merge(archive_sha256: 'not-a-digest') }

        it { is_expected.to compile.and_raise_error(%r{archive_sha256}) }
      end
    end
  end
end
