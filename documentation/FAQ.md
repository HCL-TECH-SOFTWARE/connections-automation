# Frequently Asked Questions

## Table of contents

[What do I see here?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#what-do-i-see-here)

[How can I start with this?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#how-can-i-start-with-this)

[What if I have some issues?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#what-if-i-have-some-issues)

[Flexnet package names are different then some default package names here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#flexnet-package-names-are-different-then-some-default-package-names-here)

[How can I use Flexnet package names for WebSphere?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#how-can-i-use-flexnet-package-names-for-websphere)

[What are the minimum system requirements to use this automation?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#what-are-the-minimum-system-requirements-to-use-this-automation)

[Can I spin up production ready environment using those scripts?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#can-i-spin-up-production-ready-environment-using-those-scripts)

[Does this works only with OpenLDAP, or can I use other LDAP servers as well?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#does-this-works-only-with-openldap-or-can-i-use-other-ldap-servers-as-well)

[How do I specify HCL Connections deployment type?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#how-do-i-specify-hcl-connections-deployment-type)

[How do I specify which clusters should auto start?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#how-do-i-specify-which-clusters-should-auto-start)

[Can I only add Component Pack with this?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#can-i-only-add-component-pack-with-this)

[What if my Connections is on Windows?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#what-if-my-connections-is-on-windows)

[Can I upgrade HCL Connections using those scripts?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#can-i-upgrade-hcl-connections-using-those-scripts)

[Can I install Component Pack in existing Kubernetes cluster using those scripts?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#can-i-install-component-pack-in-existing-kubernetes-cluster-using-those-scripts)

[Can I upgrade Component Pack using those scripts?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#can-i-upgrade-component-pack-using-those-scripts)

[Why are there many assumptions in different configuration files?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#why-are-there-many-assumptions-in-different-configuration-files)

[I am using local VM(s). Can I use this automation for that?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#i-am-using-local-vms-can-i-use-this-automation-for-that)

[Some Connections components are not installed](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#some-connections-components-are-not-installed)

[Is the controller node required for the daily operation of HCL Connections](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#is-the-controller-node-required-for-the-daily-operation-of-hcl-connections)

[Why are we using Nginx and Haproxy here?](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/master/ansible/documentation/FAQ.md#why-are-we-using-nginx-and-haproxy-here)

## What do I see here?

This is the end to end automation used by HCL Connections development team(s) to test different features for HCL Connections, Component Pack for HCL Connections and HCL Connections Docs.

Everything on main branch can be considered tested by HCL Connections development teams in at least single node, multiple single nodes (like, for example, one node for HCL Connections and another for Component Pack) or fully distributed environment. 

## How can I start with this?

If you never used Ansible before, please start with this [quick start guide](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/QUICKSTART.md).

## What if I have some issues?

The easiest way is just to open the issue/start the discussion here in Github. If you are using HCL Connections you can go through the official support channels as well, but this is the fastest and the most straight forward way to get in touch directly with the developers who are maintaining the upstream. 

## Flexnet package names are different then some default package names here

Package names used as default in those scripts are the same package names used by HCL Connections development teams inside all internal environments, including those exposed to the customers from time to time. The names used in Flexnet are IBM's part IDs.

However, if needed, you should be able to search on both names through the Flexnet to set up whatever you need. We do use Flexnet names as overwrites in [examples](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/c04747109398a2e34945d8893334aca165ea8255/environments/examples/cnx7/connections_7_without_component_pack/connections#L78-L85).

## How can I use Flexnet package names for WebSphere?

You can always override default package names. Please report the issue in Github or open a pull request if something doesn't provide that functionality.

For WebSphere, for example, this is how you overwrite default IBM names with those [HCL uses in Flexnet](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/c04747109398a2e34945d8893334aca165ea8255/environments/examples/cnx7/connections_7_without_component_pack/connections#L78-L85).

## What are the minimum system requirements to use this automation?

To spin up demo ready HCL Connections with Component Pack (including Customizer enabled), we use two nodes environments equivalent to AWS m5a.xlarge instance for DB2, OpenLDAP, IBM SDI, HCL Connections and equivalent of AWS m5a.4xlarge for Nginx, Docker (and Docker Registry), NFS server, Kubernetes and Component Pack with all the features currently automated enabled. 

If you want to use Docs as well, be sure to increase the first instance to at least m5a.2xlarge equivalent.

## Can I spin up production ready environment using those scripts?

This same automation was used for spinning up full blown distributed clusters used for performance tests and writing performance guide for HCL Connections.

## Does this works only with OpenLDAP, or can I use other LDAP servers as well?

These scripts will spin up OpenLDAP only, but even if you are using other LDAP implementations you can still use it. Be sure to properly configure [this section](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/35b558e9d28e79aa5cde1d960964764e7a6efa63/environments/examples/cnx7/connections_7_with_component_pack/connections#L99-L105) as this data will be used in that case for setting up (and running) IBM SDI, and for importing SSL certificate to the trust store on WebSphere during IBM WASND installation. Please note that it is expected that your LDAP implementation has LDAPS configured.

## How do I specify HCL Connections deployment type?

[This example](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/c04747109398a2e34945d8893334aca165ea8255/environments/examples/cnx7/connections_7_without_component_pack/connections#L141-L162) shows how would normally medium deployment look like. It is your choice how do you want to customize this. There are currently no specific switches/variables which would say what which type of deployment is as seen when running visual installer.

## How do I specify which clusters should auto start?

[This line](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/c04747109398a2e34945d8893334aca165ea8255/environments/examples/cnx7/connections_7_without_component_pack/connections#L173) lists all the clusters that should start automatically. The reason why not all clusters are started or stopped automatically is simply that in some cases you don't want some clusters running at all (one of the first examples being Push cluster). 

## Can I only add Component Pack with this?

Yes, this automation is flexible enough that you can install everything or just a part of it, in this case Component Pack only (yes, also on already running HCL Connections environment). 

## What if my Connections is on Windows?

All the steps that would be otherwise done by Ansible on your Windows side would have to be executed manually. 

## Can I upgrade HCL Connections using those scripts?

Yes, with a proper customization, and running the playbooks in specific order, you can. 

## Can I install Component Pack in existing Kubernetes cluster using those scripts?

Yes. The scripts are written in a way that you can spin up everything end to end, or you can install just part of it, in this case Component Pack. You also can use external Docker Registry (or equivalent you are using) and whatever NFS server you are already using.

## Can I upgrade Component Pack using those scripts?

Yes, you can upgrade or recreate Component Pack with those scripts. 

## Why are there many assumptions in different configuration files?

This automation was written exclusively to support HCL Connections, Component Pack for HCL Connections and HCL Connections Docs install. All third party modules are just a minimum needed to run HCL products, configured exactly in a way that HCL Connections development uses it to sign it off during different types of tests. At the same time, this automation is open sourced exactly due to this reason: HCL is aware that different customers have different use cases, so they get a chance to customize it their way while still having what HCL does for 1:1 comparison.

## I am using local VM(s). Can I use this automation for that?

Yes. And we would point you towards [HashiCorp Vagrant](https://www.vagrantup.com/). So far, both single node HCL Connections and single node (single VM) Component Pack for HCL Connections were tested, and Vagrant is also used locally by automation development teams. Please note that you would need some local resources to do this. We were not able to get self contained Connections (with DB2, OpenLDAP, TDI, WAS ND and Connections of top of that) without at least 4 CPUs and 12G of RAM, and 4CPUs and 10G of RAM for VM hosting Docker, Docker Registry, NFS, Kubernetes & Component Pack (to the point that all the pods are up and running).

## Some Connections components are not installed

Not everything is covered currently, but more is being added every day. This automation doesn't follow standard HCL Connections release cycle, but we are pushing new fixes and features at least once per week to the main branch, and we are creating new stable releases at least once per month.

Also, feel free to send us your PRs or feature requests using discussion boards here on Github.

## Is the controller node required for the daily operation of HCL Connections

No, it's not. However, any node can be controller node (if you are using Linux or MacOS, also your own local machine can be that, if your security setup allows it). It is useful to be able to run the scripts from time to time. For example, they are already supporting running some maintenance tasks on DB2 level (like running runstats, reorg and cleaning up scheduler). Since we are updating it every single day with new fixes and adding new features, it is also worth being able to run it from time to time simply to ensure that everything new is there as well.

## Why are we using Nginx and Haproxy here?

Nginx is used just as a reverse proxy example. You can use whatever web server you are used to use.

Haproxy is definitely not mandatory, but if you are creating a Kubernetes cluster specifically with more then one master, you do need some load balancer in front of it. Also, if you are using Amazon EKS or RedHat OpenShift for your Component Pack installation, this Haproxy solves potential CORS issues for you. But no, Haproxy is not mandatory either.
