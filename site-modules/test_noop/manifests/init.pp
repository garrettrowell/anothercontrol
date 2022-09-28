class test_noop () {

  File { noop    => false, }
  Service { noop => false, }
  include test_noop::file
  include test_noop::service
}
