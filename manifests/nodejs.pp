# @summary NodeJS installation
#
# NodeJS installation
#
# @example
#   include lsys::nodejs
class lsys::nodejs (
  # https://nodejs.org/en/about/releases/
  # 12.x - EOL 2022-04-30
  # 14.x - EOL 2023-04-30
  # 15.x - EOL 2021-06-01
  # 16.x - EOL 2024-04-30
  # 18.x - EOL 2025-04-30
  # 19.x - EOL 2023-06-01
  # 20.x - EOL 2026-04-30
  Enum['18.x', '20.x'] $release = '18.x',
) {
  class { 'nodejs':
    repo_url_suffix => $release,
    repo_enable_src => false,
  }

  file { '/etc/yum.repos.d/nodesource.repo':
    mode => '0640',
  }
}
