# Upgrading HCL Connections v8 CR using Ansible automation

> [!NOTE]
> Refer to the [Special Attention for WebSphere FP27 Installation/Upgrade](../QUICKSTART.md) before you begin the upgrade.

This automation is used to upgrade HCL Connections and Component Pack v8.0 to the latest CR.

For this example, we will show:

* How to use this Ansible automation to upgrade to the latest v8.0 CR from a prior CR running MongoDB v5 or above and OpenSearch.
* What is the logic behind it.

NOTE: If this is the very first document you are landing on, please ensure that you have read our [README.md](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/README.md) and [Quick Start Guide](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/QUICKSTART.md), especially if you are new to Ansible and/or this automation.

Before you proceed, let's analyse very quickly a few important points.

### Setting up your inventory file

If necessary, users can override the default settings by using our sample inventory [in this folder](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/environments/examples/cnx8/db2). Here is an explanation of what these files do:

* We have our HCL Connections Wizards and HCL Connections installers reside in a folder called Connections8, so we are setting the right paths in variables `connections_wizards_download_location`, `cnx_repository_url` and `cnx_fixes_repository_url` [here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx8/db2/group_vars/all.yml).
* We explicitly specify the Connections CR install version and file name in variables `cnx_fixes_version` and `cnx_fixes_files` [here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx8/db2/group_vars/all.yml).
* Check the default supported version of IBM WebSphere in the `was_fp_version` variable [here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/VARIABLES.md#websphere-variables).
* Desired version of Helm, containerd and Kubernetes can be set using variables `helm_version`, `containerd_version` and `kubernetes_version` respectively. For more details about the default supported versions of these software, click [here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/VARIABLES.md#component-pack-infra-variables).

### Choosing operating system version

Use AlmaLinux 9 or RHEL 9 is recommended. For this scenario, we will use AlmaLinux 9. Ensure that the machine is properly configured when installing any of the components mentioned in this document, whether using automation or manually. To be on the safe side, run `dnf update` before you start.

## Upgrading HCL Connections to the latest v8 CR

### Prerequisite

At this step we assume that we have a running Connections 8 with the latest Component Pack installed.

### Setting up your inventory file

You already got the idea that all there is with the installation/upgrade is handled by manipulating variables in your inventory files.
For this example, we will continue to use [this sample inventory folder](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/environments/examples/cnx8/db2).

You will see that now:

* We are pointing to the WebSphere install folder that aligns with the [default supported version](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/VARIABLES.md#websphere-variables).
* We are overriding the CR version and install kit file name in `cnx_fixes_version` and `cnx_fixes_files` to install the latest CR.

### Running the upgrade

Run below playbook. This will upgrade WebSphere to the default supported fixpack and add/remove new IHS configurations if any:

```
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/third_party/setup-webspherend.yml
```

And as a next step, let's upgrade HCL Connections to the latest CR:

```
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/hcl/setup-connections-only.yml
```

## Upgrading to the latest HCL Connections Component Pack

Run the playbooks below to upgrade and configure NGINX and HAProxy for the Component Pack

```
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/third_party/setup-nginx.yml
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/third_party/setup-haproxy.yml
```

Run the playbook below to configure NFS. This playbook will also create and configure the MongoDB 7 folders and setup PV export folders permissions.

```
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/third_party/setup-nfs.yml
```

Run the playbook below to upgrade containerd (container runtime).

```
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/third_party/setup-containerd.yml
```

To deploy the latest Component Pack, we use the HCL Harbor repository.  Before upgrading the Component Pack, we strongly recommend that you upgrade Kubernetes to the latest supported version as specified in variable `kubernetes_version` [here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/VARIABLES.md#component-pack-infra-variables).

### Upgrading Kubernetes

Follow the [official Kubernetes documentation](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/) on how to upgrade Kubernetes version. Kubernetes can be upgraded to the next minor version using below playbook.  Do NOT skip MINOR versions when upgrading Kubernetes.   For example, if you are upgrading from 1.29 -> 1.31, it needs to be upgraded from 1.29 -> 1.30 -> 1.31.
Add variable `upgrade_version` to the [inventory file](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx8/db2/group_vars/all.yml) set it to the target version and adjust to the next minor version before running the playbook each time:

```
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/third_party/kubernetes/upgrade-kubernetes.yml
```

### Preparation if upgrading from MongoDB 5

If upgrading from Connections v8 CR8 or below, MongoDB needs to be upgraded from v5 to v7.  Follow the steps in [Installing MongoDB 7 for Component Pack](https://opensource.hcltechsw.com/connections-doc/v8-cr9/admin/install/installing_mongodb_7_for_component_pack_8.html) till the point the image is imported into containerd and MongoDB5 is shut down.
In `all.yml`, set `mongo_image_tag` to the image tag defined when building the MongoDB 7 image to enable the infrastructure chart to use this image.

### Upgrading the Component Pack

Access to the HCL Harbor registry is needed to install the Component Pack. You can provide the Harbor credentials (and Quay credentials if enabling Huddo Boards) as environment variables.

```
export HARBOR_USERNAME=<<Harbor username>>
export HARBOR_SECRET=<<Harbor password>>

export QUAY_USERNAME=<<Quay username>>
export QUAY_SECRET=<<Quay password>>
```

Add Harbor variables `docker_registry_username`, `docker_registry_password` and Quay variables `huddoboards_registry_username` and `huddoboards_registry_password` if necessary as shown in the [inventory file](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx8/db2/group_vars/all.yml).

Then execute

```
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/hcl/harbor/setup-component-pack.yml
```

### Data migration if upgrading from MongoDB 5

If upgrading from Connections v8 CR8 or below, [follow this topic](https://opensource.hcltechsw.com/connections-doc/v8-cr9/admin/install/v8-cr8/admin/install/mongo7-migration-script.md) to migrate data from MongoDB 5 to MongoDB 7.

### Running post install playbook

Now run post installation tasks.  Once your Component Pack installation is done, run this playbook to set up some post installation:

```
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/hcl/connections-post-install.yml
```

Once this is done, log in to your HCL Connections 8 installation, just to confirm that all is fine.

### Thumbnail fix for Connections Docs after upgrade

Thumbnails may not be generated after Connections is upgraded.  If `com.ibm.connections.spi.events.EventHandlerInitException` exceptions are found in the WebSphere server log, follow the fix in the [FAQ](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/FAQ.md#docs-thumbnails-stop-working-after-upgrading-connections-how-to-fix-that).

## Final words

As you probably already noticed, same playbooks can be used for both fresh installations and upgrades, and it is designed that way.
