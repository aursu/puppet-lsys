# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::webserver::client_auth' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      case os
      when %r{^centos-}, %r{^rocky-}
        it {
          is_expected.to contain_file('/etc/pki/tls/certs/internal/ca.pem')
        }
      when %r{ubuntu-}
        it {
          is_expected.to contain_file('/etc/ssl/certs/internal/ca.pem')
        }
      end
    end
  end
end
