# site.pp master config file

# set up a filebucket on the puppet master
case $::domain {
  /.*dev.*/: {
    filebucket { 'main':
      path => '/tmp/filebackup',
    }
  }
  default: {
    filebucket { 'main':
      path => false,                # This is required for remote filebuckets.
    }
  }
}

File { backup => main, }

# let's set some top-scope variables

# vo_env ( environment: dev, stg, or lab)
case $::domain {
  /^.*dev\..*\.victorops\.net$/:  { $vo_env = 'dev' }
  /^.*stg\..*\.victorops\.net$/:  { $vo_env = 'stg' }
  /^.*lab\..*\.victorops\.net$/:  { $vo_env = 'lab' }
  default:                        { fail('vo_env cannot be determined') }
}

# vo_location ( physical location, or 'vagrant' for vagrant environments )
case $::domain {
  /^.*vagrant\.victorops\.net$/:  { $vo_location = 'vagrant' } # Vagrant
  /^.*bdco01\.victorops\.net$/:   { $vo_location = 'bdco01' }  # Boulder, CO
  /^.*kcmo01\.victorops\.net$/:   { $vo_location = 'kcmo01' }  # Kansas City, MO
  /^.*spmn01\.victorops\.net$/:   { $vo_location = 'spmn01' }  # St. Paul, MN
  default:                        { fail('vo_location cannot be determined') }
}

# Server-type classification by hostname
$vo_st_nagios_server    = $::hostname =~ /^nagios[0-9].*$/
$vo_st_puppet_server    = $::hostname =~ /^puppet[0-9].*$/
$vo_st_database_server  = $::hostname =~ /^mysql[0-9].*$/
$vo_st_web_server       = $::hostname =~ /^web[0-9].*$/
$vo_st_haproxy_server   = $::fqdn     =~ /^haproxy.*/

# Most servers' class membership may be determined from the hostname
# See the vo_st variables above, and the common module for these name-based
# profiles

node default {
  include common
}

