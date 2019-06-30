require 'spec_helper'

describe 'lsys::pxe::dhcp' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
        }
      end

      it { is_expected.to compile }

      if ['redhat-7-x86_64', 'centos-7-x86_64'].include?(os)
        context 'check network interfaces setup with default parameters' do
          it {
            is_expected.to contain_file('/etc/systemd/system/dhcpd.service')
              .with_content(%r{^ExecStart=.* -user dhcpd -group dhcpd --no-pid $})
          }
        end

        context 'check network interfaces setup when specified' do
          let(:params) do
            super().merge(
              dhcp_interfaces: %w[eth0 eth1],
            )
          end

          it {
            is_expected.to contain_file('/etc/systemd/system/dhcpd.service')
              .with_content(%r{^ExecStart=.* -user dhcpd -group dhcpd --no-pid eth0 eth1$})
          }
        end
      end

      context 'check DHCP authoritative setup with default parameters' do
        it {
          is_expected.to contain_concat__fragment('dhcp-conf-header')
            .with_content(%r{^not authoritative;$})
        }
      end

      context 'check DHCP option 150 setup with default parameters' do
        it {
          is_expected.to contain_concat__fragment('dhcp-conf-header')
            .with_content(%r{^option voip-tftp-server code 150 = ip-address;$})
        }
      end

      context 'check option domain-name-servers setup with default parameters' do
        it {
          is_expected.to contain_concat__fragment('dhcp-conf-header')
          is_expected.not_to contain_concat__fragment('dhcp-conf-header')
            .with_content(%r{option domain-name-servers})
        }
      end

      context 'check option domain-name-servers setup when name servers specified' do
        let(:params) do
          super().merge(
            dhcp_nameservers: ['8.8.8.8', '8.8.4.4'],
          )
        end

        it {
          is_expected.to contain_concat__fragment('dhcp-conf-header')
            .with_content(%r{option domain-name-servers 8.8.8.8, 8.8.4.4;})
        }
      end

      context 'check default subnet setup' do
        let(:params) do
          super().merge(
            default_subnet: {
              'openstack_web' => {
                network: '10.55.156.0',
                mask: '255.255.255.0',
                broadcast: '10.55.156.255',
                routers: '10.55.156.1',
                domain_name: 'os.domain.tld',
                nameservers: ['8.8.8.8', '8.8.4.4', '1.1.1.1']
              }
            },
          )
        end

        it {
          is_expected.to contain_concat__fragment('dhcp_pool_openstack_web')
            .with_content(%r{subnet 10.55.156.0 netmask 255.255.255.0})
        }

        it {
          is_expected.to contain_concat__fragment('dhcp_pool_openstack_web')
            .with_content(%r{option routers 10.55.156.1;})
        }

        it {
          is_expected.to contain_concat__fragment('dhcp_pool_openstack_web')
            .with_content(%r{option domain-name "os.domain.tld";})
        }

        it {
          is_expected.to contain_concat__fragment('dhcp_pool_openstack_web')
            .with_content(%r{option domain-name-servers 8.8.8.8, 8.8.4.4, 1.1.1.1;})
        }

        it {
          is_expected.to contain_concat__fragment('dhcp_pool_openstack_web')
            .with_content(%r{option broadcast-address 10.55.156.255;})
        }
      end
    end
  end
end
