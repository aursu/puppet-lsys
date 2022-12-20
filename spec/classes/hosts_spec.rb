# frozen_string_literal: true

require 'spec_helper'

networking_facts = {
  'networking' => {
    'hostname' => 'web-server-001',
    'domain' => 'intern.domain.tld',
    'fqdn' => 'web-server-001.intern.domain.tld',
    'ip' => '172.16.100.49',
    'interfaces': {
      'lo0': {
        'mtu': 16384,
        'bindings': [
          {
            'address': '127.0.0.1',
            'netmask': '255.0.0.0',
            'network': '127.0.0.0',
          },
        ],
        'bindings6': [
          {
            'address': '::1',
            'netmask': 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff',
            'network': '::1',
            'scope6': 'host'
          },
          {
            'address': 'fe80::1',
            'netmask': 'ffff:ffff:ffff:ffff::',
            'network': 'fe80::',
            'scope6': 'link',
          },
        ],
        'ip': '127.0.0.1',
        'netmask': '255.0.0.0',
        'network': '127.0.0.0',
        'ip6': '::1',
        'netmask6': 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff',
        'network6': '::1',
        'scope6': 'host'
      },
      'en0': {
        'mtu': 1500,
        'mac': 'f0:18:98:50:64:d6',
        'dhcp': '172.16.100.1',
        'bindings': [
          {
            'address': '172.16.100.49',
            'netmask': '255.255.255.0',
            'network': '172.16.100.0',
          },
        ],
        'bindings6': [
          {
            'address': 'fe80::cac:e387:c664:e06',
            'netmask': 'ffff:ffff:ffff:ffff::',
            'network': 'fe80::',
            'scope6': 'link',
          },
        ],
        'ip': '172.16.100.49',
        'netmask': '255.255.255.0',
        'network': '172.16.100.0',
        'ip6': 'fe80::cac:e387:c664:e06',
        'netmask6': 'ffff:ffff:ffff:ffff::',
        'network6': 'fe80::',
        'scope6': 'link'
      },
      'utun9': {
        'mtu': 1400,
        'bindings': [
          {
            'address': '192.168.127.16',
            'netmask': '255.255.255.255',
            'network': '192.168.127.16',
          },
        ],
        'ip': '192.168.127.16',
        'netmask': '255.255.255.255',
        'network': '192.168.127.16',
      }
    }
  }
}

describe 'lsys::hosts' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(networking_facts)
      end

      it { is_expected.to compile }

      it {
        expect(exported_resources).to contain_host('web-server-001.intern.domain.tld')
          .with(
            'ensure'       => 'present',
            'ip'           => '172.16.100.49',
            'host_aliases' => ['web-server-001'],
            'tag'          => 'exported',
          )
      }

      it {
        is_expected.to contain_host('localhost')
          .with(
            'ensure'       => 'present',
            'name'         => 'localhost',
            'ip'           => '127.0.0.1',
            'host_aliases' => ['localhost.localdomain', 'localhost4', 'localhost4.localdomain4'],
          )
      }

      it {
        is_expected.to contain_host('localhost6')
          .with(
            'ensure'       => 'present',
            'name'         => 'localhost6',
            'ip'           => '::1',
            'host_aliases' => ['localhost', 'localhost.localdomain', 'localhost6.localdomain6'],
          )
      }

      context 'when aliases provided' do
        let(:params) do
          {
            aliases: ['app-server'],
          }
        end

        it {
          expect(exported_resources).to contain_host('web-server-001.intern.domain.tld')
            .with(
              'host_aliases' => ['web-server-001'],
            )
        }

        it {
          is_expected.to contain_host('app-server')
            .with(
              'ensure'       => 'present',
              'ip'           => '172.16.100.49',
              'host_aliases' => [],
            )
        }

        context 'and aliases exported' do
          let(:params) do
            super().merge(
              exported_aliases: true,
            )
          end

          it {
            expect(exported_resources).to contain_host('web-server-001.intern.domain.tld')
              .with(
                'ip'           => '172.16.100.49',
                'host_aliases' => ['web-server-001', 'app-server'],
              )
          }

          it {
            is_expected.not_to contain_host('app-server')
          }
        end
      end

      context 'when do not export resources' do
        let(:params) do
          {
            exported: false,
          }
        end

        it {
          expect(exported_resources).not_to contain_host('web-server-001.intern.domain.tld')
        }

        it {
          is_expected.to contain_host('web-server-001.intern.domain.tld')
            .with(
              'ensure'       => 'present',
              'ip'           => '172.16.100.49',
              'host_aliases' => ['web-server-001'],
            )
            .without_tag
        }
      end
    end
  end
end
