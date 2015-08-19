# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'
Vagrant.require_version '>= 1.5.0'


def abspath(f)
  File.expand_path("../#{f}", __FILE__)
end


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = 'lol'

  # config.omnibus.chef_version = "12.3.0"
  if Vagrant.has_plugin?("vagrant-omnibus")
    config.omnibus.chef_version = 'latest'
  end

  config.vm.box = "trusty32"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    vb.customize ["modifyvm", :id, "--memory", 1024]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  # config.vm.network :private_network, type: 'dhcp'
  config.vm.network "forwarded_port", guest: 9001, host: 9001

  config.berkshelf.enabled = true
  config.vm.provision :chef_solo do |chef|
    json_file = if File.exist?(abspath("chef.json"))
                  abspath("chef.json")
                else
                  abspath("chef.json.example")
                end
    chef.json = JSON.parse(IO.read(json_file))
    chef.environments_path = 'environments'
    chef.environment = 'development'
    chef.run_list = [
      'recipe[apt]',
      'recipe[ruby_build]',
      'recipe[rbenv::vagrant]',
      'recipe[lol::default]'
    ]
  end
end
