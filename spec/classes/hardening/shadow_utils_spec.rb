# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::hardening::shadow_utils' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('/etc/login.defs')
          .with_content(%r{^PASS_MAX_DAYS 180$})
      }

      it {
        is_expected.to contain_file('/etc/login.defs')
          .with_content(%r{^PASS_MIN_DAYS 0$})
      }

      it {
        is_expected.to contain_file('/etc/login.defs')
          .with_content(%r{^PASS_MIN_LEN 8$})
      }

      it {
        is_expected.to contain_file('/etc/login.defs')
          .with_content(%r{^PASS_WARN_AGE 14$})
      }

      if ['redhat-6-x86_64', 'centos-6-x86_64'].include?(os)
        it {
          is_expected.to contain_file('/etc/login.defs')
            .with_content(%r{^UID_MIN 500$})
        }

        it {
          is_expected.to contain_file('/etc/login.defs')
            .with_content(%r{^GID_MIN 500$})
        }
      else
        it {
          is_expected.to contain_file('/etc/login.defs')
            .with_content(%r{^UID_MIN 1000$})
        }

        it {
          is_expected.to contain_file('/etc/login.defs')
            .with_content(%r{^GID_MIN 1000$})
        }
      end
    end
  end
end
