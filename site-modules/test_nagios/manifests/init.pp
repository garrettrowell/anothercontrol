class test_nagios () {
  # tmp should be removed from path once verified everything works
  $nagios_cfg_base_path = '/tmp/omd/sites/ops/etc/nagios/conf.d'

  # lint:ignore:140chars
  $nagios_cfg_path = $customer ? {
    undef   => "${nagios_cfg_base_path}/${facts['org']['env']}/${facts['org']['country']}/${facts['networking']['hostname']}.cfg",
    default => "${nagios_cfg_base_path}/cust/${facts['org']['customer']}/${facts['org']['country']}/${facts['networking']['hostname']}.cfg",
  }
  # lint:endignore

  # need to split the path so that we can rebuild it piece by piece
  $nagios_cfg_path_elms = split($nagios_cfg_path, '/')
  #
  #  # /tmp/omd/sites/ops/etc/nagios/conf.d/cust
  #  # export the full directory structure
  $nagios_cfg_path_elms.each |$index, $value| {
    unless $index <= 1 {
      $new_path = join($nagios_cfg_path_elms[0,$index], '/')
      echo { "new_path = ${new_path}": }
  #      @@file { "${trusted['certname']} - ${new_path}":
  #        path   => $new_path,
  #        ensure => directory,
  #        tag    => 'nagios_cfg_path',
  #      }
    }
  }

  # get every permutation of 'org' fact from puppetdb
  $org_query = 'facts[value] {name = "org"}'
  $_org = puppetdb_query($org_query)
  echo { $_org: }
  # collect only on puppetserver
  #  if $facts['is_pe'] {
  #    File <<| tag == 'nagios_cfg_path' |>>
  #  }
}
