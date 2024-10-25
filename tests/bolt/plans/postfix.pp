plan lsys_tests::postfix (
  TargetSpec $targets = 'puppetservers',
) {
  run_task(bsys::install_yum, $targets)
  run_task(puppet_agent::install, $targets, stop_service => true)

  run_plan(facts, $targets)
  return apply($targets) {
    class { 'lsys::postfix::client':
      relayhost          => 'mail.domain.tld',
      postdrop_nosgid    => true,
      maillog_file       => '/var/log/maillog',
      master_os_template => 'lsys/postfix/master.cf.rocky.erb',
    }
  }
}
