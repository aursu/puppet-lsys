# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::monit' do
  on_supported_os.each do |os, os_facts|
    next if os == 'centos-8-x86_64'

    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
