# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::postgres' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_yumrepo('yum.postgresql.org')
          .with_baseurl(%r{^https://download.postgresql.org/pub/repos/yum/12/redhat/rhel-\$releasever-\$basearch})
          .that_notifies('Exec[yum-reload-e0c99ff]')
      }

      if os == 'centos-8-x86_64'
        it {
          is_expected.to contain_package('postgresql-server')
            .with_ensure('12.8')
            .with_name('postgresql-server')
        }
      else
        it {
          is_expected.to contain_package('postgresql-server')
            .with_ensure('12.8')
            .with_name('postgresql12-server')
        }
      end
    end
  end
end
