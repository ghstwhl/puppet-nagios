# == Class: vo_nagios::server::install

class vo_nagios::server::install {

  # TODO:  Call this in the profile instead of here, maybe
  class{ 'apache':
    purge_configs =>  false,
    mpm_module    =>  'prefork',
  }

  class{ '::apache::mod::php': }
  class{ '::apache::mod::ssl': }
  ::apache::mod{ 'authn_core': }

  package{ 'nagios3':
    ensure  =>  installed,
    require =>  Class['apache'],
  }

  exec{'/usr/bin/dpkg-statoverride --update --add nagios www-data 2710 /var/lib/nagios3/rw':
    unless  => '/bin/ls -ld /var/lib/nagios3/rw|/bin/grep www-data > /dev/null',
    require => Package['nagios3'],
    notify  => Service['nagios3'],
  }

  exec{'/usr/bin/dpkg-statoverride --update --add nagios nagios 751 /var/lib/nagios3':
    unless => '/bin/ls -ld /var/lib/nagios3|/bin/grep drwxr-x--x > /dev/null',
    require => Package['nagios3'],
    notify  => Service['nagios3'],
  }

  file{'/var/lib/nagios3/':
    ensure  => directory,
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0751',
    require => Package['nagios3'],
  }

  file{'/var/lib/nagios3/rw':
    ensure  => directory,
    owner   => 'nagios',
    group   => 'www-data',
    mode    => '2710',
  }

  # NRPE is our remote monitoring solution
  package{ 'nagios-nrpe-plugin':  ensure  => installed }

  file{ '/etc/apache2/conf.d/nagios.conf':
    owner   =>  'www-data',
    group   =>  'www-data',
    mode    =>  '0644',
    source  =>  'puppet:///modules/vo_nagios/etc/apache2/conf.d/nagios.conf',
    require =>  Package['apache2'],
    notify  =>  Service['apache2'],
  }

  file{ '/etc/nagios3/objects':
    ensure  =>  directory,
    owner   =>  'nagios',
    group   =>  'nagios',
    mode    =>  '0755',
    require =>  Package['nagios3'],
  }
}
