class test_noop () {

  File { noop    => false, }
  Service { noop => false, }
  contain test_noop::file
  contain test_noop::service
  @@host { $facts['hostname']:
    ensure => present,
    ip     => $facts['ipaddress'],
  }
}
