# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::postgres' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      case os
      when %r{^centos-8}
        it {
          is_expected.to contain_package('postgresql-server')
            .with_ensure('15.0')
            .with_name('postgresql-server')
        }
      when %r{^centos-7}
        it {
          is_expected.to contain_yumrepo('yum.postgresql.org')
            .with_baseurl(%r{^https://download.postgresql.org/pub/repos/yum/15/redhat/rhel-\$releasever-\$basearch})
            .that_notifies('Exec[yum-reload-9c247b8]')
        }

        it {
          is_expected.to contain_package('postgresql-server')
            .with_ensure('15.4')
            .with_name('postgresql15-server')
        }
      when %r{^rocky}
        it {
          is_expected.to contain_package('postgresql-server')
            .with_ensure('15.2')
            .with_name('postgresql-server')
        }
      else
        it {
          is_expected.to contain_package('postgresql-server')
            .with_ensure('15.4')
        }
      end
    end
  end
end
