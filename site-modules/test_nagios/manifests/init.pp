class test_nagios (
  Hash   $services = {},
  String $host_use = 'standard-server'
) {
  # tmp should be removed from path once verified everything works
  $nagios_cfg_base_path = '/tmp/omd/sites/ops/etc/nagios/conf.d'

  # lint:ignore:140chars
  $nagios_cfg_path = $facts['org']['customer'] ? {
    undef   => "${nagios_cfg_base_path}/${facts['org']['env']}/${facts['org']['country']}/${facts['networking']['hostname']}.cfg",
    default => "${nagios_cfg_base_path}/cust/${facts['org']['customer']}/${facts['org']['country']}/${facts['networking']['hostname']}.cfg",
  }
  # lint:endignore

  # Every node should export its host entry for nagios
  @@nagios_host { $facts['networking']['hostname']:
    use        => $host_use,
    host_name  => $facts['networking']['hostname'],
    alias      => $facts['networking']['hostname'],
    address    => $facts['networking']['ip'],
    hostgroups => $facts['org']['env'],
    target     => $nagios_cfg_path,
  }

  # Dynamically build service definitions from hieradata
  #   for example:
  # test_nagios::services:
  #   'CPU Usage':
  #     check_command: 'check_nrpe_long!check_cpu_stats'
  #     servicegroups: 'engr, prod'
  $services.each |$service_name, $service_cfg| {
    @@nagios_service { "${facts['networking']['hostname']}-${service_name}":
      service_description => $service_name,
      target              => $nagios_cfg_path,
      *                   => $service_cfg,
    }
  }

  # Do stuff only on puppetserver as a nagios analog
  if $facts['is_pe'] {
    # Get permutations of $facts['org']['country'] from puppetdb
    $org_country_query = 'fact_contents[value] { path = ["org", "country"] group by value}'
    $_country = puppetdb_query($org_country_query)

    # Get permutations of $facts['org']['env'] from puppetdb
    $org_env_query = 'fact_contents[value] { path = ["org", "env"] group by value}'
    $_env = puppetdb_query($org_env_query)

    # Get permutations of $facts['org']['env'] from puppetdb
    $org_customer_query = 'fact_contents[value] { path = ["org", "customer"] group by value}'
    $_customer = puppetdb_query($org_customer_query)

    # Ensure that the base path exists
    $cfg_elms = split($nagios_cfg_base_path, '/')
    $cfg_elms.each |$index, $value| {
      unless $index < 1 {
        $n_p1 = join($cfg_elms[0, $index+1], '/')
        file { $n_p1:
          ensure => directory,
          tag    => 'nagios_cfg_path',
        }
      }
    }

    # Build possible paths when customer undef
    $_env.each |$env_elm| {
      $_country.each |$country_elm| {
        $env_country_path = "${env_elm['value']}/${country_elm['value']}"
        $e_c_elms = split($env_country_path, '/')
        $e_c_elms.each |$index, $value| {
          $n_p2 = join([$nagios_cfg_base_path, $e_c_elms[0, $index+1]], '/')
          unless defined(File[$n_p2]) {
            file { $n_p2:
              ensure => directory,
              tag    => 'nagios_cfg_path',
            }
          }
        }
      }
    }

    # Build possible paths when customer defined
    $_customer.each |$cust_elm| {
      $_country.each |$country_elm| {
        $cust_country_path = "cust/${cust_elm['value']}/${country_elm['value']}"
        $c_c_elms = split($cust_country_path, '/')
        $c_c_elms.each |$index, $value| {
          $n_p3 = join([$nagios_cfg_base_path, $c_c_elms[0, $index+1]], '/')
          unless defined(File[$n_p3]) {
            file { $n_p3:
              ensure => directory,
              tag    => 'nagios_cfg_path',
            }
          }
        }
      }
    }

    # ensure the directory path we create above happens before collecting the nagios_host resources
    File <| tag == 'nagios_cfg_path' |>
    -> Nagios_service <<| |>>
    -> Nagios_host <<| |>>
  }

}
