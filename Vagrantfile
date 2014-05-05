Vagrant.configure('2') do |config|
  config.vm.box      = 'precise32'
  config.vm.box_url  = 'http://files.vagrantup.com/precise32.box'
  config.vm.hostname = 'taxi-sim-box'

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = './'
    puppet.manifest_file = 'vagrant_manifest.pp'
  end
end
