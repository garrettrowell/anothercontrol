class test_noop () {

  class { 'test_noop::file':
    noop => false,
  }

  include test_noop::service
}
