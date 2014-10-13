# -*- mode: ruby -*-
# vi: set ft=ruby :

$hostname_script = <<-'SCRIPT'
echo "Populate /etc/hosts and hostname files"

groupadd -f wheel
groupmod -g 2000 vagrant
groupmod -g 2002 vboxsf

echo "Shell Provisioning Work Around"
echo "%s" > /etc/hostname
#sed -i "s/127.0.1.1.*/127.0.0.1 %s/g" /etc/hosts
cat /vagrant/hosts >> /etc/hosts
hostname "%s"
SCRIPT

$apt_update = <<-'SCRIPT'
/usr/bin/apt-get update
SCRIPT

$prep_puppetmaster = <<-'SCRIPT'
echo "Put production environment into /etc/puppet"

if [[ ! -d /etc/puppet ]] ; then
  mkdir /etc/puppet
fi

cp -rp /vagrant/puppet/* /etc/puppet/
SCRIPT

$cleanup_apply_report = <<-'SCRIPT'
echo "Fix ownership on puppet apply report output"
chown -R puppet:puppet /var/lib/puppet
SCRIPT

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  add_server("10.2.0.2", "puppet1.dev.vagrant.victorops.net", config, "8082", "8442")
  add_server("10.2.0.3", "nagios1.dev.vagrant.victorops.net", config, "8083", "8443")
  add_server("10.2.0.4", "web1.dev.vagrant.victorops.net", config, "8084", "8444")
  add_server("10.2.0.5", "web2.dev.vagrant.victorops.net", config, "8085", "8445")
  add_server("10.2.0.6", "mysql1.dev.vagrant.victorops.net", config, "8086", "8446")
  add_server("10.2.0.7", "mysql2.dev.vagrant.victorops.net", config, "8087", "8447")
  add_server("10.2.0.8", "haproxy.dev.vagrant.victorops.net", config, "8088", "8448")

end

def add_server(ip, hostname, config, httpport, httpsport = [])

  config.vm.define hostname[/\w+\./].gsub('.','').to_sym do |p|
    p.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"
    p.vm.hostname = hostname
    # type = 'static' to fix https://github.com/mitchellh/vagrant/issues/3387 plz to remove when fix
    # is confirmed
    p.vm.network "private_network", ip: ip, type: 'static'

    p.vm.provider :virtualbox do |vb|
      # to enable a console session uncomment this e.g. if you lock yourself out
      # vb.gui = true
      if hostname =~ /^puppet.*|^mysql.*/
        vb.customize ["modifyvm", :id, "--memory", 2048]
      else
        vb.customize ["modifyvm", :id, "--memory", 1024]
      end
      if hostname =~ /^puppet.*/
        # vb.gui = true
        vb.customize ["modifyvm", :id, "--cpus", 2]
      end
    end

    # Share an additional folder to the guest VM. The first argument is
    # the path on the host to the actual folder. The second argument is
    # the path on the guest to mount the folder. And the optional third
    # argument is a set of non-required options.
    # config.vm.synced_folder "../data", "/vagrant_data"
    p.vm.synced_folder "./shared_files", "/vagrant"

    p.vm.network "forwarded_port", guest: 80, host: httpport, protocol: 'tcp'
    p.vm.network "forwarded_port", guest: 443, host: httpsport, protocol: 'tcp'
    
    if hostname =~ /^haproxy.*/
      p.vm.network "forwarded_port", guest: 9000, host: 9000, protocol: 'tcp' 
    end



    p.vm.provision :shell, :inline => $hostname_script % [hostname, hostname, hostname]
    p.vm.provision :shell, :inline => $apt_update
    # p.vm.provision :shell, :inline => $puppet_upgrade_script

    # Puppetmaster goes first, provisioned with puppet-apply
    # Other hosts provision from the puppetmaster
    if hostname =~ /^puppet.*/
      p.vm.provision :shell, :inline => $prep_puppetmaster
      p.vm.provision :puppet do |puppet|
        puppet.manifests_path = "shared_files/puppet/environments/production/manifests"
        puppet.module_path    = "shared_files/puppet/environments/production/modules"
        puppet.manifest_file  = "site.pp"
        puppet.facter = {
          "vagrant_apply_bootstrap" => "1"
        }
        # puppet.options = '--debug --verbose'
        # puppet.options = '--verbose --debug --trace'
      end
      p.vm.provision :shell, :inline => $cleanup_apply_report
    else
      # p.vm.provision
      p.vm.provision "puppet_server" do |puppet|
        puppet.puppet_server = "puppet1.dev.vagrant.victorops.net"
	#puppet.options = '--debug --verbose'
	puppet.facter = {
          "vagrant_agent_bootstrap" => "1"
        }
      end
    end
  end
end
