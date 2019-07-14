# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include lsys::pxe::enc
class lsys::pxe::enc  (
  String  $repo_source,
  String  $repo_revision  = 'master',
  Optional[Stdlib::Unixpath]
          $repo_identity  = undef,
){
  include lsys::pxe::storage

  vcsrepo { '/var/lib/pxe/enc':
    ensure     => latest,
    provider   => 'git',
    source     => $repo_source, # eg git@git.domain.tld:project/enc.git
    revision   => $repo_revision,
    submodules => false,
    identity   => $repo_identity,
  }
}
