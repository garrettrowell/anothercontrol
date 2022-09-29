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

  # Do stuff only on puppetserver as a nagios analog
  if $facts['is_pe'] {
    # Get permutations of $facts['org']['country'] from puppetdb
    $org_country_query = 'fact_contents[value] { path = ["org", "country"] group by value}'
    $_country = puppetdb_query($org_country_query)
    echo { "${_country}": }

    # Get permutations of $facts['org']['env'] from puppetdb
    $org_env_query = 'fact_contents[value] { path = ["org", "env"] group by value}'
    $_env = puppetdb_query($org_env_query)
    echo { "${_env}": }

    # Get permutations of $facts['org']['env'] from puppetdb
    $org_customer_query = 'fact_contents[value] { path = ["org", "cust"] group by value}'
    $_customer = puppetdb_query($org_customer_query)
    echo { "${_customer}": }

    # Build possible paths when customer undef
    $_env.each |$env_elm| {
      $_country.each |$country_elm| {
        echo { "${nagios_cfg_base_path}/${env_elm['value']}/${country_elm['value']}": }
      }
    }

    # Build possible paths when customer defined
    $_customer.each |$cust_elm| {
      $_country.each |$country_elm| {
        echo { "${nagios_cfg_base_path}/${cust_elm['value']}/${country_elm['value']}": }
      }
    }

    # Only concerned with the base path for now
    $cfg_elms = split($nagios_cfg_base_path, '/')
    $cfg_elms.each |$index, $value| {
      unless $index <= 1 {
        $n_p = join($cfg_elms[0,$index], '/')
        echo { "n_p = ${n_p}": }
      }
    }
  }

  # collect only on puppetserver
  #  if $facts['is_pe'] {
  #    File <<| tag == 'nagios_cfg_path' |>>
  #  }
}
