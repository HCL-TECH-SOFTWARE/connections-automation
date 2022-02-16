# Upgrading HCL Connections using Ansible automation

This automation is used by HCL from HCL Connections 6.5 to test HCL Connections and Component Pack upgrades.

For this example, we will show:

* How to install HCL Connections 6.5CR1
* How to use the same automation to upgrade HCL Connections 6.5CR1 (6.5 CR1) to HCL Connection 7 and
* What is the logic behind it.

NOTE: If this is the very first document you are landing on, please ensure that you read already our [README.md](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/README.md) and our [Quick Start Guide](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/QUICKSTART.md), specially if you never used Ansible and/or this automation before.

## Installing HCL Connections 6.5CR1

The easiest and most straight forward way to set up any end-to-end HCL Connections installation is to simply:

* Set up your inventory file the way you want (we will use [this example file for setting up 6.5.0.1](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/inventory.ini))
* Use CentOS 7 (the later CentOS 7 the better)

...and simply run your playbook with

```
ansible-playbook -i environments/examples/cnx6/connections playbooks/setup-connections-complete.yml
```

### Running this playbook, as you can see [here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/playbooks/setup-connections-complete.yml) will simply set up IBM DB2, NFS, Connections Wizards, OpenLDAP, setup and run IBM SDI, setup IBM WebSphere ND with all the dependencies, and install HCL Connections on top of that.

Before you proceed, let's analyse very quickly what is important for which step.

### Setting up your inventory file

To set up 6.5CR1, let's assume that we want to also install IBM WebSphere ND 8.5.5 with FixPack 16 (for HCL Connections 7 recommended version is FixPack 18).

Please note that [this example file](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/inventory.ini) is already set to overwrite defaults, which means it will install non default packages and we will explain here what it is doing differently:

* We have our HCL Connections and HCL Connections Wizards installer living in a folder called Connections6.5, so we are setting the right paths [here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L44)
* We want, specifically, to install IBM WebSphere ND 8.5.5.16 instead of 8.5.5.18 which is default, and we [specify the location here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L40-L42)
* IBM WebSphere ND 8.5.5.16 package names are different from those for 8.5.5.18 and we [specify right packages here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L54-L70)
* We need to specify that we are not installing default version 7, and we do it [here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L74)
* Also, the [package name](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L72) is different for HCL Connections 6.5CR1. Your package name could be different, but this is where you set up which one you want Ansible to install.
* We are preparing the database for 6.5(.0.1), not for 7, and we tell it to Ansible [here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L78)

### Choosing operating system version

For this scenario, let's say you are using CentOS 7.9 (latest in this moment). Be always sure, as whenever installing any of the components mentioned here, using automation or manually, to configure machine properly and just to be on the safe side run yum update before you start.

### Installing end-to-end HCL Connections 6.5CR1

And it is the time to run:

```
ansible-playbook -i environments/examples/cnx6/db2/inventory.ini playbooks/setup-connections-complete.yml
```

So to sum it up - what is actually going to happen when you run the playbook?

