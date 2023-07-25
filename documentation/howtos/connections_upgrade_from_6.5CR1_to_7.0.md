# Upgrading HCL Connections using Ansible automation

This automation is used by HCL from HCL Connections 6.5CR1 to test HCL Connections and Component Pack upgrades.

For this example, we will show:

* How to install HCL Connections 6.5CR1
* How to use the same automation to upgrade HCL Connections 6.5CR1 (6.5 CR1) to HCL Connection 7 and
* What is the logic behind it.

NOTE: If this is the very first document you are landing on, please ensure that you read already our [README.md](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/README.md) and our [Quick Start Guide](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/QUICKSTART.md), specially if you never used Ansible and/or this automation before.

## Installing HCL Connections 6.5CR1

The easiest and most straight forward way to set up any end-to-end HCL Connections installation is to simply:

* Set up your inventory file the way you want (we will use [this example file for setting up 6.5CR1- inventory.ini](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/inventory.ini) and [group_vars](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml))
* Use CentOS 7 Or RHEL 8.5 (the later CentOS 7 Or RHEL 8.5 the better)

...and simply run your playbook with

```
ansible-playbook -i environments/examples/cnx6/db2/inventory.ini playbooks/setup-connections-complete.yml
```

## Running this playbook, as you can see [here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/playbooks/setup-connections-complete.yml) will simply set up IBM DB2, NFS, Connections Wizards, OpenLDAP, setup and run IBM SDI, setup IBM WebSphere ND with all the dependencies, and install HCL Connections on top of that.

Before you proceed, let's analyse very quickly what is important for which step.

### Setting up your inventory file

To set up 6.5CR1, let's assume that we want to also install IBM WebSphere ND 8.5.5 with latest supported FixPack.

Please note that [files in this folder ](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/) are already set to overwrite defaults, which means it will install non default packages and we will explain here what it is doing differently:

* We have our HCL Connections and HCL Connections Wizards installer living in a folder called Connections6.5, so we are setting the right paths [here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L44)
* We want, specifically, to install IBM WebSphere 8.5.5 with Fixpack, and we [specify the location here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L40-L42)
* We need to specify that we are not installing default version 7, and we do it [here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L74)

* As connections kit names are different for different versions, so we need to specify [Connections install kit name](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L72) and [Connections Wizard kit name](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L73). Also specify [Connections 6.5CR1 version name](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L75) and [Connections 6.5CR1 fixes install kit name](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L76-L77).
* We are preparing the database for 6.5CR1, not for 7, and we tell it to Ansible [here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L78)
* For connections 6.5CR1 , provide file name to download for [database schema upgrade](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L79)
* Elastic Search version 5 is supported on connections 6.5CR1, specify right Elastic Search [Version](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L80) and [Port](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml#L140)

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
* OpenLDAP would be installed, IBM TDI after that, and NFS set up by default, since HCL Connections is requiring it by default.
* IBM WebSphere ND 8.5.5 with FixPack would be installed (in background, base version would be always installed and then upgraded to the FixPack per was_fp_version in [VARIABLES.md](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/VARIABLES.md)
* HCL Connections 6.5CR1 would be installed. Specifying proper version above would tell it to use proper response file (the only delta between response file between version 6.* and 7 is one extra app, IC360)

## Upgrading HCL Connections from 6.5CR1 to 7.0

You already got the idea that all there is with the installation/upgrade is handled by manipulating variables in your inventory files.

For a sake of this HowTo, let's assume that we did all the steps mentioned until now: we installed HCL Connections end to end on WAS ND 8.5.5 with Fixpack, and we have currently HCL Connections 6.5CR1 running as a result on WAS ND.

To upgrade HCL Connections itself from 6.5CR1 to 7.0, we need to do again three things:

* Change the inventory file in a proper way.
* Upgrade Connections Wizard (there is a new database that gets created with HCL Connections 7 and migration script that needs to run after it)
* Upgrade HCL Connections to version 7.0 with post installation tasks.

### Setting up your inventory file

For this example, we will reference [this example inventory folder](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/environments/examples/cnx7/db2).

If you make a simple diff between [this file](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx7/db2/group_vars/all.yml) and [this file](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx6/db2/group_vars/all.yml) you will see that now:

* We are pointing to a folders with Connections 7 and WAS ND with Fixpack.
* We are not overwriting any package and file name, as by default Ansible will assume that, in this moment, default version is 7, and package names for version 7 are being used.

### Running the upgrade

Run Connections Wizards to create new database(s) and run needed migrations:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/hcl/setup-connections-wizards.yml
```

And as a next step, let's upgrade HCL Connections to 7.0:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/hcl/setup-connections-only.yml
```

Once this is done, log in to your HCL Connections 7 installation, just to confirm that all is fine.

## Final words

As you probably already noticed, same playbooks can be used for both installations and upgrades, and it is designed that way. Worst case scenario that can happen is that some services will be restarted while playbooks are ensuring that everything is the way it is described.

And this gives you already the idea - it is very easy, this way, to deploy if needed new build every day, or even multiple times per day, by ensuring that you are simply having a new package uploaded to the right folder, without even changing anything in Ansible itself.

As for the Component Pack, upgrading from 6.5CR1 directly to the Component Pack hosted in the HCL Harbor registry is not supported.  Please follow the product documentation to upgrade to Connections v7.0 first.
