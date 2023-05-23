# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @param path
#   Path to log file, for which logrotate rule will be created
#
# @param config
#   Set of configuration directives and according values to set into logrotate config
#
# @param merge_with_global
#   Whether to Merge with global logrotate configuration or not
#
# @example
#   lsys::logrotate::rule { 'namevar': }
define lsys::logrotate::rule (
  Variant[
    Stdlib::Unixpath,
    Array[Stdlib::Unixpath]
  ] $path,
  Optional[Lsys::Logrotate] $config = undef,
  Boolean $merge_with_global = true,
) {
  include lsys::params

  if $merge_with_global {
    $global_config = $lsys::params::logrotate_main_config
  }
  else {
    $global_config = {}
  }

  if $config {
    $rule_config = $global_config + $config
  }
  else {
    $rule_config = $global_config + $lsys::params::logrotate_default_config
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
  elsif $rule_config['rotate_every'] {
    $rotate_every = $rule_config['rotate_every']
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

  if $rule_config['su'] =~ String {
    $su_data = split($rule_config['su'], ' ')
    $config_su = {
      'su'       => true,
      'su_user'  => $su_data[0],
      'su_group' => $su_data[1],
    }
  }
  elsif $rule_config['su'] or ($rotate_every == 'hour' and $global_config['su']) {
    $config_su = {
      'su'       => true,
      'su_user'  => $global_config['su_user'],
      'su_group' => $global_config['su_group'],
    }
  }
  else {
    $config_su = {}
  }

  logrotate::rule { $title:
    *            => $rule_config - ['hourly', 'daily', 'weekly', 'monthly', 'yearly', 'rotate_every', 'notifempty', 'su'] -
    $noconfig_postrotate +
    $config_ifempty +
    $config_postrotate +
    $config_sharedscripts +
    $config_su,
    path         => $path,
    rotate_every => $rotate_every,
  }
}