* DB2 will be set up exactly the same way as it would be for Connections 7
* Connections Wizards would set up the databases needed for HCL Connections 6.5CR1
* OpenLDAP would be installed, IBM TDI after that, and NFS set up by default, since HCL Connections is requiring it by default (if you don't want to use NFS, just uncomment [this variable](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/inventory.ini#L79))
* IBM WebSphere ND 8.5.5.16 would be installed using proper FixPack 16 packages (in background, base version would be always installed and then upgraded to FixPack 16)
* HCL Connections 6.5CR1 would be installed. Specifying proper version above would tell it to use proper response file (the only delta between response file between version 6.* and 7 is one extra app, IC360)

## Upgrading IBM WebSphere ND with FixPack 18

Once your installation works, and everything is up and running, let's say you want just to upgrade IBM WebSphere ND, and nothing else.

To upgrade WebSphere ND normally, you need to stop all the java services, otherwise the installer will fail. After that, you would upgrade IBM Installation Manager (if needed), and all the packages provided by IBM WebSphere ND.

So again we will make it two parts work - tweak your inventory file, and do the upgrade (stop everything, upgrade, restart).

### Tweak inventory file to upgrade WebSphere ND to 8.5.5.18

Again, we will reference [this inventory file](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/inventory.ini)

* Comment out [those lines](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L40, https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L42) since we do not want FP18 anymore
* Uncomment [those lines](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/84fad83cb7cc95918330720f32362c527419dfb4/environments/examples/cnx6/connections#L58-L59) to switch to the proper folder. If you have all the packages living in the same folder, then there is obviously nothing to be done in this and previous step, since package names are always different.
* FP18 package names are different, so simply remove [those lines](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L55-L70) (yes, just remove them) to fail over to default names. In case you are using files with a different name(s), then you need to [use this section](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L55-L70) as a reference on how to overwrite the defaults. Note that current defaults are FixPack 18 names.

And that's it. You are ready to roll.

### Upgrading IBM WebSphere ND to FixPack 18

Stop all WAS ND services with:

```
ansible-playbook -i environments/examples/cnx6/db2/inventory.ini playbooks/third_party/was-nd-stop.yml
```

Run full stack WebSphere ND upgrade:

```
ansible-playbook -i environments/examples/cnx6/db2/inventory.ini playbooks/third_party/setup-webspherend.yml
```

Restart all the services after upgrade is done:

```
ansible-playbook -i environments/examples/cnx6/db2/inventory.ini playbooks/third_party/was-nd-restart.yml
```

Note: just to be on the safe side, in case that something was started during/after upgrade, we want to restart everything and ensure that HCL Connections apps are also up and running.

And that's it. You can access your HCL Connections application now.

## Upgrading HCL Connections from 6.5CR1 to 7.0

You already got the idea that all there is with the installation/upgrade is handled by manipulating variables in your inventory files.

For a sake of this HowTo, let's assume that we did all the steps mentioned until now: we installed HCL Connections end to end on WAS ND 8.5.5.16, and then upgraded WAS ND only from FP16 to FP18, and we have currently HCL Connections 6.5CR1 running as a result on WAS ND 8.5.5.18.

To upgrade HCL Connections itself from 6.5CR1 to 7.0, we need to do again three things:

* Change the inventory file in a proper way.
* Upgrade Connections Wizard (there is a new database that gets created with HCL Connections 7 and migration script that needs to run after it)
* Upgrade HCL Connections to version 7.0 with postinstallation tasks.

### Setting up your inventory file

For this example, we will reference [this example inventory file](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx7/db2/inventory.ini).

If you make a simple diff between [this file](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx7/db2/group_vars/all.yml) and [this file](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml) you will see that now:

* We are pointing to a folders with Connections 7 and WAS ND FP18.
* We are not overwriting any package and file name, as by default Ansible will assume that, in this moment, default version is 7, and package names for version 7 are being used.
* Be sure that [this variable](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L88) is uncommented. This variable will get the offering ID directly from the package you specify and set it up into response file, so you don't need to hardcode anything.
* Uncomment [this line](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L88). This will enable Connections Wizards playbook to create additional database(s) and run necessary migration(s) for this upgrade. After you are done with upgrades, simply disable it again (comment it).
* Note that in your new inventory file also [new application](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/roles/hcl/connections/vars/main.yml#L204) and [new database](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/roles/hcl/connections/vars/main.yml#L222) are enabled.

### Running the upgrade

Run Connections Wizards to create new database(s) and run needed migrations:

```
ansible-playbook -i environments/examples/cnx7/connections_7_with_component_pack/connections playbooks/hcl/setup-connections-wizards.yml
```

Once this step is done, you won't need it anymore. It shouldn't break anything even if you skip commenting it again, but just to be on the safe side, [comment it again here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/roles/hcl/connections-wizards/vars/main.yml#L9)

And as a next step, let's upgrade HCL Connections to 7.0:

```
ansible-playbook -i environments/examples/cnx7/connections_7_with_component_pack/connections playbooks/hcl/setup-connections-only.yml
```

Once this is done, log in to your HCL Connections 7 installation, just to confirm that all is fine.

## Final words

As you probably already noticed, same playbooks can be used for both installations and upgrades, and it is designed that way. Worst case scenario that can happen is that some services will be restarted while playbooks are ensuring that everything is the way it is described.

And this gives you already the idea - it is very easy, this way, to deploy if needed new build every day, or even multiple times per day, by ensuring that you are simply having a new package uploaded to the right folder, without even changing anything in Ansible itself.
