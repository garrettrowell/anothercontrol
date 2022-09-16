# frozen_string_literal: true

Puppet::Type.type(:archive).provide(:puppet_curl, parent: :curl) do
  commands curl: '/opt/puppetlabs/puppet/bin/curl'
end
