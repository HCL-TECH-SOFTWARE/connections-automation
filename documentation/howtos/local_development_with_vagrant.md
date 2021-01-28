# Using Vagrant for local development and testing

In case you are doing some local development and testing, or want simply to see all this automation working on your own local virtual machine, we already prepared some examples using Vagrant. It is important to say that Vagrant is also used extensively locally to test specially different flavours and versions of operating systems.

## Installing and setting up Vagrant

Please check out [official HashiCorp Vagrant page](https://www.vagrantup.com/) to install Vagrant on your local machine. 

## Installing and setting up VirtualBox

Vagrant is, by default, using [VirtualBox](https://www.virtualbox.org/wiki/Downloads).

## Prepare packages locally

Download the packages locally in some folder, and [set it up as explained here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/QUICKSTART.md#setting-up-file-share). Your VM will, in the end, try to connect locally to some port running there to download those packages into it.

Why not to use fileshare? Simply because it takes way more disk space, CPU power, and time needed to mount it initially into the VM and then use it from there. 

## So how does this all work together?

It's quite simple: 

* You will have the packages downloaded locally, the same way you would have to have it if you are manually creating VM and installing them inside. 
* I files called Vagrantfile.connections and Vagrantfile.componentpack you have all the information that Vagrant needs to create a VM for you and set it up. Yes, using this same Ansible automation.
* Add to your own /etc/hosts the local IP and the name that Vagrant is expecting to have. Check setup_componentpack_vm.sh and setup_connections_vm.sh for more details. Yes, you can use this on Windows as well, just customize the Vagrantfile in whatever way you want to. 

```
##
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1	localhost
255.255.255.255	broadcasthost
::1             localhost
# Hosts below will be used by Vagrant
10.172.13.3     connections.internal connections
10.172.13.5     componentpack.internal componentpack
```
* And in the end, run one of those setup scripts. Why setup scripts? Because by default, Vagrant expects the file called Vagrantfile to exists, but it can be overridden by setting up VAGRANT_VAGRANTFILE environment variable and pointing it to whatever file name you want. Otherwise, by default, Vagrantfile is the expected filename for the Vagrant. 

## What next?

Vagrant is highly customizable, and options here are endless. Browse the internet, official documentation, and customize it all to your own needs.
