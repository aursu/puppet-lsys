plan lsys_tests::logrotate (
  TargetSpec $targets = 'puppetservers',
) {
  run_task(bsys::install_yum, $targets)
  run_task(puppet_agent::install, $targets, stop_service => true)

  run_plan(facts, $targets)
  return apply($targets) {
    class { 'lsys::logrotate': }
  }
}
