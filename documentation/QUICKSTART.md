# Quick start for setting up HCL Connections and Component Pack using Ansible automation

This is just an example of setting up your first HCL Connections and Component Pack environment including Customizer configured.

To set this up, you will need at least four machines (for this example, let us say we use CentOS 7):

- ansible.internal.example.com is going to run Ansible commands (i.e. Ansible controller).  Typical laptop grade environment should be suffice.
- web.internal.example.com is going to host, in this example, only Nginx and Haproxy. This is needed here only for the Customizer. At least 1CPU and 2G of RAM are preferable.
- connections.internal.example.com is going to host IBM WebSphere, IHS and HCL Connections. We will put here also OpenLDAP with 10 users, and IBM DB2. NFS will be set for shared data and message stores. HCL Connections will be deployed as a small topology (single JVM). Here you need at least two CPUs and at least 16G of RAM for having everything self contained.
- cp.internal.example.com is going to host Kubernetes 1.18.18, be NFS server for persistent volumes, Docker Registry, and Component Pack on top of it. You need at least 32G of RAM to install full offering and at least 8 CPUs.

Once the installation is done, we will access our HCL Connections login page through https://connections.example.com/

Example inventory files for this Quick Start can be found in environments/examples/cnx7/quick_start folder.

# Setting up your environment

For this example, we will use only four machines described above for all the work. One of them is going to be Ansible controller, another one is going to serve the files like described in README.md.

## Before you start

* Ensure that all three machines have DNS set in a consistant way:

```
[web.internal.example.com]$ hostname
web.internal.example.com
[web.internal.example.com]$ hostname -f
web.internal.example.com
[web.internal.example.com]$ hostname -s
web
```

```
[connections.internal.example.com]$ hostname
connections.internal.example.com
[connections.internal.example.com]$ hostname -f
connections.internal.example.com
[connections.internal.example.com]$ hostname -s
connections
```

```
[cp.internal.example.com]$ hostname
cp.internal.example.com
[cp.internal.example.com]$ hostname -f
cp.internal.example.com
[cp.internal.example.com]$ hostname -s
cp
```

* Update all three machines using yum update or dnf before you proceed.  This is important otherwise deployment will fail due to missing packages.
* Update your /etc/hosts on each of those machines with proper ip/short/long name
* On all three machines, ensure that the content of /etc/environment file is like follows:

```
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
```

* Reboot all three machines

## Setting up the user

Let's say we will use user called ansible to execute Ansible commands. For this example, we will use ansible.internal.example.com for running Ansible commands.

As a very first step, create user called ansible on all four machines, and ensure it is in sudoers file the way that it can sudo without being asked for the password.

Once this is done, on ansible.internal.example.com (which is going to be our Ansible controller) switch to user ansible (sudo su - ansible) and create your key pair with:

```
[ansible@ansible ~]$ ssh-keygen -t rsa
```

Just press Enter for each question (leave everything as default).

Go to your ansible/.ssh folder, and create file called config with following content:

```
[ansible@ansible ~]$ cat ~/.ssh/config
Host *
    User ansible
    ForwardAgent yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    IgnoreUnknown AddKeysToAgent,UseKeychain
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_rsa
```

Allow ansible user to SSH to other three machines without being asked for the password by coping the content of id_rsa.pub to authorized_keys on other hosts:

```
[ansible@web ~]$ cat ~/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvupayZq/4h+vrzisZAa4Yx/JqbgRFPu5WSAO5YIkws/3fdXGcFFFx2DXdIcvFT+70SSE0Cwh5520K1ypK6/M2WXhJhu7gz/7eldWFOuFvT9XF4zRq90A5DemwYJALclHz3Kecq5/uE7hrSg7ojYRGow3qPO4F5kfiFSH/mRoxRj2990tbHOfNV3R45A6qoPk/POFU61DFFt/o42jm5IsKg40mFCRUIOez477b51CgIhEnMeL6tIPjdM7jYblnpf+gMeg8Ulz4OGdBhqQhJJfeRyYMRghxkb9/2uXIlhlCxHZH+HnIru67X4CAVpHAuO3pFX/9L9NEUooaLh723$1 ansible@web.internal.example.com

[ansible@connections ~]$ cat ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvupayZq/4h+vrzisZAa4Yx/JqbgRFPu5WSAO5YIkws/3fdXGcFFFx2DXdIcvFT+70SSE0Cwh5520K1ypK6/M2WXhJhu7gz/7eldWFOuFvT9XF4zRq90A5DemwYJALclHz3Kecq5/uE7hrSg7ojYRGow3qPO4F5kfiFSH/mRoxRj2990tbHOfNV3R45A6qoPk/POFU61DFFt/o42jm5IsKg40mFCRUIOez477b51CgIhEnMeL6tIPjdM7jYblnpf+gMeg8Ulz4OGdBhqQhJJfeRyYMRghxkb9/2uXIlhlCxHZH+HnIru67X4CAVpHAuO3pFX/9L9NEUooaLh723$1 ansible@web.internal.example.com

[ansible@cp ~]$ cat ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvupayZq/4h+vrzisZAa4Yx/JqbgRFPu5WSAO5YIkws/3fdXGcFFFx2DXdIcvFT+70SSE0Cwh5520K1ypK6/M2WXhJhu7gz/7eldWFOuFvT9XF4zRq90A5DemwYJALclHz3Kecq5/uE7hrSg7ojYRGow3qPO4F5kfiFSH/mRoxRj2990tbHOfNV3R45A6qoPk/POFU61DFFt/o42jm5IsKg40mFCRUIOez477b51CgIhEnMeL6tIPjdM7jYblnpf+gMeg8Ulz4OGdBhqQhJJfeRyYMRghxkb9/2uXIlhlCxHZH+HnIru67X4CAVpHAuO3pFX/9L9NEUooaLh723$1 ansible@web.internal.example.com
```

