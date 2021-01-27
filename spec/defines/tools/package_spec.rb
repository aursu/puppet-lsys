# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::tools::package' do
  let(:title) { 'sudo' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.not_to contain_package('sudo') }

      context 'check boolean ensure => false' do
        let(:params) { { ensure: false } }

        it { is_expected.not_to contain_package('sudo') }
      end

      context 'check boolean ensure => true' do
        let(:params) { { ensure: true } }

        it { is_expected.to contain_package('sudo').with_ensure('installed') }
      end

      context 'check string ensure => latest' do
        let(:params) { { ensure: 'latest' } }

        it { is_expected.to contain_package('sudo').with_ensure('latest') }
      end

      context 'check string ensure => numeric' do
        let(:params) { { ensure: '1.8.23-10.el7_9.1' } }

        it { is_expected.to contain_package('sudo').with_ensure('1.8.23-10.el7_9.1') }
      end
    end
  end
end
