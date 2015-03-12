# == Class: vo_puppetmaster
#
# Manages resources not covered by the "foreman" and "puppet" classes.
#
# === Parameters
#
# No Parameters
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# No Global Variables
#
# === Authors
#
# Michael Merideth <mike@victorops.com>
#
# === Copyright
#
# Copyright 2014 VictorOps, unless otherwise noted.
#
class profile::vo_puppetmaster {

  # By default the environment will not get cached
  Puppet::Server::Env{
    environment_timeout => 0,
  }

  class { 'puppet':
    server                      => true,
    server_passenger            => true,
    server_envs_dir             => '/etc/puppet/environments',
    server_storeconfigs_backend => 'puppetdb',
    server_git_repo_path				=> false,
    runinterval                 => '600',
    splaylimit                  => '600',
  } ->


  file{ '/etc/puppet/autosign.conf':
    owner		=> 'puppet',
    group		=> 'puppet',
    mode		=> '0664',
    source	=> 'puppet:///modules/profile/etc/puppet/autosign.conf',
  } ->

  file{ '/etc/puppet/puppetdb.conf':
    owner		=> 'root',
    group		=> 'root',
    mode		=> '0644',
    source	=> 'puppet:///modules/profile/etc/puppet/puppetdb.conf',
  } ->

  package{ 'puppetdb-terminus':
    ensure  => installed,
  } ->

  package{ 'puppetdb':
    ensure  => installed,
  } ->

  file{ '/etc/puppetdb/conf.d/jetty.ini':
    owner		=> 'root',
    group		=> 'root',
    mode		=> '0644',
    source  => 'puppet:///modules/profile/etc/puppetdb/conf.d/jetty.ini',
    require	=> Package['puppetdb'],
    notify	=> Exec['puppetdb-ssl-setup'],
  } ->

  exec{ 'puppetdb-ssl-setup':
    command			=>	'/usr/lib/puppetdb/puppetdb-ssl-setup -f',
    creates			=>	'/etc/puppetdb/ssl/private.pem',
    require			=>	Package['puppetdb'],
    notify			=>	Service['puppetdb'],
  } ->

  service{ 'puppetdb' :
    ensure	=> running,
    enable	=> true,
  } ->

  class { 'foreman':
    authentication  => true,
    admin_username  => 'admin',
    admin_password  => 'admin',
  }

  package { 'sqlite3':
    ensure  => installed,
  }

  file{'/usr/local/bin/vagrant_update_puppet.sh':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/profile/usr/local/bin/vagrant_update_puppet.sh',
  }

}
