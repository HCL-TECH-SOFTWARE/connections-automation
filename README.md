# HCL Connections and Component Pack Automation Scripts

This set of scripts is able to spin up end-to-end HCL Connections 7 with Component Pack and all the dependencies. They can be used as whole and set up end to end environment, including the set of fake users for a sake of quickly being able to log in and see how the application works, or they can can be used autonomously from each other.  

Before you start, please be sure to check out [Frequently Asked Questions](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/FAQ.md).

For HCL Connections 7 dependencies this means that:

* Database will be installed (IBM DB2, Oracle or Microsoft SQL Server), configured as per Performance tunning guide for HCL Connections, and license applied. Please note: the license, the same one from FlexNet, will be applied only to IBM DB2 v11.1. If you want to learn more about using HCL Connections with different database backends, please [check out this document](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/howtos/setup_connections_with_different_database_backends.md).
* HCL Connections Wizard will populate the database with needed schemas and grants.
* If needed for demo or even production purposes, OpenLDAP will be spun up and seeded with some demo users. OpenLDAP will be spun up with SSL enabled, as needed later for setting up IBM WebSphere Application Server properly.
* IBM TDI will be installed, configured, and run to populate profiles database in IBM DB2 with users from OpenLDAP
* IBM Installation Manager will be set up on the nodes where IBM WebSphere Application Server Network Deployment needs to be installed.
* IBM WebSphere Application Server Network Deployment will be set up where needed. Currently we tested it with Fixpack 16 and 18. By default, FP18 is going to be installed. Deployment manager and nodeagents profiles are going to be created, application security enabled, TLS certificated imported from LDAP, LDAP configured up to the point where it is ready to install HCL Connections 7.
* IBM HTTP Server is going to be installed, patched with the same fixpack as IBM WebSphere Application Server, and added to the deployment manager.
* NFS server will be installed, including master and clients configurations and proper folders set.

For HCL Connections 7 itself it means:

* The script will mount NFS shares needed for the shared data and message stores where needed.
* Install and configure database (currently IBM DB2 and Oracle are supported)
* HCL Connections 7 will be downloaded and installed. Any type of layout is supported and customizable.
* In LotusConnections-config.xml dynamicHost will be updated.
* Optionaly, Prometheus JMX exported will be enabled for all HCL Connections clusters.
* Optionally, Moderation can be enabled as well.
* In case of upgrades, it will clean up temp folders to prevent possible issues with UI post upgrade.
* All or some (or none) clusters will be started automatically.
* IBM HTTP Server plugins will get generated and propagated
* IBM HTTP Server's httpd.conf will be generated ready to support Component Pack integrations.
* Needed post installation tasks on IBM WebSphere Application Server, like setting up properly session management and single sign on will be also handled.

For Component Pack for HCL Connections 7 it means:

* Nginx will be set up and configured to support Customizer.
* Haproxy will be set up configured to be the control plane for Kubernetes cluster and Component Pack.
* NFS will be set up for Component Pack.
* docker-ce 19.08.15 will be set up and configured for overlay2 and systemd support with the optimisations required by the version of Kubernetes.
* Docker Registry will be set up on all future Kubernetes nodes, including enabling and handling TLS.
* Kubernetes 1.18.18 will be set up.
* Component Pack will be set up by default using latest community Kubernetes Ingress, Grafana and Prometheus for monitoring out of the box.
* Post installation tasks needed for configuring Component Pack and the WebSphere-side of Connections to work together are also going to be executed, including enabling searches and Metrics using ElasticSearch 7.

## Requirements:

* Ansible 2.9 installed on your machine
* SSH access (passwordless makes stuff easier, but not mandatory) to the machine(s) you want to provision. Be sure that key forwarding is properly set on your controller and on all machines that you plan to manage with.
* Your user (or any user used for the purposes of provisioning) having passwordless sudo acces on the nodes being provisioned.

