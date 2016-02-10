Vagrant.configure(2) do |config|
  config.vm.define "node1" do |node1|
    node1.vm.box = "geerlingguy/centos7"
    node1.vm.network "private_network", ip: "192.168.0.2"
    node1.vm.hostname = "node1.example.com"
    node1.vm.provider "virtualbox" do |v|
      v.memory = 4096
      v.cpus = 2
    end
  end
  config.vm.define "node2" do |node2|
    node2.vm.box = "geerlingguy/centos7"
    node2.vm.network "private_network", ip: "192.168.0.3"
    node2.vm.hostname = "node2.example.com"
    node2.vm.provider "virtualbox" do |v|
      v.memory = 4096
      v.cpus = 2
    end
  end
  config.vm.define "node3" do |node3|
    node3.vm.box = "geerlingguy/centos7"
    node3.vm.network "private_network", ip: "192.168.0.4"
    node3.vm.hostname = "node3.example.com"
    node3.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end
  end
end
