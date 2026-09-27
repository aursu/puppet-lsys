# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::hardening::root_access' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      # The switch defaults to true, and bites only on release 8.
      if os_facts[:os]['family'] == 'RedHat' && os_facts[:os]['release']['major'] == '8'
        it { is_expected.to contain_sysctl('fs.protected_symlinks').with_value('0') }
      else
        it { is_expected.not_to contain_sysctl('fs.protected_symlinks') }
      end
    end
  end
end
