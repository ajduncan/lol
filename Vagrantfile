# -*- mode: ruby -*-
# vi: set ft=ruby :

def abspath(f)
  File.expand_path("../#{f}", __FILE__)
end

Vagrant.configure("2") do |config|
  config.vm.box = "trusty32"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box"
  config.vm.provider :virtualbox do |vb|
    vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    vb.customize ["modifyvm", :id, "--memory", 1024]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end
  config.vm.network "forwarded_port", guest: 8000, host: 8000
  config.omnibus.chef_version = "12.3.0"
  config.berkshelf.enabled = true
  config.vm.provision :chef_solo do |chef|
    json_file = if File.exist?(abspath("chef.json"))
                  abspath("chef.json")
                else
                  abspath("chef.json.example")
                end
    chef.json = JSON.parse(IO.read(json_file))
    chef.run_list = [
      'recipe[apt]',
      'recipe[chef-lol::default]'
    ]
  end

end
