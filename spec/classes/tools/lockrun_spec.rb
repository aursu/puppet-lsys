# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::tools::lockrun' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_class('lsys::tools::system')
      }

      it {
        is_expected.not_to contain_file('/usr/local/bin/lockrun')
      }

      context 'check lockrun installation' do
        let(:params) do
          {
            custom: true,
          }
        end

        it { is_expected.to compile }

        case os
        when %r{^centos-[78]}, %r{^rocky-8}
          it {
            is_expected.to contain_file('/usr/local/bin/lockrun')
              .with_source(%r{^puppet:///modules/lsys/lockrun/lockrun\.el[678]$})
          }
        end
      end
    end
  end
end
