# frozen_string_literal: true

require 'spec_helper'

local_facts = {
  'root_home' => '/root',
}

describe 'lsys::graylog' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(local_facts) }
      let(:params) do
        {
          'root_password' => 'secret',
          'password_secret' => '1H3RGlH5vNZUYgLAD7hDya74PmsioxpJZIIIjiEHySOF68ozxxaIUbJSygIDGvMKAGvaVfYgbqDxk2Cji3sLqQ9MncSSE73o',
          'mongodb_password' => 'SecretP@ssword',
        }
      end

      it { is_expected.to compile }

      context 'enable web service' do
        let(:params) do
          super().merge(
            http_server: 'graylog.domain.tld',
          )
        end

        it { is_expected.to compile }
      end
    end
  end
end
