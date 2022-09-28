class test_nagios () {
  # tmp should be removed from path once verified everything works
  $nagios_cfg_base_path = '/tmp/omd/sites/ops/etc/nagios/conf.d'

  $customer = 'a_cust'

  # lint:ignore:140chars
  $nagios_cfg_path = $customer ? {
    undef   => "${nagios_cfg_base_path}/${facts['networking']['hostname']}.cfg",
    default => "${nagios_cfg_base_path}/cust/${customer}/${facts['networking']['hostname']}.cfg",
  }
  # lint:endignore

  # need to split the path so that we can rebuild it piece by piece
  $nagios_cfg_path_elms = split($nagios_cfg_path, '/')

  # /tmp/omd/sites/ops/etc/nagios/conf.d/cust
  # export the full directory structure
  $nagios_cfg_path_elms.each |$index, $value| {
    unless $index <= 1 {
      $new_path = join($nagios_cfg_path_elms[0,$index], '/')
      @@file { "${trusted['certname']} - ${new_path}":
        path   => $new_path,
        ensure => directory,
        tag    => 'nagios_cfg_path',
      }
    }
  }

  # collect only on puppetserver
  #  if $facts['is_pe'] {
  #    File <<| tag == 'nagios_cfg_path' |>>
  #  }
}
