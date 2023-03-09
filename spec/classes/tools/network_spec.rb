# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::tools::network' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_package('iputils')
          .with_ensure('installed')
      }

      it {
        is_expected.to contain_package('iproute')
          .with_ensure('installed')
      }
    end
  end
end
