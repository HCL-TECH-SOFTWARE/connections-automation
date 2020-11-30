# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  #config.vm.box = "bento/centos-8.1"
  #config.vm.box_version = "202002.04.0"
  config.vm.box = "centos/7"
  config.vm.box_version = "2004.01"

  config.vm.provider :virtualbox do |v|
    v.memory = 4096
    v.cpus = 2
  end

  boxes = [
    { :name => "cdemo3cp", :ip => "10.172.13.3" },
  ]

  # Provision each of the VMs.
  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.hostname = opts[:name]
      config.vm.network :private_network, ip: opts[:ip]

      # Provision all the VMs in parallel using Ansible after last VM is up.
      if opts[:name] == "cdemo3cp"
        config.vm.provision "ansible" do |ansible|
          ansible.compatibility_mode = "2.0"
          #ansible.playbook = "playbooks/third_party/kubernetes/upgrade-single-node.yml"
          ansible.playbook = "playbooks/vagrant-all-in-one.yml"
          ansible.limit = "all"
          ansible.become = true
          ansible.groups = {
            "k8s_masters" => ["cdemo3cp"],
            "k8s_workers" => ["cdemo3cp"],
            "docker_registry" => ["cdemo3cp"],
            "k8s_load_balancers" => ["cdemo3cp"],
            "nfs_servers" => ["cdemo3cp"],
            "component_pack_master" => ["cdemo3cp"],
            "k8s_masters:vars" => {
              kubernetes_version: "1.18.1",
              upgrade_version: "1.18.0",
              single_node_installation: true,
              docker_version: "19.03.8",
              calico_install_latest: "True"
            },
            "component_pack_master:vars" => {
              component_pack_download_location: "cntr-builder1.cnx.cwp.pnp-hcl.com:8000/cp",
              component_pack_package_name: "hybridcloud_20200321-175618.zip",
              ic_internal: "cdemo2.cnx.cwp.pnp-hcl.com",
              skip_pod_checks: true
            },
            "docker_registry:vars" => {
              setup_docker_registry: true,
              docker_registry_url: "localhost:5000"
            }
          }
        end
      end
    end
  end

end
