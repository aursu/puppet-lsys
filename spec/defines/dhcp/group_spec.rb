require 'spec_helper'

describe 'lsys::dhcp::group' do
  let(:pre_condition) do
    <<-PRECOND
    class { 'lsys::pxe::dhcp': next_server => '10.55.156.10' }
    PRECOND
  end

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
          is_expected.to contain_concat__fragment('dhcp_group_namevar')
            .with_content(%r{group \{\s+\}})
        }
      end

      context 'when host declaration in use as client hostname' do
        let(:params) do
          super().merge(
            host_decl_names: true,
          )
        end

        it {
          is_expected.to contain_concat__fragment('dhcp_group_namevar')
            .with_content(%r{use-host-decl-names on;})
        }
      end

      context 'when PXE settings enabled' do
        let(:params) do
          super().merge(
            pxe_settings: true,
          )
        end

        it {
          is_expected.to contain_concat__fragment('dhcp_group_namevar')
            .with_content(%r{if \( substring \(option vendor-class-identifier, 0, 9\) = "PXEClient" \)})
        }

        it {
          is_expected.not_to contain_concat__fragment('dhcp_group_namevar')
            .with_content(%r{next-server})
        }

        it {
          is_expected.not_to contain_concat__fragment('dhcp_group_namevar')
            .with_content(%r{filename})
        }

        context 'when DHCP PXE option next-server declared' do
          let(:params) do
            super().merge(
              next_server: '10.55.156.40',
            )
          end

          it {
            is_expected.to contain_concat__fragment('dhcp_group_namevar')
              .with_content(%r{next-server 10.55.156.40;})
          }

          it {
            is_expected.to contain_concat__fragment('dhcp_group_namevar')
              .with_content(%r{option tftp-server-name "10.55.156.40";})
          }

          context 'when option tftp-server-name disabled' do
            let(:params) do
              super().merge(
                tftp_server_name: false,
              )
            end

            it {
              is_expected.to contain_concat__fragment('dhcp_group_namevar')
              is_expected.not_to contain_concat__fragment('dhcp_group_namevar')
                .with_content(%r{option tftp-server-name})
            }
          end
        end

        context 'when host declaration in use as client hostname' do
          let(:params) do
            super().merge(
              pxe_filename: 'boot/grub/i386-pc/core.0',
            )
          end

          it {
            is_expected.to contain_concat__fragment('dhcp_group_namevar')
              .with_content(%r{filename "boot/grub/i386-pc/core.0";})
          }
        end
      end

      context 'with host record declared' do
        let(:params) do
          super().merge(
            host: {
              'web-dev-005' => {
                mac: '00:50:56:a5:e9:81',
                ip: '10.55.156.5',
                mask: '255.255.255.0',
                routers: '10.55.156.1',
                host_name: 'web-dev-005.domain.tld',
                filename: '/pxelinux.0'
              }
            },
          )
        end

        it {
          is_expected.to contain_concat__fragment('dhcp_group_namevar')
            .with_content(%r{host web-dev-005})
        }

        it {
          is_expected.to contain_concat__fragment('dhcp_group_namevar')
            .with_content(%r{hardware ethernet 00:50:56:A5:E9:81;})
        }

        it {
          is_expected.to contain_concat__fragment('dhcp_group_namevar')
            .with_content(%r{fixed-address 10.55.156.5;})
        }

        it {
          is_expected.to contain_concat__fragment('dhcp_group_namevar')
            .with_content(%r{option subnet-mask 255.255.255.0;})
        }

        it {
          is_expected.to contain_concat__fragment('dhcp_group_namevar')
            .with_content(%r{option routers 10.55.156.1;})
        }

        it {
          is_expected.to contain_concat__fragment('dhcp_group_namevar')
            .with_content(%r{option host-name "web-dev-005.domain.tld";})
        }

        it {
          is_expected.to contain_concat__fragment('dhcp_group_namevar')
            .with_content(%r{filename "/pxelinux.0";})
        }
      end
    end
  end
end
