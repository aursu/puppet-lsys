require 'spec_helper'

describe 'lsys::dhcp::shared_network' do
  let(:title) { 'namevar' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'with default parameters' do
        it {
          is_expected.to contain_concat__fragment('dhcp_shared_network_namevar')
            .with_content(%r{shared-network "namevar" \{\s+\}})
        }
      end

      context 'with different network name' do
        let(:params) do
          super().merge(
            network_name: "os-web-nfs",
          )
        end

        it {
          is_expected.to contain_concat__fragment('dhcp_shared_network_namevar')
            .with_content(%r{shared-network "os-web-nfs" \{\s+\}})
        }
      end

      context 'with option domain-name-servers' do
        let(:params) do
          super().merge(
            nameservers: ['8.8.8.8', '8.8.4.4'],
          )
        end

        it {
          is_expected.to contain_concat__fragment('dhcp_shared_network_namevar')
            .with_content(%r{option domain-name-servers 8.8.8.8, 8.8.4.4;})
        }
      end

      context 'with option domain-name' do
        let(:params) do
          super().merge(
            domain_name: 'os.domain.tld',
          )
        end

        it {
          is_expected.to contain_concat__fragment('dhcp_shared_network_namevar')
            .with_content(%r{option domain-name "os.domain.tld";})
        }
      end

      context 'with custom options' do
        let(:params) do
          super().merge(
            options: [ 'tftp-server-name "10.55.156.10"', 'bootfile-name "boot/grub/i386-pc/core.0"' ],
          )
        end

        it {
          is_expected.to contain_concat__fragment('dhcp_shared_network_namevar')
            .with_content(%r{option tftp-server-name "10.55.156.10";})
            .with_content(%r{option bootfile-name "boot/grub/i386-pc/core.0";})
        }
      end

      context 'with custom parameters' do
        let(:params) do
          super().merge(
            parameters: [ 'dynamic-bootp-lease-length 600', 'boot-unknown-clients off' ],
          )
        end

        it {
          is_expected.to contain_concat__fragment('dhcp_shared_network_namevar')
            .with_content(%r{dynamic-bootp-lease-length 600;})
            .with_content(%r{boot-unknown-clients off;})
        }
      end

      context 'with subnet' do
        let(:params) do
          super().merge(
            subnet: {
              'os web' => {
                network: '10.55.156.0',
                mask: '255.255.255.0',
                broadcast: '10.55.156.255',
                routers: '10.55.156.1',
                domain_name: 'os.domain.tld',
                nameservers: ['8.8.8.8', '8.8.4.4', '1.1.1.1'],
                range: {
                  low_address: '10.55.156.32',
                }
              }
            },
          )
        end

        it {
          is_expected.to contain_concat__fragment('dhcp_shared_network_namevar')
            .with_content(%r{subnet 10.55.156.0 netmask 255.255.255.0})
        }

        it {
          is_expected.to contain_concat__fragment('dhcp_shared_network_namevar')
            .with_content(%r{option routers 10.55.156.1;})
        }

        it {
          is_expected.to contain_concat__fragment('dhcp_shared_network_namevar')
            .with_content(%r{option domain-name "os.domain.tld";})
        }

        it {
          is_expected.to contain_concat__fragment('dhcp_shared_network_namevar')
            .with_content(%r{option domain-name-servers 8.8.8.8, 8.8.4.4, 1.1.1.1;})
        }

        it {
          is_expected.to contain_concat__fragment('dhcp_shared_network_namevar')
            .with_content(%r{option broadcast-address 10.55.156.255;})
        }

        it {
          is_expected.to contain_concat__fragment('dhcp_shared_network_namevar')
            .with_content(%r{range 10.55.156.32;})
        }
      end

      context 'when subnet with dynamic bootp range' do
        let(:params) do
          super().merge(
            subnet: {
              'os web' => {
                network: '10.55.156.0',
                mask: '255.255.255.0',
                range: {
                  low_address: '10.55.156.32',
                  dynamic_bootp: true,
                }
              }
            },
          )
        end

        it {
          is_expected.to contain_concat__fragment('dhcp_shared_network_namevar')
            .with_content(%r{range dynamic-bootp 10.55.156.32;})
        }
      end
    end
  end
end
