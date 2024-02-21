# frozen_string_literal: true

require 'spec_helper'

describe 'lsys::db', type: :define do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(root_home: '/root')
      end

      let(:title) { 'test_db' }

      let(:params) do
        { 'user' => 'testuser',
          'password' => 'testpass',
          'mysql_exec_path' => '' }
      end

      let(:sql) { ['/tmp/test.sql'] }

      context 'does not notify the import sql exec if no sql script was provided' do
        it {
          is_expected.to contain_mysql_database('test_db').without_notify
        }
      end

      context 'subscribes to database if sql script is given' do
        let(:params) do
          super().merge(
            sql: sql,
          )
        end

        it {
          is_expected.to contain_mysql_database('test_db')
        }

        it {
          is_expected.to contain_exec('test_db-import').with_subscribe('Mysql_database[test_db]')
        }
      end

      context 'onlies import sql script on creation if not enforcing' do
        let(:params) do
          super().merge(
            sql: sql,
            enforce_sql: false,
          )
        end

        it {
          is_expected.to contain_exec('test_db-import').with_refreshonly(true)
        }
      end

      context 'imports sql script on creation' do
        let(:params) do
          super().merge(
            sql: sql,
            enforce_sql: true,
          )
        end

        it {
          is_expected.to contain_exec('test_db-import').with_refreshonly(false)
        }

        it {
          is_expected.to contain_exec('test_db-import').with_command('cat /tmp/test.sql | mysql test_db')
        }
      end

      context 'imports sql script with custom command on creation' do
        let(:params) do
          super().merge(
            sql: sql,
            enforce_sql: true,
            import_cat_cmd: 'zcat',
          )
        end

        it {
          # if enforcing #refreshonly
          is_expected.to contain_exec('test_db-import').with_refreshonly(false)
        }

        it {
          # if enforcing #command
          is_expected.to contain_exec('test_db-import').with_command('zcat /tmp/test.sql | mysql test_db')
        }
      end

      context 'imports sql scripts when more than one is specified' do
        let(:params) do
          super().merge(
            sql: ['/tmp/test.sql', '/tmp/test_2.sql'],
          )
        end

        it {
          is_expected.to contain_exec('test_db-import').with_command('cat /tmp/test.sql /tmp/test_2.sql | mysql test_db')
        }
      end

      context 'does not create database' do
        let(:params) do
          super().merge(
            ensure: 'absent',
            host: 'localhost',
          )
        end

        it {
          is_expected.to contain_mysql_database('test_db').with_ensure('absent')
        }

        it {
          is_expected.to contain_mysql_user('testuser@localhost').with_ensure('absent')
        }
      end

      context 'creates with an appropriate collate and charset' do
        let(:params) do
          super().merge(
            charset: 'utf8',
            collate: 'utf8_danish_ci',
          )
        end

        it {
          is_expected.to contain_mysql_database('test_db').with(
            'charset' => 'utf8',
            'collate' => 'utf8_danish_ci',
          )
        }
      end

      context 'uses dbname parameter as database name instead of name' do
        let(:params) do
          super().merge(
            dbname: 'real_db',
          )
        end

        it {
          is_expected.to contain_mysql_database('real_db')
        }
      end

      context 'uses tls_options for user when set' do
        let(:params) do
          super().merge(
            tls_options: ['SSL'],
          )
        end

        it {
          is_expected.to contain_mysql_user('testuser@localhost').with_tls_options(['SSL'])
        }
      end

      context 'uses grant_options for grant when set' do
        let(:params) do
          super().merge(
            grant_options: ['GRANT'],
          )
        end

        it {
          is_expected.to contain_mysql_grant('testuser@localhost/test_db.*').with_options(['GRANT'])
        }
      end

      # Invalid file paths
      [
        '|| ls -la ||',
        '|| touch /tmp/foo.txt ||',
        '/tmp/foo.txt;echo',
        'myPath;',
        '\\myPath\\',
        '//myPath has spaces//',
        '/',
      ].each do |path|
        context "fails when provided '#{path}' as a value to the 'sql' parameter" do
          let(:params) do
            super().merge(
              sql: [path],
            )
          end

          it {
            is_expected.to raise_error(Puppet::PreformattedError, %r{The file '#{Regexp.escape(path)}' is invalid. A valid file path is expected.})
          }
        end
      end

      # Valid file paths
      [
        '/tmp/test.txt',
        '/tmp/.test',
        '/foo.test',
        '/foo.test.txt',
        '/foo/test/test-1.2.3/schema/test.sql',
        '/foo/test/test-1.2.3/schema/foo.test.sql',
        '/foo/foo.t1.t2.t3/foo.test-1.2.3/test.test.schema/test..app.sql',
        '/foo/foo.t1.t2...t3/foo.test-1.2.3/test.test.schema/test.app.sql',
      ].each do |path|
        context "succeeds when provided '#{path}' as a value to the 'sql' parameter" do
          let(:params) do
            super().merge(
              sql: [path],
            )
          end

          it {
            is_expected.to contain_exec('test_db-import').with_command("cat #{path} | mysql test_db")
          }
        end
      end

      # Invalid database names
      [
        'test db',
        'test_db;',
        'test/db',
        '|| ls -la ||',
        '|| touch /tmp/foo.txt ||',
      ].each do |name|
        context "fails when provided '#{name}' as a value to the 'name' parameter" do
          let(:params) do
            super().merge(
              name: name,
            )
          end

          it {
            is_expected.to raise_error(Puppet::PreformattedError, %r{The database name '#{name}' is invalid.})
          }
        end
      end

      # Valid database names
      [
        'test_db',
        'testdb',
        'test-db',
        'TESTDB',
      ].each do |name|
        context "succeeds when the provided '#{name}' as a value to the 'dbname' parameter" do
          let(:params) do
            super().merge(
              dbname: name,
            )
          end

          it {
            is_expected.to contain_mysql_database(name)
          }
        end
      end
    end
  end
end
