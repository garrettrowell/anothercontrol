class test_noop::file () {
  file { '/tmp/imatest':
    ensure => present,
    noop   => false,
  }
}
