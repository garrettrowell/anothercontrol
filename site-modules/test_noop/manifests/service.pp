class test_noop::service () {

  Service <| name == 'pxp-agent' |> {
    ensure => running,
  }
}
