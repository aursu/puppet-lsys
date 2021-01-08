# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::bindmount' do
  let(:title) { '/mnt/share/www/www.domain.com' }
  let(:params) do
    {
      source: '/var/www/www.domain.com',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_mount('/mnt/share/www/www.domain.com bind')
          .with(
            ensure: 'mounted',
            device: '/var/www/www.domain.com',
            name: '/mnt/share/www/www.domain.com',
            fstype: 'none',
            options: 'bind',
          )
      }

      context 'when file resource control enabled' do
        let(:pre_condition) do
          <<-PRECOND
          file { '/mnt/share/www/www.domain.com': }
          PRECOND
        end
        let(:params) do
          super().merge(
            require_target: true,
          )
        end

        it {
          is_expected.to contain_mount('/mnt/share/www/www.domain.com bind')
            .that_requires('File[/mnt/share/www/www.domain.com]')
        }
      end
    end
  end
end
