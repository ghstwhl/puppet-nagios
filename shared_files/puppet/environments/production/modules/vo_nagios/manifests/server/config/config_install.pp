# == Class: vo_nagios::server::config::config_install

class vo_nagios::server::config::config_install {

  include vo_nagios::params

  $dyn_configfiles = $::vo_nagios::params::nag_dyn_configfiles

  define installNagConfig () {

    $cfg_tmpdir = hiera('nagios_config_tmpdir')
    $cfg_rundir = hiera('nagios_config_rundir')

    exec{ "touch ${title}":
      command => "/usr/bin/touch ${cfg_tmpdir}/${title}",
    } ->

    exec{ "chown ${title}":
      command => "/bin/chown nagios:nagios ${cfg_tmpdir}/${title}",
    } ->

    exec{ "copy ${title}":
      command => "/bin/cp -fp ${cfg_tmpdir}/${title} ${cfg_rundir}/${title}",
      unless  => "/usr/bin/diff -I '^# HEAD.*' ${cfg_tmpdir}/${title} ${cfg_rundir}/${title} > /dev/null",
      notify  => Service['nagios3'],
    }
  }

  installNagConfig{ $dyn_configfiles: }

}
