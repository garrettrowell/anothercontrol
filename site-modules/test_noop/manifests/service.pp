class test_noop::service () {

  service { 'pxp-agent':
    ensure => running,
  }

}
