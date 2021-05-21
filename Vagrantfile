#
# welcome to k8s.institute sponsered by http://www.ninit.tech# https://k8s.institute https://www.k8s.institute
Vagrant.configure("2") do |config|

  config.vm.define "k8sinstitute" do |k8sinstitute|
    k8sinstitute.vm.box = "bento/ubuntu-18.04"
    k8sinstitute.vm.hostname = "k8s.institute"
    k8sinstitute.vm.define "k8s.institute"
    k8sinstitute.vm.network "private_network", ip: "10.10.10.76"
    k8sinstitute.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus   = 2
    end
    k8sinstitute.vm.provision "shell", path: "./k8s_institute_ubuntu_script.sh"
    end
end

