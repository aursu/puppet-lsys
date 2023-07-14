# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::monit::prebuilt_binary' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      case os
      when 'rocky-8-x86_64'
        it {
          is_expected.to contain_package('libnsl')
            .with_ensure('installed')
        }
      else
        it {
          is_expected.not_to contain_package('libnsl')
        }
      end
    end
  end
end
