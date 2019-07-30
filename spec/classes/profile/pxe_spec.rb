require 'spec_helper'

describe 'lsys::profile::pxe' do
  let(:ssh_rsa_id) do
    <<-PRIVATEKEY
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAt1ksv3M1S/tg/qeTmUSMhUn5xJzZQ98vf2EXp3eBFtNCfO/c
jLGu7oClGPpjNqmR1p+zdud0R+UOuwfS5gXOze9/lbY1iGU+BPLz8YwSPyeceG32
48OnP9TJByhKqLCytylZog+4Wz4AtBdCKj5bxwXTsYB0pthegTQkUeG6gU75U4hg
nmCkDCEYleEK9iUjfZ7x8HlT9nkwXBigDyzpwpi3NWjnI6YPKXTxbjE7e5bM87I1
bbdjmwH7Mev8esOlT7XREo3XTvhiFWLLilSRdOB0Nuz8oluEMKTA3+9bCVCQ7/or
nANcLXreMfEDt5NVu/eqeZ0/Fepoti5Vv8mkwQIDAQABAoIBACmHLTd/5MZ8/Y8w
baH9gMZ/5u69iAhzeNKlLzJjQv3kg97AhXfolvK2eK6bp/Utmza9nWyFKDVQkHGU
aBRppFnIsWE7kAyAwfdlABPp4ggj9LDiV1Vnb25px86zNZXXz+LknsSyQtOHy6j+
y6G91hPSIgzGR6WyxFUHdmKFejTnR+wE2X/HreChrH0Qia6qIbEPL5maGR0U5hD4
EcfBmiXPmpRHhN4ZiReIt60vGSDk0PWHSeZdAM9S1rMIIe09ZKuaTOyTUPAUTORD
rLbCMoc4TUgrjV8ma/LaL+Beqxz1nnRPcKWfk/m7r/bgSleVmOK/LJK3ncWA7XVL
CqdeJUECgYEA6dIECm0P5mm8TbMLRoOgr4kOq9wKjjvR9oCWNQOgt3iXTXYWu4WG
gB4K3AQ+QGiSQOGDIGJ1HuwxgmavaMpb703U3Ijc0Oh3XTypP3vNbGXgba1/lIUb
DESeJz6UDb+WsXPck59u+81bZw2EYIuvWBaY6YCvQiGKyF3+WLnTCvUCgYEAyL2F
Eb/inRGI676IHOYRqEJczNx1EnQd5LLo8zkE0RnBY5waV6ur9JIb8DLaG0o9kKcM
HfvBoJBl/pc+JaLCDBUS9ak2jVf+95eGabrMy+gc/X3khAGXv7ZjZ9lCRQQtbnSh
9SpzPIzUlp+xzrPb+wTGLDXFNcc2HaZ5zWH5ax0CgYBugC4gr0IgZj/ziHX/sR0z
V9ZzKd5jMaockNBr5XcCvh7jILfFj2jtC0WejPLOhZz4xJqvp1gqcP1E3zpuj5O7
GFFMl/GjWPlwOsbRlbSTUeIqcyAkFHOf7J3BdjWJ+c1Bt7u6mFJe9cIIhb7V0a3g
N220jHhHDIsF/kXBsLAoMQKBgEAp8+Lchr7V4AIagL9b+sDhlXAV94XSf8ueND+q
NhPwO5RvTSxAv1IJccyxNG4MqOkXvBPJaPa9sRxTk5XMFGJwSgMj9z/upJzXXitl
fhifNMUB/I0FRVAOKHAFTd1pnGv18969lt//0+PhX6BGdUYjHIT9GvA5oN6RW9V+
P48xAoGBANkZ3UPNk+SvHH50Fd2flEIn0WJCkmiOm1Aq64a7u6HjmzORJO2iwt+o
5mGOebGzbiVAuX5UDjUtUECHmB+N5euPVR0rh6KmSS4LILmihKhQC1TzPMgADTq8
T6plhPLwidmKGX1PiwTFbOc6bCg6XIwZuvd9LCxgTVTHvf05l1u9
-----END RSA PRIVATE KEY-----
PRIVATEKEY
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          install_server:         'install.domain.tld',
          install_server_address: '192.168.1.10',
          resolver: ['192.168.1.1', '8.8.8.8', '1.1.1.1'],
          dhcp_default_subnet: {
            'VLAN400' => {
              network: '192.168.1.0',
              mask: '255.255.255.0',
              broadcast: '192.168.1.255',
              routers: '192.168.1.1',
              domain_name: 'domain.tld',
              nameservers: ['192.168.1.1', '8.8.8.8', '1.1.1.1']
            }
          },
          enc_repo_source: 'git@gitlab.domain.tld:infra/enc.git',
          enc_repo_identity: ssh_rsa_id,
          enc_repo_branch: 'master'
        }
      end

      it {
        is_expected.to compile
      }
    end
  end
end
