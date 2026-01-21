# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::github::runner' do
  let(:pre_condition) do
    <<-PRECOND
    include dockerinstall
    include dockerinstall::compose
    PRECOND
  end
  let(:title) { 'runner1' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_dockerinstall__webservice('github-actions-runner-runner1')
          .with_docker_image(%r{^ghcr\.io/aursu/rockylinux:.+-actions-runner-.+$})
          .with_manage_image(false)
          .with_project_name('github')
          .with_service_name('githubrunner')
          .with_env_name('jwt')
      }

      context 'when using registration token' do
        let(:params) do
          super().merge(
            registration_token: 'ABCD1234567890',
            url: 'https://github.com/myorg',
          )
        end

        it {
          is_expected.to contain_dockerinstall__webservice('github-actions-runner-runner1')
            .with_secrets(
              'GITHUB_TOKEN' => 'ABCD1234567890',
              'GITHUB_URL' => 'https://github.com/myorg',
              'GITHUB_PAT' => '',
              'GITHUB_CLIENT_ID' => '',
            )
        }

        it {
          is_expected.to contain_dockerinstall__webservice('github-actions-runner-runner1')
            .with_docker_secret(nil)
            .with_project_secrets(nil)
        }
      end

      context 'when using GitHub App authentication' do
        let(:params) do
          super().merge(
            client_id: '123456',
            app_key: 'my-github-app-private-key-content',
            url: 'https://github.com/myorg',
          )
        end

        it {
          is_expected.to contain_dockerinstall__webservice('github-actions-runner-runner1')
            .with_secrets(
              'GITHUB_URL' => 'https://github.com/myorg',
              'GITHUB_TOKEN' => '',
              'GITHUB_PAT' => '',
              'GITHUB_CLIENT_ID' => '123456',
            )
            .with_docker_secret(['github_key'])
        }

        it {
          is_expected.to contain_dockerinstall__webservice('github-actions-runner-runner1')
            .with_project_secrets(
              [
                {
                  'name' => 'github_key',
                  'type' => 'file',
                  'setup' => true,
                  'value' => 'my-github-app-private-key-content',
                  'filename' => 'private-key.pem',
                },
              ],
            )
        }

        it {
          is_expected.to contain_dockerinstall__webservice('github-actions-runner-runner1')
            .with_environment(
              'RUNNER_NAME' => 'github-actions-runner-runner1',
              'GITHUB_APP_KEY_PATH' => '/run/secrets/github_key',
              'DOCKER_TLS_CERTDIR' => '/certs',
              'DOCKER_CERT_PATH' => '/certs/client',
              'DOCKER_TLS_VERIFY' => '1',
              'DOCKER_HOST' => 'tcp://localhost:2376',
            )
        }
      end

      context 'when using custom runner name' do
        let(:params) do
          super().merge(
            runner_name: 'custom-runner-001',
          )
        end

        it {
          is_expected.to contain_dockerinstall__webservice('custom-runner-001')
            .with_environment(
              'RUNNER_NAME' => 'custom-runner-001',
              'DOCKER_TLS_CERTDIR' => '/certs',
              'DOCKER_CERT_PATH' => '/certs/client',
              'DOCKER_TLS_VERIFY' => '1',
              'DOCKER_HOST' => 'tcp://localhost:2376',
            )
        }
      end

      context 'when using custom volumes' do
        let(:params) do
          super().merge(
            docker_volumes: ['/custom/path:/app/data'],
            runner_volume: 'my-runner-volume',
          )
        end

        it {
          is_expected.to contain_dockerinstall__webservice('github-actions-runner-runner1')
            .with_docker_volume(
              [
                '/etc/docker/certs.d:/etc/docker/certs.d',
                '/var/run/docker.sock:/var/run/docker.sock',
                '/etc/docker/tls:/certs/client',
                'my-runner-volume:/home/runner',
                '/custom/path:/app/data',
              ],
            )
        }
      end

      context 'when using PAT authentication' do
        let(:params) do
          super().merge(
            pat: 'ghp_xxxxxxxxxxxxxxxxxxxx',
          )
        end

        it {
          is_expected.to contain_dockerinstall__webservice('github-actions-runner-runner1')
            .with_secrets(
              'GITHUB_URL' => 'https://github.com/rpmbsys',
              'GITHUB_TOKEN' => '',
              'GITHUB_PAT' => 'ghp_xxxxxxxxxxxxxxxxxxxx',
              'GITHUB_CLIENT_ID' => '',
            )
        }
      end

      context 'when PAT and client_id are not specified (undef)' do
        it {
          is_expected.to contain_dockerinstall__webservice('github-actions-runner-runner1')
            .with_secrets(
              'GITHUB_URL' => 'https://github.com/rpmbsys',
              'GITHUB_TOKEN' => '',
              'GITHUB_PAT' => '',
              'GITHUB_CLIENT_ID' => '',
            )
        }
      end

      context 'with Docker access configuration' do
        it {
          is_expected.to contain_dockerinstall__webservice('github-actions-runner-runner1')
            .with_environment(
              'RUNNER_NAME' => 'github-actions-runner-runner1',
              'DOCKER_TLS_CERTDIR' => '/certs',
              'DOCKER_CERT_PATH' => '/certs/client',
              'DOCKER_TLS_VERIFY' => '1',
              'DOCKER_HOST' => 'tcp://localhost:2376',
            )
        }

        it {
          is_expected.to contain_dockerinstall__webservice('github-actions-runner-runner1')
            .with_docker_volume(
              [
                '/etc/docker/certs.d:/etc/docker/certs.d',
                '/var/run/docker.sock:/var/run/docker.sock',
                '/etc/docker/tls:/certs/client',
                'githubrunner:/home/runner',
              ],
            )
        }
      end

      context 'when manage_image is true' do
        let(:params) do
          super().merge(
            registration_token: 'ABCD1234567890',
            manage_image: true,
          )
        end

        it {
          is_expected.to contain_dockerinstall__webservice('github-actions-runner-runner1')
            .with_manage_image(true)
        }
      end
    end
  end
end