To learn more about how to install Ansible on your local machine or Ansible controller, please check out [official Ansible documentation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

Supported OSs:

* CentOS 7+
* RHEL 7+

NOTE: Recommended OS for this automation is CentOS/RHEL 7.9. All HCL Connections, Docs and Component Pack builds are done on CentOS/RHEL 7. While it is being tested, in different scenarios, using version 8+ of both CentOS and RHEL you may hit different issues that are eventually not being tested. Component Pack itself is also tested on Amazon EKS and RedHat OpenShift 4 to ensure that builds are compatible.

### Have files ready for download

To be able to use this automation you will need to be able to download the packages.

The suggestion is to have them all downloaded in a single location, and for this you would need at least 50G of disk space. Run a small HTTP server just to be able to serve them, it can be as simple as a single Ruby one liner to open web server on specific port so that automation can connect and download it.

This is the example data folder structure we are following at HCL

```
[root@c7lb1 packages]# ls -la *
Connections6.5:
total 3185512
drwxr-xr-x.  2 root orion         88 Sep 11 12:34 .
drwxr-xr-x. 13 root orion        192 Nov 18 08:33 ..
-rw-r--r--.  1 root orion 2444339200 Apr 23  2020 HCL_Connections_6.5_lin.tar
-r-xr-xr-x.  1 root orion  817623040 Apr 28  2020 HCL_Connections_6.5_wizards_lin_aix.tar

Connections7:
total 3079024
drwxr-xr-x.  2 root    orion          195 Feb  4 21:29 .
drwxr-xr-x. 16 root    orion          238 Jan 27 14:26 ..
-r-xr-xr-x.  1 dmenges dmenges 2001305600 Jan 20 11:54 HCL_Connections_7.0_lin.tar
-r-xr-xr-x.  1 root    root     817807360 Dec 17 05:21 HCL_Connections_7.0_wizards_lin_aix.tar
-rw-r--r--.  1 root    root     125556954 Feb  4 21:24 LO100079-IC7.0.0.0-Common-Fix.jar
-rwxr--r--.  1 root    root     189793326 Feb  4 21:28 updateInstaller.zip

DB2:
total 2067052
drwxr-xr-x.  2 dmenges orion           96 Nov 19 11:01 .
drwxr-xr-x. 13 root    orion          192 Nov 18 08:33 ..
-rw-r--r--.  1 dmenges dmenges    3993254 Oct 16 13:13 CNB23ML.zip
-rw-r--r--.  1 dmenges orion    250880000 Jun  3 10:48 v11.1.4fp5_jdbc_sqlj.tar.gz
-rw-r--r--.  1 dmenges orion   1861783964 Apr 23  2020 v11.1.4fp5_linuxx64_universal_fixpack.tar.gz

Docs:
total 1397484
drwxr-xr-x.  2 root orion        78 Sep  7 11:31 .
drwxr-xr-x. 13 root orion       192 Nov 18 08:33 ..
-r-xr-xr-x.  1 root orion 737753769 Sep  7 11:02 IBMConnectionsDocs_2.0.1.zip

MSSQL:
total 2956
drwxr-xr-x.  2 root    root         84 Mar  1 10:02 .
drwxr-xr-x. 17 root    orion       263 Mar  1 10:01 ..
-rw-r--r--.  1 dmenges dmenges  838550 Mar  1 10:01 sqljdbc_4.1.8112.200_enu.tar.gz
-rw-r--r--.  1 dmenges dmenges 2186950 Mar  1 10:01 sqljdbc_6.0.8112.200_enu.tar.gz

Oracle:
total 2998572
drwxr-xr-x.  2 root       root               96 Feb 22 13:41 .
drwxr-xr-x. 16 root       orion             238 Jan 27 14:26 ..
-rwxr--r--.  1 root       root       3059705302 Jan 25 15:12 LINUX.X64_193000_db_home.zip
-rw-r--r--.  1 root       root          3389454 Feb 22 13:41 ojdbc6.jar
-rw-r--r--.  1 sabrinayee sabrinayee    3397734 Feb 18 21:54 ojdbc7.jar
-rw-r--r--.  1 sabrinayee sabrinayee    4036257 Feb 18 21:54 ojdbc8.jar

TDI:
total 704248
drwxr-xr-x.  2 root orion        70 May  6  2020 .
drwxr-xr-x. 13 root orion       192 Nov 18 08:33 ..
-r-xr-xr-x.  1 root orion  76251327 May  6  2020 7.2.0-ISS-SDI-FP0006.zip
-r-xr-xr-x.  1 root orion 644894720 Apr 30  2020 SDI_7.2_XLIN86_64_ML.tar

cp:
total 22500184
drwxr-xr-x.  2 dmenges orion         255 Nov 19 10:10 .
drwxr-xr-x. 13 root    orion         192 Nov 18 08:33 ..
lrwxrwxrwx.  1 root    root           31 Nov 17 21:01 component_pack_65.zip -> hybridcloud_20191122-120706.zip
lrwxrwxrwx.  1 root    root           31 Nov  6 17:21 component_pack_6501.zip -> hybridcloud_20200420-105909.zip
lrwxrwxrwx.  1 root    root           49 Nov 19 10:10 component_pack_latest.zip -> /data/packages/cp/hybridcloud_20201118-181644.zip
-r-xr-xr-x.  1 root    root   5339289797 Nov 17 21:01 hybridcloud_20191122-120706.zip
-rw-rw-r--.  1 dmenges orion  5559028115 Apr 20  2020 hybridcloud_20200420-105909.zip
-rw-rw-r--.  1 dmenges orion  6667502885 Aug 25 17:30 hybridcloud_20200825-172059.zip
-rw-r--r--.  1 lcuser  lcuser 5474360862 Nov 19 10:10 hybridcloud_20201118-181644.zip

was855:
total 8280848
drwxr-xr-x.  2 dmenges orion       4096 Oct 21 09:18 .
drwxr-xr-x. 13 root    orion        192 Nov 18 08:33 ..
-rw-r--r--.  1 dmenges orion 1025869744 Apr 23  2020 8.0.5.17-WS-IBMWASJAVA-Linux.zip
-rw-r--r--.  1 root    root  1022054019 Oct 21 09:15 8.0.6.15-WS-IBMWASJAVA-Linux.zip
-rw-r--r--.  1 dmenges orion  135872014 Apr 23  2020 InstalMgr1.6.2_LNX_X86_64_WAS_8.5.5.zip
-rw-r--r--.  1 dmenges orion 1054717615 Apr 23  2020 WAS_ND_V8.5.5_1_OF_3.zip
-rw-r--r--.  1 dmenges orion 1022550691 Apr 23  2020 WAS_ND_V8.5.5_2_OF_3.zip
-rw-r--r--.  1 dmenges orion  902443241 Apr 23  2020 WAS_ND_V8.5.5_3_OF_3.zip
-rw-r--r--.  1 dmenges orion  112238284 Apr 23  2020 WAS_ND_v8.5.5_Liberty.zip
-rw-r--r--.  1 dmenges orion  976299561 Apr 23  2020 WAS_V8.5.5_SUPPL_1_OF_3.zip
-rw-r--r--.  1 dmenges orion 1056708869 Apr 23  2020 WAS_V8.5.5_SUPPL_2_OF_3.zip
-rw-r--r--.  1 dmenges orion  998887246 Apr 23  2020 WAS_V8.5.5_SUPPL_3_OF_3.zip
-rw-r--r--.  1 dmenges orion  171921530 Apr 23  2020 agent.installer.linux.gtk.x86_64_1.8.9006.20190918_1303.zip
-rw-r--r--.  1 root    root   215292676 Aug 12 22:52 agent.installer.linux.gtk.x86_64_1.9.1003.20200730_2125.zip

was855FP16:
total 7391380
drwxr-xr-x.  2 dmenges orion       4096 Oct 21 09:08 .
drwxr-xr-x. 13 root    orion        192 Nov 18 08:33 ..
-rw-r--r--.  1 dmenges orion 1037725904 Apr 23  2020 8.0.5.37-WS-IBMWASJAVA-Linux.zip
-rw-r--r--.  1 dmenges orion  359841878 Apr 23  2020 8.0.5.37-WS-IBMWASJAVA-Win.zip
-rw-r--r--.  1 dmenges orion  967852764 Apr 23  2020 8.5.5-WS-WAS-FP016-part1.zip
-rw-r--r--.  1 dmenges orion  216147845 Apr 23  2020 8.5.5-WS-WAS-FP016-part2.zip
-rw-r--r--.  1 dmenges orion 1899893435 Apr 23  2020 8.5.5-WS-WAS-FP016-part3.zip
-rw-r--r--.  1 dmenges orion  471099562 Apr 23  2020 8.5.5-WS-WASSupplements-FP016-part1.zip
-rw-r--r--.  1 dmenges orion  716291953 Apr 23  2020 8.5.5-WS-WASSupplements-FP016-part2.zip
-rw-r--r--.  1 dmenges orion 1899893435 Apr 23  2020 8.5.5-WS-WASSupplements-FP016-part3.zip

was855FP18:
total 7240080
drwxr-xr-x.  2 root    orion       4096 Oct 21 09:12 .
drwxr-xr-x. 13 root    orion        192 Nov 18 08:33 ..
-rw-r--r--.  1 root    orion 1022054019 Sep 24 15:33 8.0.6.15-WS-IBMWASJAVA-Linux.zip
-rw-rw-r--.  1 dmenges orion 1024726232 Sep 24 16:17 8.5.5-WS-WAS-FP018-part1.zip
-rw-rw-r--.  1 dmenges orion  216415911 Sep 24 16:20 8.5.5-WS-WAS-FP018-part2.zip
-rw-rw-r--.  1 dmenges orion 1955876681 Sep 24 16:23 8.5.5-WS-WAS-FP018-part3.zip
-rw-r--r--.  1 root    orion  472424472 Sep 24 16:40 8.5.5-WS-WASSupplements-FP018-part1.zip
-rw-r--r--.  1 root    orion  766454469 Sep 24 16:44 8.5.5-WS-WASSupplements-FP018-part2.zip
-rw-r--r--.  1 root    orion 1955876681 Sep 24 16:47 8.5.5-WS-WASSupplements-FP018-part3.zip
```

Of course, you can drop it all to a single folder, or restructure it whatever way you prefer.

### Inventory files

Inventory files live in environments folder. To keep things simple, there are two files (you can break it to more if you want, it's up to you):
* inventory.ini which has all FQDNs of the hosts in different groups
* group_vars/all.yml with the variables you can customize.

We strongly recommend using the current model for handling variables. However, if you still want to stick with the old model, the only thing you need to add is cnx_was_servers group to your old connections inventory file. Otherwise, it is backwards compatible.

### SSH User

If you run the Ansible playbooks from a Mac or Linux host, you need to specify the `remote_user` for the SSH connection, or it will default to your local username.

Edit `ansible.cfg` and remove the comment `#` from the line and set your user:

    # remote_user = root

Example:

    remote_user = sysadmin

The `ansible.cfg` allows a lot of settings, see the example file at https://github.com/ansible/ansible/blob/devel/examples/ansible.cfg and it can stay in the root of your Ansible project, or can be placed in `~/.ansible.cfg`, then it will work for all of your Ansible projects.

### Supported layouts

Those scripts should be able to support both single node installations and HA environments, specifically:

* We tested with a single WAS node (DMGR, IHS, and Node agent co-located)
* We tested with a proper distributed WAS (two separate WAS nodes, two separate IHSs behind internal load balancer, DMGR on a dedicated machine)
* Kubernetes can be single node installation or any type of HA. Scaling is also supported by those scripts (you can add new masters or workers if you created your Kubernetes environment using those scripts in the first place).

### Cache folders

Running those scripts specifically for Component Pack will create two cache folders:

* /tmp/k8s_cache and
* /home/${YOURUSER}/generated_charts

The second one will have all the values generated when running Helm installs. Those value files are used by Helm to install Component Pack. Values you see inside are coming from a variables inside your automation.

## Setting up HCL Connections with its dependencies

This scenario is useful in multiple cases:
* If you want to spin up a demo environment where you want to be able to quickly log in and start using it
* If you want to spin up a production ready environment that you know will work, see it work, and then start replacing component by component (like switching/adding LDAP servers, switching databases, etc).

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/setup-connections-complete.yml
```

Running this playbook will:
* Setup database (IBM DB2 or Oracle) with HCL Connections Wizards on top
* Install OpenLDAP and populate it with a number of fake user, one of them being the HCL Connections admin user
* Set and execute IBM TDI to popule PeopleDB with LDAP users
* Install IBM WebSphere Application Server Network Deployment and IBM HTTP Server and configure it properly
* Install HCL Connections on top of that

You can, of course, run those steps separately.

### Setting up IBM DB2

To install JDBC drivers for DB2 on WAS nodes for example, please set:

```
setup_db2_jdbc: True
```

To install IBM DB2 only, execute:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/third_party/setup-db2.yml
```

This will install IBM DB2 on a Linux server, tune the server and IBM DB2 as per Performance tunning guide for HCL Connections, and apply the licence.

In case IBM DB2 was already installed nothing will happen, the scripts will just ensure that everything is as expected. JDBC drivers will be only installed if the variable mentioned above is also set.

### Setting up Oracle database

To install JDBC drivers for Oracle on WAS nodes for example, please set:

```
setup_oracle_jdbc: True
```

To install Oracle 19c only, execute:

```
ansible-playbook -i environments/examples/cnx7/oracle/inventory.ini playbooks/third_party/setup-oracle.yml
```

Running this playbook will set up the prerequisites for Oracle 19c (like setting up big enough swap on the node dedicated for Oracle database) but it will also set up the JDBC for HCL Connections and HCL Connections Docs.

JDBC drivers for Oracle will be only installed if you have setup_oracle_jdbc set to true as mentioned above.

### Installing HCL Connections Wizards

This requires the database already being set. To create the databases and apply the grants, execute:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/hcl/setup-connections-wizards.yml
```

If databases already exist, this script will execute runstats and rerogs on all the databases by default on each consecutive run.

If you want to recreate the databases, uncomment:

```
#cnx_force_repopulation: True
```

If you are upgrading from Connections 6.5.0.1 to 7 and want to only create IC360 database and run needed migrations, uncomment:

```
#db_enable_upgrades: True
```

in your inventory file. This will then drop all the databases and recreate them again. Don't forget to run TDI afterwards. Be sure to comment it again once you do it.

### Setting up OpenLDAP with SSL and amount of fake users

To install OpenLDAP with SSL enabled and generate fake users, execute:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/third_party/setup-ldap.yml
```

You can turn on or off creating any of fake users by manipulating:

```
setup_fake_ldap_users: True
```

If you are creating them, you can manipulate the details using next set of variables:

```
ldap_nr_of_users: 2500
ldap_userid: "fakeuser"
ldap_user_password: "password"
ldap_user_admin_password: "password"
```

This will create 2500 fake accounts, starting with user id 'fakeuser1' and going to 'fakeuser2499'. First of them in this case (fakeuser1) will get 'ldap_user_admin_password' set, and all others are going to get 'ldap_user_password'. On top of that, it you will get automatically 10 more users created being set as external. Be sure to set in this case one of those users as HCL Connections admin user before the Connections installation like here:

```
connections_admin: fakeuser1
ldap_user_mail_domain: "connections.example.com"
```

This comes in handy if you don't have any other LDAP server ready and you want to quickly get to the point where you can test HCL Connections. You can later replace this LDAP with any other one.

### Setting up IBM TDI and populating PeopleDB

To install IBM TDI, set up tdisol folder as per documentation, and migrate the users from LDAP to IBM DB2, run:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/third_party/setup-tdi.yml
```

### Installing and configuring IBM WebSphere Application Server only

To install IBM WebSphere Application Server, you should alraedy have either LDAP installed all LDAP data properly configured in your inventory file, in the section like this:

```
# This is just an example!
ldap_server: ldap1.internal.example.com
ldap_alias: ldap1
ldap_repo: LDAP_PRODUCTION1
ldap_bind_user: cn=Admin,dc=cxn,dc=example,dc=com
ldap_bind_pass: password
ldap_realm: dc=cxn,dc=example,dc=com
ldap_login_properties: uid;mail
```

LDAP should also have SSL enabled as IBM WebSphere Application Server is going to try to import its TLS certificate and fail if there is none.

And in the end, you need to create WebSphere user account by setting this:

```
was_username=wasadmin
was_password=password
```

To install JDBC drivers for Oracle, please set:

```
setup_oracle_jdbc: True
```

To install IBM WebSphere Application Server, IBM HTTP Server and configure it, execute:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/third_party/setup-webspherend.yml
```

### Preparing NFS for HCL Connections

By default, HCL Connections would use NFS for message stores and shared data. In case of single node and small demo environments, NFS is not needed, and that is also supported.

If you are going to use NFS with HCL Connections, then set it up first before you proceed with HCL Connections installation with:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/third_party/setup-nfs.yml
```

### Installing HCL Connections

By default, use of NFS is enabled, which means HCL Connections would try to mount the folders for shared data and message store. Note that NFS is needed if you plan to install HCL Docs later on a separate server.  If you don't want it to be mounted and don't plan to install HCL Docs on a separate server, set:

```
skip_nfs_mount_for_connections: true
```

To install the WebSphere-side of HCL Connections only, on an already prepared environment (all previous steps are already done and the environment is ready for HCL Connections to be installed) execute:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/hcl/setup-connections-only.yml
```

Note that installation will not start (and will inform you about that) if mandatory variables are missing.

To enable Moderation and Invites, set:

```
cnx_enable_moderation: true
cnx_enable_invite: true
```

To ensure that you don't have to pin specific offering version yourself, make sure that the next variable is set:

```
cnx_updates_enabled: True
```

You can also rewrite locations of message and shared data stores by manipulating next two variables before you hit install:

```
cnx_shared_area: "/nfs/data/shared"
cnx_message_store: "/nfs/data/messageStores"
```

### Installing iFix for HCL Connections

To install iFix for HCL Connections 7 (version 7.0.0.1) on already installed HCL Connections 7, edit your connections inventory file, and append these two lines:

```
ifix_apar:                                       CFix.70.2110
ifix_file:                                       CFix.70.2110-IC7.0.0.0-Common-Fix.jar
cnx_ifix_installer:                              "updateInstaller_2104.zip"
```

After it, run the iFix installation:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/hcl/setup-connections-ifix.yml
```

### Running post installation tasks

Once your Connections installation is done, run this playbook to set up some post installation bits and pieces needed for Connections 7 on WebSphere:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/hcl/connections-post-install.yml
```

## Setting up Component Pack for HCL Connections 7 with its dependencies

To set up Component Pack, you should have the WebSphere-side of Connections already up and running and be able to log in successfully.

To set up Component Pack, execute:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/setup-component-pack-complete.yml
```

This playbook will:

* Set up Nginx
* Set up Haproxy
* Set up NFS
* Set up Docker and Docker Registry
* Set up Kubernetes
* Install and configure Component Pack to work with Connections

By default, Component Pack will consider first node in [nfs_servers] to be your NFS master also, and by default it will consider that on NFS master, all needed folders for Component Pack live in /pv-connections. You can rewrite it with:

```
nfsMasterAddress: "172.29.31.1"
persistentVolumePath: "nfs"
```

This translates to //172.29.31.1:/nfs

Note: The Component Pack installation and configuration contains tasks with an impact on the WebSphere-side of Connections side which require restarts of WebSphere and Connections itself, and which will be executed.

### Setting up Nginx

Nginx is used only as an example of a reverse proxy for the WebSphere-side of Connections and Component Pack.

To install Nginx only, execute:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/third_party/setup-nginx.yml
```

### Setting up Haproxy

Haproxy is used as an example load balancer. To ensure it is not trying to bind to the same ports as Nginx, by default, it is going to use non standard ports (81 and 444).

If you want to change the default ports (81 and 444) edit your all.yml and set up those two variables to different values:

```
main_port: '81'
main_ssl_port: '444'
```

To install Haproxy only, execute:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/third_party/setup-haproxy.yml
```

### Setting up NFS

If you are setting up your own NFS, execute:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/third_party/setup-nfs.yml
```

This will set up the NFS master, create and export needed folders for Component Pack components, and set up the clients so they can connect to it.

By default, NFS master will export the folders for its own network. If you want to change the netmask, be sure to set for example:

```
nfs_export_netmask: 255.255.0.0
```

### Setting up Docker and Docker Registry

This will install docker-ce and configure Docker Registry with SSL enabled, and also ensure that all future workers can authenticate to that Docker Registry. Default usernames/passwords can be overridden.

To set it up, execute:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/third_party/setup-docker-registry.yml
```

### Setting up Kubernetes

This will install Kubernetes, set up kubectl and Helm and make the Kubernetes cluster ready for Component Pack to be installed. However, this is really a minimum way of installing a stable Kubernetes using kubeadm. We do advice using more battle-proven solutions like kubespray or kops (or anything else) for production-ready Kubernetes clusters.

This set of automation will install by default 1.18.18 and should be always able to install the Kubernetes versions supported by Component Pack.

To install Kubernetes, execute:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/third_party/kubernetes/setup-kubernetes.yml
```

#### Setting up kubectl for your user

If the cluster is already created, and you only want to set up kubectl for your own user, just run:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/third_party/kubernetes/setup-kubectl.yml
```

### Setting up Component Pack without Haproxy

If you don't want to use Haproxy (if you simply don't need it), then you can use this playbook:

```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/setup-component-pack-complete-development.yml
```

It will do exactly the same as playbooks/setup-component-pack-complete.yml but it will not setup Haproxy.

## Troubleshooting

For each machine that is going to be used in any capacity with those scripts, ensure that:

* You run yum/dnf update before you start doing anything (there are multiple components that can fail installing if you don't do this)
* You have user accounts created
* DNS is properly set and reverse DNS works fine in any direction
* You have proper network and internet access where needed (no firewall issues etc)
* Machine hostnames are set properly (there are multiple components that can fail installing if this is not the case)

As a rule of thumb, be sure that:

* User that is running Ansible can SSH into all the servers mentioned inside your inventory files.
* User that is running Ansible have passwordless sudo access on all the servers mentioned inside your inventory files.
* User that is running Ansible has key forwarding enabled. Automation will try to SSH from one machine to another to execute specific tasks, run rsync etc. which can fail if key forwarding is not properly configured.
* Ansible is using Python. It *can* happen that something doesn't work as expected in your own scenario, depending on OS level, changes in distribution, etc.


# HCL Connections Docs Automation Scripts
This set of scripts is able to spin up end-to-end HCL Connections Docs on top of an existing HCL Connections deployed by the ansible scripts described above.

For HCL Connections Docs dependencies this means that:
* HCL Docs database will be created with needed user, schemas and grants.
* WebSphere application clusters will be created for each Docs components.
* WebSphere Job Manager targets will be created for Docs and Conversion nodes, Deployment Manager and Web Server.

For HCL Connections Docs itself it means:
* The script will mount NFS shares needed for the HCL Connections shared data, Docs data and Viewer data.
* HCL Docs installation kit will be downloaded.  Document Format Conversion, Editor and Viewer applications, Editor and Viewer Extensions, Editor Proxy Filter will be installed.
* IBM HTTP Server plugins will be re-generated and propagated to the web servers.
* All clusters will be started automatically at the end of the install.

## Requirements:
* HCL Connections has been installed using the Ansible script describe above.

### Have files ready for download
* See [Have files ready for download](https://github.com/HCL-TECH-SOFTWARE/connections-automation#have-files-ready-for-download) above.

### Installing HCL Connections Docs

To install HCL Connections Docs, after adjusting your inventory files, execute:
```
ansible-playbook -i environments/examples/cnx7/db2/inventory.ini playbooks/hcl/setup-connections-docs.yml
```

### HCL Connections Docs Troubleshooting
* If HCL Connections Docs configuration adjustment is needed after the install, it can be done in `/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/config/cells/${CELLNAME}/IBMDocs-config` on the WebSphere Deployment Manager.  Make sure to do a full re-synchronize to propagate any changes to all Docs nodes.
* If options are not available in HCL Connections Files to create Document/Spreadsheet/Presentation, follow Step#3 in [documentation](https://help.hcltechsw.com/docs/v2.0.1/onprem/install_guide/guide/text/functional_verification_of_installation.html) to check if the HCL Docs and File Viewer extensions are installed and active within HCL Connections. If the modules are not listed, on the HCL Connections server, go to `{{cnx_data_path_on_cnx_server}}` based on the inventory file, then go to `/provision/webresources` in that location to make sure the jars are there. Also, go to the WAS admin console to make sure `HCLDocsProxyCluster` Proxy server cluster is running.
* If you wish to re-install a HCL Connections Docs component, first cd to `/opt/HCL/<component>/installer` (`/opt/HCL/<component>/extension/installer` for Docs or Viewer extension) then run `sudo ./uninstall.sh` (`sudo ./uninstall_node.sh on subsequent nodes if exist`, ) to uninstall the component.  Delete the .success file in `/opt/HCL/<component>/` then run the playbook again.  It is recommended to comment out the prior steps in the playbook to save time.
* If you run into a problem while running a playbook, examine the output to determine the specific command that is failing.  It is often best to try to manually run this command and to troubleshoot the specific problem before trying to run the playbook again. Based on this investigation, you'll either resolve the problem that prevented the step from completing, or you will have successfully run the command manually.  You can then run the playbook again and it will either complete the step or skip the step if no further work is needed.

## Acknowledgments

This project was inspired by the [Ansible WebSphere/Connections 6.0 automation done by Enio Basso](https://github.com/ebasso/ansible-ibm-websphere). It is done in a way that it can interoperate with the mentioned project or parts of it.

## License

This project is licensed under Apache 2.0 license.

## Disclaimer

This product is not officially supported, and can be used as is. This product is only proof of concept, and HCL Technologies Limited would welcome any feedback. HCL Technologies Limited does not make any warranty about the completeness, reliability and accuracy of this code. Any action you take by using this code is strictly at your own risk, and HCL Technologies Limited will not be liable for any losses and damages in connection with the use of this code.