From ansible.internal.example.com you should be able now, as ansible user, to SSH to web.internal.example.com, connections.internal.example.com and cp.internal.example.com without being prompted for the password.

As the last step, customize .bashrc for your ansible user like this:


```
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

export ANSIBLE_HOST_KEY_CHECKING=False

eval "$(ssh-agent)"
```

Environment variable that you are setting here will save you the time with typing yes every time Ansible hits new hosts. The last command will ensure that you use only key and the keychain from ansible user itself.

### ...but if you use root user

Please note that you need to either disable password login for root user in your SSH configuration, or run Ansible playbooks with using usernames/passwords, because the scripts will otherwise block when they try to go from machine to machine. Due to both security and practical reasons, we don't recommend to use root user directly for this.

## Installing Ansible

Ansible needs to be installed only on the controller machine, in our example it is ansible.internal.example.com

```
[ansible@web ~]$ sudo yum install ansible
```

We are supporting Ansible 2.9. Once you are done with installation, check the version (note that minor version can deffer depending at when you performed the installation):

```
[ansible@web ~]$ ansible --version
ansible 2.9.15
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/home/lcuser/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /bin/ansible
  python version = 2.7.5 (default, Oct 14 2020, 14:45:30) [GCC 4.8.5 20150623 (Red Hat 4.8.5-44)]
```

Once this is done, you are ready to roll!

# Setting up full HCL Connections stack

Don't forget to install git, and to clone git@github.com:HCL-TECH-SOFTWARE/connections-automation.git to be able to proceed.

## Setting up file share

As explained in README.md, you need first to download all needed packages to be able to install them (as you would have to even if you are doing it manually).

For this example, we will download all the packages to /tmp folder on connections.internal.example.com and serve them from there. In general, keeping anything in /tmp is not a good idea, but since we are setting up playground, it doesn't really matter here. You can do it of course in any other folder that you chose, just ensure that you have enough disk space for downloading everything.

Once you downloaded all needed packages in your /tmp folder on connections.internal.example.com, the easiest way to start a very simple server just for this example is to use Ruby:

* Use yum to install ruby on connections.internal.example.com
* Enter /tmp folder in connections.internal.example.com
* Run next command as root user while being inside /tmp folder:
```
ruby -run -e httpd . -p 8001 &
```

And you are good to go - you've just started web server on port 8001 inside your /tmp folder and you are serving everything that is there. You can check if it works if you simply point your browser to http://connections.internal.example.com:8001 and you see all your downloaded files there.

## Setting up your inventory files

There are two things you need to adapt before you try the installation:

- Change FQDNs in inventory.ini to match your own FQDNs.
- Edit group_vars/all.yml and change in mandatory section the FQDN towards your Haproxy (cnx_component_pack_ingress) and the URL which will be used as an entry point to your HCL Connections environment (dynamicHost on CNX side - cnx_application_ingress).

## Setting up HCL Connections with all the dependencies

To set up HCL Connections with DB2, OpenLDAP, TDI, IBM WebSphere, IBM IHS and HCL Connections, run:

```
ansible-playbook -i environments/examples/cnx7/quick_start/inventory.ini playbooks/setup-connections-complete.yml
```

## Setting up Component Pack for HCL Connections with all the dependencies

To set up Component Pack with Kubernetes, Docker, Docker Registry, NFS, Nginx and Haproxy all configured to support Customizer as well, run:

```
ansible-playbook -i environments/examples/cnx7/quick_start/inventory.ini playbooks/setup-component-pack-complete.yml
```

## Setting up Connections Docs 2.0.1

To set up Connections Docs 2.0.1, just run:

```
ansible-playbook -i environments/examples/cnx7/quick_start/inventory.ini playbooks/hcl/setup-connections-docs.yml
```

Note: if you are using old format of inventory files, it is all backwards compatible. The only thing that you need to add there is cnx_was_servers to your connections inventory (to make it same as done for docs already).

# Validating your installation

* Check out https://connections.example.com/ - if all went well, you should see HCL Connections login screen, and should be able to log in there as fakeuser1 to fakeuser9 using password 'password'
* SSH to cp.internal.example.com, become user ansible, and start playing with Kubernetes using Helm and kubectl already configured for user ansible.

# Frequently Given Answers

* Please check the troubleshooting section if you have any issues.
* Yes, you have to have DNS (proper DNS) set up. It will not work, and it can not work, with using only local hosts files due to various reasons which are not the topic of this automation.
* We don't plan to automate any type of DNS setup.
* Postfix (or any other mail server) is intentionally not installed.
* Feel free to customize it to the best of your knowledge, it's under Apache licence after all and that was the intention.
