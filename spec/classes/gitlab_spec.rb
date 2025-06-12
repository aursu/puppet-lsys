# frozen_string_literal: true

require 'spec_helper'

puppet_sslcert = {
  'hostcert' => {
    'path' => '/etc/puppetlabs/puppet/ssl/certs/gitlab.domain.tld.pem',
    'data' => '-----BEGIN CERTIFICATE-----
MIIDezCCAmOgAwIBAgIBAjANBgkqhkiG9w0BAQsFADAnMSUwIwYDVQQDDBxQdXBw
ZXQgQ0E6IHB1cHBldC5kb21haW4udGxkMB4XDTIwMDkxMDIwMzkxM1oXDTIxMDkx
MDIwMzkxM1owHDEaMBgGA1UEAwwRZ2l0bGFiLmRvbWFpbi50bGQwggEiMA0GCSqG
SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCqUh5O9lE0ArMRzvzeXaIrqIlIjWZFzS72
4qQ+NFX5x+cmsrpKn2EZQBGe06410nQWNuWdtUgldMBlA/AKXvJELNYo/OIjBwAa
zf9lKKD4TdWqB+OnbrlNHHGFVNCbCjIHy+0ZO34CeTn/f8IR/UadLp32CgCxX/pi
HPkdMZOJ4OD04zEQH5hRL69bCEaIGeqxWifrYjtY6NLP8eZdzYDb+smX8mF47TL8
geUy9C3owNNxfFxJ352Q9TLh8pHEIvBBE4aU0VSEQYYemKhPb5FfzntZ++1WKRgt
DbsPHe49zGW3XUGaT8RakImlLaNzwFukLHoUQc2c5pN/GuwWAZy/AgMBAAGjgbww
gbkwNwYJYIZIAYb4QgENBCoWKFB1cHBldCBSdWJ5L09wZW5TU0wgSW50ZXJuYWwg
Q2VydGlmaWNhdGUwDgYDVR0PAQH/BAQDAgWgMCAGA1UdJQEB/wQWMBQGCCsGAQUF
BwMBBggrBgEFBQcDAjAMBgNVHRMBAf8EAjAAMB0GA1UdDgQWBBSkAuzYqYjiGZ8H
Fylh/TFu1ShZxTAfBgNVHSMEGDAWgBS1nyWNzIAheLXbl7+ad7b5UBRXoDANBgkq
hkiG9w0BAQsFAAOCAQEAZdbaHB5JFVV9fpEwbBFM235yGVQATdgB8SXDpn/KTKX8
FfyzHxJ5QX0Fb9deR0ZhgXesa0S5QOvyQTN0R00fjaV8KKlXDiElQKmxcaHhtD21
N+W9tiRmKqLinvA8dPYOByL6nWSF2PMRkiTHxjO2+YBBYCCGYJsygdIA5RaD/Cou
51CNxbKKpcrsO+kmKSxmZC97V67xRD4Z3DeaGVYcV7nLzwHO4tbZlUKHtlPRXo8M
a/sYFsthasPKSnjtGup40hJdpeuc4IPy3k5yjB6nmgNSmm/V7+4rOhB7VAbukc79
z2FjmEt7Mf+o3qNO/6/yGZipvb0zjTzcZhnxGaM7oQ==
-----END CERTIFICATE-----
',
  },
  'localcacert' => {
    'path' => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
    'data' => '-----BEGIN CERTIFICATE-----
MIIDgTCCAmmgAwIBAgIBATANBgkqhkiG9w0BAQsFADAnMSUwIwYDVQQDDBxQdXBw
ZXQgQ0E6IHB1cHBldC5kb21haW4udGxkMB4XDTIwMDkxMDIwMzUxMVoXDTMwMDkw
ODIwMzUxMVowJzElMCMGA1UEAwwcUHVwcGV0IENBOiBwdXBwZXQuZG9tYWluLnRs
ZDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALJgXuAvAms0dNPxObJg
Mk6u9JgSyiQn/RHMxECGaF3M5vpvi9r6raARtT+RGsqoyo+Max/HFpiZXUmzEbDG
XuxrmhtlNaqIx1AnDw/E61ZDad9/VsLnC+NTwrV7EFZGzTNHSQGyqeb7aOmqTlui
nSZPv4ZQAdnwMeoLdnXCV1ezQ7H1+6ZxJeBprABkYG2/gYFFdpYCuvmFh/m0uWEz
mBrx844Yi/SLtAhY3LEnjLnxSjsyGC1wQ/V+vbxFaeG5BIl/kVVqGXgoY58N6ndJ
m4GcAobPO5UIAxDj8HsZSQTjmzbQBh01eSDr239Auem+EfCPE3VJOli0zynAKg9/
CaMCAwEAAaOBtzCBtDA3BglghkgBhvhCAQ0EKhYoUHVwcGV0IFJ1YnkvT3BlblNT
TCBJbnRlcm5hbCBDZXJ0aWZpY2F0ZTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/
BAUwAwEB/zAdBgNVHQ4EFgQUtZ8ljcyAIXi125e/mne2+VAUV6AwOQYDVR0jBDIw
MKErpCkwJzElMCMGA1UEAwwcUHVwcGV0IENBOiBwdXBwZXQuZG9tYWluLnRsZIIB
ATANBgkqhkiG9w0BAQsFAAOCAQEAmwpFypAWQ9F4cMfGvE44b9h6NQSM9DjShb7j
U9eadbUQ6l8i/ddskQ1IDdh0BV0TVeatX4OhdwmeNmF433BJwzrwqbd3GaoCivUX
tHzwFLi++J32aCBTqMolRCR6okzAQzdaE1fZzM4YGoet0XtecYKCxIWIzlXDAAu/
0eOG2F5RScqsWz/L/DDNeqDMSm1qpIiwiFVBXGSTCwAF5DhrMI9H7SoPKjrPltI7
wYdeHV72guqAp8vOZSP4MiM2dkhY7QIdin6AAIKrps+wFqAEJvYscIY5HOw2AOTy
ROxDS2uWHhQk6CjTo9U9CCKi76v9Pkg5Tv0uTo1KKfDeJuvSUA==
-----END CERTIFICATE-----
',
  },
  'hostprivkey' => {
    'path' => '/etc/puppetlabs/puppet/ssl/private_keys/gitlab.domain.tld.pem',
  },
  'hostpubkey' => {
    'path' => '/etc/puppetlabs/puppet/ssl/public_keys/gitlab.domain.tld.pem',
    'data' => '-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqlIeTvZRNAKzEc783l2i
K6iJSI1mRc0u9uKkPjRV+cfnJrK6Sp9hGUARntOuNdJ0FjblnbVIJXTAZQPwCl7y
RCzWKPziIwcAGs3/ZSig+E3Vqgfjp265TRxxhVTQmwoyB8vtGTt+Ank5/3/CEf1G
nS6d9goAsV/6Yhz5HTGTieDg9OMxEB+YUS+vWwhGiBnqsVon62I7WOjSz/HmXc2A
2/rJl/JheO0y/IHlMvQt6MDTcXxcSd+dkPUy4fKRxCLwQROGlNFUhEGGHpioT2+R
X857WfvtVikYLQ27Dx3uPcxlt11Bmk/EWpCJpS2jc8BbpCx6FEHNnOaTfxrsFgGc
vwIDAQAB
-----END PUBLIC KEY-----
',
  },
  'hostreq' => {
    'path' => '/etc/puppetlabs/puppet/ssl/certificate_requests/gitlab.domain.tld.pem',
    'data' => '-----BEGIN CERTIFICATE REQUEST-----
MIICnzCCAYcCAQAwHDEaMBgGA1UEAwwRZ2l0bGFiLmRvbWFpbi50bGQwggEiMA0G
CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCqUh5O9lE0ArMRzvzeXaIrqIlIjWZF
zS724qQ+NFX5x+cmsrpKn2EZQBGe06410nQWNuWdtUgldMBlA/AKXvJELNYo/OIj
BwAazf9lKKD4TdWqB+OnbrlNHHGFVNCbCjIHy+0ZO34CeTn/f8IR/UadLp32CgCx
X/piHPkdMZOJ4OD04zEQH5hRL69bCEaIGeqxWifrYjtY6NLP8eZdzYDb+smX8mF4
7TL8geUy9C3owNNxfFxJ352Q9TLh8pHEIvBBE4aU0VSEQYYemKhPb5FfzntZ++1W
KRgtDbsPHe49zGW3XUGaT8RakImlLaNzwFukLHoUQc2c5pN/GuwWAZy/AgMBAAGg
PjA8BgkqhkiG9w0BCQ4xLzAtMB0GA1UdDgQWBBSkAuzYqYjiGZ8HFylh/TFu1ShZ
xTAMBgNVHRMBAf8EAjAAMA0GCSqGSIb3DQEBCwUAA4IBAQCOt66RVxnisLiBccBp
E6wDH1fn1iiEJEkbN7zSmjGUWttyADVWYa3yAEFcd4Qt+32GQW5+Zsq75Lf5p7L1
NnPAmiXfAprxv7fm4h22Jgv/9xKTzT2blZElCY0x9engGDEZOS+KMDDaZ/PZnCOu
Xy6Pc3xtg25GzfLQ406lqYbmyBrrRu0kWPYnR8/OtwcoT+KjIuibwkuRuvGDDVbQ
5nShJxx7BcYIpHAsgDCiCQcGUntgSrMFY6diKip1eyplhyCY8sSFr6drAIJQt4sE
E32dLRRGEoEV7eWthNpEf7yrt8aoWwRXGrdFYwBslvzTU9GYOZ+ElZGgXlXT7zp7
OsAB
-----END CERTIFICATE REQUEST-----
',
  },
}

