class test_noop () {

  Resources {
    noop => false,
  }

  include test_noop::file
  include test_noop::service
}
