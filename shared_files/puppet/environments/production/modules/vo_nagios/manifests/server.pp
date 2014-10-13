# == Class: vo_nagios::server
class vo_nagios::server {

  include vo_nagios
  include vo_nagios::server::install
  include vo_nagios::server::config

  service{ 'nagios3':
    ensure  =>  running,
    enable  =>  true,
    require =>  Package['nagios3'],
  }

}
