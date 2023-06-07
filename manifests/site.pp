## site.pp ##

# This file (./manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
# https://puppet.com/docs/puppet/latest/dirs_manifest.html
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition if you want to use it.

## Active Configurations ##
# Disable filebucket by default for all File resources:
# https://github.com/puppetlabs/docs-archive/blob/master/pe/2015.3/release_notes.markdown#filebucket-resource-no-longer-created-by-default
File { backup => false }

## Node Definitions ##

# The default node definition matches any node lacking a more specific node
# definition. If there are no other node definitions in this file, classes
# and resources declared in the default node definition will be included in
# every node's catalog.
#
# Note that node definitions in this file are merged with node data from the
# Puppet Enterprise console and External Node Classifiers (ENC's).
#
# For more on node definitions, see: https://puppet.com/docs/puppet/latest/lang_node_definitions.html
node default {
  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }

  # override comply module to use puppet's vendored curl
  #Archive <| tag == 'comply' |> {
  #  provider => 'puppet_curl',
  #}

  #include test_noop
  #include test_nagios

  #  Resources <| tag == 'test_noop' |> {
  #    noop => false,
  #  }

}

node 'pe-primary.garrett.rowell' {
  ini_setting { 'policy-based autosigning':
    setting => 'autosign',
    path    => "${::settings::confdir}/puppet.conf",
    section => 'master',
    value   => '/opt/puppetlabs/puppet/bin/autosign-validator',
    notify  => Service['pe-puppetserver'],
  }

  class { ::autosign:
    ensure => 'latest',
    config => {
      'general' => {
        'loglevel' => 'INFO',
      },
      'jwt_token' => {
        'secret'   => 'hunter2',
        'validity' => '7200',
      }
    },
  }

  #catalog diff
  puppet_authorization::rule { 'catalog-diff certless catalog':
    match_request_path   => '^/puppet/v3/catalog',
    match_request_type   => 'regex',
    match_request_method => 'post',
    allow                => 'catalog-diff',
    sort_order           => 500,
    path                 => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    notify               => Service['pe-puppetserver'],
  }

  puppet_authorization::rule { 'garrett jank certless catalog':
    match_request_path   => '^/puppet/v3/catalog',
    match_request_type   => 'regex',
    match_request_method => 'post',
    allow                => '*',
    sort_order           => 500,
    path                 => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    notify               => Service['pe-puppetserver'],
  }

}
