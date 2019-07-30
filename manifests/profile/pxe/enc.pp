# ENC repository setup
#
# @summary ENC repository setup
#
# @example
#   class { 'lsys::profile::pxe::enc':
#     repo_source   => 'git@gitlab.domain.tld:infra/enc.git',
#     repo_identity => lookup('profile::pxe::enc_identity', String, 'first', undef),
#     repo_branch   => 'master',
#   }
class lsys::profile::pxe::enc (
  String $repo_source,
  String $repo_identity,
  String $repo_branch = 'enc',
)
{
  openssh::priv_key { 'enc-e39b7d4':
    user_name  => 'root',
    key_data   => $repo_identity,
    key_prefix => 'enc',
  }

  class { 'lsys::pxe::enc':
    repo_source   => $repo_source,
    repo_revision => $repo_branch,
    repo_identity => '/root/.ssh/enc.id_rsa',
    require       => Openssh::Priv_key['enc-e39b7d4'],
  }
}
