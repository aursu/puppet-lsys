# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::hardening::chmod_directory' do
  let(:title) { '/etc' }
  let(:params) do
    {
      mode: '0710',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
