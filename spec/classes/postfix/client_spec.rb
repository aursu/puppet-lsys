# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::postfix::client' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it {
        is_expected.to contain_user('postfix')
      }

      it {
        is_expected.to contain_group('postdrop')
      }

      it {
        is_expected.not_to contain_file('/var/spool/postfix/maildrop')
      }

      it {
        is_expected.not_to contain_file('/var/spool/postfix/public')
      }

      if os == 'rocky-8-x86_64'
        it {
          is_expected.to contain_file('/etc/postfix/master.cf')
            .with_content(%r{^127.0.0.1:smtp      inet  n       -       n       -       -       smtpd})
            .with_content(%r{^postlog   unix-dgram n  -       n       -       1       postlogd})
            .with_content(%r{^bounce    unix  -       -       n       -       0       bounce})
        }
      end

      # Postfix on EL10 is built without Berkeley DB: `postconf -m` offers lmdb
      # and no longer offers hash, and the distribution's own main.cf already
      # reads lmdb:/etc/aliases. Everything older keeps hash, unchanged.
      it 'passes the lookup table type the release actually supports' do
        expected = (os_facts[:os]['release']['major'] == '10') ? 'lmdb' : 'hash'

        is_expected.to contain_class('postfix').with(
          lookup_table_type: expected,
          alias_maps: "#{expected}:/etc/aliases",
        )
      end

      context 'when the lookup table type is given explicitly' do
        let(:params) do
          {
            lookup_table_type: 'cdb',
          }
        end

        it 'uses it for both the maps and the aliases' do
          is_expected.to contain_class('postfix').with(
            lookup_table_type: 'cdb',
            alias_maps: 'cdb:/etc/aliases',
          )
        end
      end

      context 'when SGID bits removed from binaries' do
        let(:params) do
          {
            postdrop_nosgid: true,
          }
        end

        it {
          is_expected.to contain_file('/var/spool/postfix/maildrop')
            .with_mode('1733')
        }

        it {
          is_expected.to contain_file('/var/spool/postfix/public')
            .with_mode('0711')
        }
      end

      context 'when Mail Log file defined' do
        let(:params) do
          {
            maillog_file: '/var/log/maillog',
          }
        end

        it {
          is_expected.to contain_augeas("manage postfix 'maillog_file'")
            .with_changes(%r{set maillog_file '/var/log/maillog'})
        }
      end
    end
  end

  # facterdb ~> 3.0, which this module's Gemfile pins, ships no rocky-10
  # factset, so release 10 is exercised by moving a real Rocky factset forward
  # rather than by inventing one. Drop this once the pin can reach facterdb 4.2
  # and let on_supported_os cover it.
  _os, rocky9 = on_supported_os.find { |os, _facts| os.start_with?('rocky-9') }

  context 'on Rocky 10' do
    let(:facts) do
      rocky9.merge(
        os: rocky9[:os].merge(
          'release' => rocky9[:os]['release'].merge('major' => '10', 'full' => '10.2'),
        ),
      )
    end

    it { is_expected.to compile }

    it 'switches the lookup table type to lmdb' do
      is_expected.to contain_class('postfix').with(
        lookup_table_type: 'lmdb',
        alias_maps: 'lmdb:/etc/aliases',
      )
    end

    # The module's own master.cf carries the postlogd service; the postfix
    # module's RedHat template does not gain it before its v5.1.0, and the
    # maillog_file parameter has nothing writing to it without one.
    it "keeps using this module's own master.cf template" do
      is_expected.to contain_file('/etc/postfix/master.cf')
        .with_content(%r{^postlog   unix-dgram n  -       n       -       1       postlogd})
    end
  end
end