describe 'lsys::gitlab' do
  let(:pre_condition) do
    <<-PRECOND
    tlsinfo::certificate { 'f1453246': }
    PRECOND
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          puppet_sslcert: puppet_sslcert,
          stype: 'web',
        )
      end
      let(:params) do
        {
          external_url: 'https://ci.domain.tld',
          registry_host: 'registry.domain.tld',
          database_password: 'AVerySecurePassword',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('lsys::gitlab') }
      it { is_expected.to contain_class('lsys_postgresql') }
      it { is_expected.to contain_class('gitlabinstall') }
      it { is_expected.to contain_class('gitlabinstall::external_registry') }
      it { is_expected.to contain_class('gitlabinstall::gitlab') }

      context 'with custom database_max_connections' do
        let(:params) do
          super().merge(
            database_max_connections: 123,
          )
        end

        it {
          is_expected.to contain_class('gitlabinstall::gitlab')
            .with_database_max_connections(123)
        }
      end

      context 'with ldap enabled and required params' do
        let(:params) do
          super().merge(
            ldap_enabled: true,
            ldap_host: 'ldap.example.com',
            ldap_password: 'secret',
            ldap_base: 'dc=example,dc=com',
          )
        end

        it { is_expected.to contain_class('gitlabinstall::ldap') }
      end

      context 'with manage_nginx_core => false' do
        let(:pre_condition) do
          <<-PRECOND
          include nginx
          tlsinfo::certificate { 'f1453246': }
          PRECOND
        end

        let(:params) do
          super().merge(
            manage_nginx_core: false,
          )
        end

        it {
          is_expected.to contain_class('gitlabinstall::gitlab')
            .with_manage_nginx_core(false)
        }
      end
    end
  end
end
