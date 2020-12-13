# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::resolv' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_file('/etc/resolv.conf') }
      it { is_expected.to contain_file('/etc/resolv.conf').without_content(%r{^search}) }
      it { is_expected.to contain_file('/etc/resolv.conf').without_content(%r{^nameserver}) }
      it { is_expected.to contain_file('/etc/resolv.conf').without_content(%r{^options}) }
      it { is_expected.to contain_file('/etc/resolv.conf').without_content(%r{^sortlist}) }

      context 'with nameserver specified' do
        let(:params) do
          {
            nameserver: ['8.8.4.4', '8.8.8.8', '1.1.1.1'],
          }
        end

        it { is_expected.to contain_file('/etc/resolv.conf').with_content(%r{^nameserver 8.8.4.4\nnameserver 8.8.8.8\nnameserver 1.1.1.1}) }
      end

      context 'with options specified' do
        let(:params) do
          {
            options: ['debug', { 'ndots' => 2 }, 'timeout:20', 'rotate'],
          }
        end

        it { is_expected.to contain_file('/etc/resolv.conf').with_content(%r{^options debug ndots:2 timeout:20 rotate}) }
      end
    end
  end
end
