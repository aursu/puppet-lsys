# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::nodejs' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      if ['redhat-7-x86_64', 'centos-7-x86_64'].include?(os)
        it {
          is_expected.to contain_yumrepo('nodesource')
            .with_baseurl("https://rpm.nodesource.com/pub_18.x/nodistro/nodejs/\$basearch")
        }

        it {
          is_expected.to contain_package('nodejs')
            .with_ensure('installed')
        }
      end
    end
  end
end
