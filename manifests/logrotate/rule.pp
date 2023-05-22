# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   lsys::logrotate::rule { 'namevar': }
define lsys::logrotate::rule (
  Variant[
    Stdlib::Unixpath,
    Array[Stdlib::Unixpath]
  ] $path,
  Optional[Lsys::Logrotate] $config = undef,
) {
  include lsys::params

  if $config {
    $rule_config = $config
  }
  else {
    $rule_config = $lsys::params::logrotate_default_config
  }

  if $rule_config['hourly'] {
    $rotate_every = 'hour'
  }
  elsif $rule_config['daily'] {
    $rotate_every = 'day'
  }
  elsif $rule_config['weekly'] {
    $rotate_every = 'week'
  }
  elsif $rule_config['monthly'] {
    $rotate_every = 'month'
  }
  elsif $rule_config['yearly'] {
    $rotate_every = 'year'
  }
  else {
    $rotate_every = undef
  }

  if $rule_config['notifempty'] {
    $config_ifempty = { 'ifempty' => false }
  }
  else {
    $config_ifempty = {}
  }

  $config_postrotate = $rule_config['postrotate'] ? {
    true => { 'postrotate' => $lsys::params::logrotate_postrotate },
    default => {},
  }

  $noconfig_postrotate = $rule_config['postrotate'] ? {
    false => ['postrotate'],
    default => [],
  }

  if $rule_config['sharedscripts'] =~ Boolean {
    $config_sharedscripts = {}
  }
  elsif ($rule_config['postrotate'] or $rule_config['prerotate']) and Array($path, true) =~ Array[Stdlib::Unixpath, 2] {
    $config_sharedscripts = { 'sharedscripts' => true }
  }
  else {
    $config_sharedscripts = {}
  }

  logrotate::rule { $title:
    *            => $rule_config - ['hourly', 'daily', 'weekly', 'monthly', 'yearly', 'notifempty'] -
    $noconfig_postrotate +
    $config_ifempty +
    $config_postrotate +
    $config_sharedscripts,
    path         => $path,
    rotate_every => $rotate_every,
  }
}
