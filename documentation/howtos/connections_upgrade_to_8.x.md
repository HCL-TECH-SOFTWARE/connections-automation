# Upgrading HCL Connections using Ansible automation

This automation is used to upgrade HCL Connections and Component Pack upgrades to v8.0x.

For this example, we will show:

* How to use the ansible automation to upgrade to HCL Connection 8.0x. This includes migrating data from MongoDB v3 to MongoDB v5 and ElasticSearch7 to OpenSearch manually if upgrading from Component Pack v7.

* What is the logic behind it.

NOTE: If this is the very first document you are landing on, please ensure that you read already our [README.md](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/README.md) and our [Quick Start Guide](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/QUICKSTART.md), specially if you never used Ansible and/or this automation before.

Before you proceed, let's analyse very quickly few what is important points.

### Setting up your inventory file

Please note that if needed user can overwrite defaults using [files in this folder ](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx8/db2/). We will explain here what it is doing:

* We have our HCL Connections Wizards and HCL Connections installer living in a folder called Connections8, so we are setting the right paths here [#1](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx8/db2/group_vars/all.yml#L40) and [#2](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx8/db2/group_vars/all.yml#L47)
* Check default supported version of IBM WebSphere [here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/VARIABLES.md#was_fp_version:~:text=WebSphere%20Base%20version-,was_fp_version).

#### Note: There is a known issue in IBM WebSphere 8.5.5 Fixpack 22 where retrieve from port using TLS v1.3 or v1.2 ciphers may not work. See [PH49497: RETRIEVE FROM PORT NOT HONORING SSL PROTOCOL](https://www.ibm.com/support/pages/apar/PH49497) for details. Contact HCL Connections support or IBM WebSphere support for the iFix 8.5.5.22-WS-WAS-IFPH49497.zip.
* As connections kit names are different for different versions, so we can explicitly specify [Connections install kit name](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx8/db2/group_vars/all.yml#L50) and [Connections Wizard package name](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx8/db2/group_vars/all.yml#L51). Check out default values here [#1](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/VARIABLES.md#:~:text=location%20to%20download-,cnx_package) and [#2](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/VARIABLES.md#:~:text=connections_wizards_package_name)
* Desired version of docker, helm, kubernetes can be set using variables docker_version, kubernetes_version, helm_version respectively set in the [inventory file](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx8/db2/group_vars/all.yml). [Click here](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/VARIABLES.md) to see more details and supported default versions of these software.

### Choosing operating system version

Use CentOS 7 Or RHEL 8.6 (the later CentOS 7 Or RHEL 8.6 the better). For this scenario, let's say you are using CentOS 7.9. Be always sure, as whenever installing any of the components mentioned here, using automation or manually, to configure machine properly and just to be on the safe side run yum update before you start.


## Upgrading HCL Connections to v8

### Prerequisite

At this step we assume that we have a running Connections 7 or above with the Component Pack installed.

### Setting up your inventory file

You already got the idea that all there is with the installation/upgrade is handled by manipulating variables in your inventory files.
For this example, we will reference [this example inventory folder](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/environments/examples/cnx8/db2).

If you make a simple diff between [this file](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx8/db2/group_vars/all.yml) and [this file](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx7/db2/group_vars/all.yml) you will see that now:

* We are pointing to a folders with Connections 8 and WAS ND to the [default supported version](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/VARIABLES.md#was_fp_version:~:text=WebSphere%20Base%20version-,was_fp_version).
* We are not overwriting any package and file name, as by default Ansible will assume that, in this moment, default version is 8, and package names for version 8 are being used.

### Running the upgrade

Run below playbook. This will add/remove new IHS configurations if any:

```
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/third_party/setup-webspherend.yml
```

And as a next step, let's upgrade HCL Connections to v8:

```
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/hcl/setup-connections-only.yml
```

## Upgrading HCL Component Pack to v8

Run below playbooks to upgrade and configure nginx and haproxy for the HCL Connections v8

```
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/third_party/setup-nginx.yml
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/third_party/setup-haproxy.yml
```

Run below playbook to configure NFS. This playbook will also create and configure OpenSearch and MongoDB 5 folders and setup PV export folders permission for v8.

```
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/third_party/setup-nfs.yml
```

Run below playbook to install containerd (container runtime).

```
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/third_party/setup-containerd.yml
```

To deploy Component Pack 8, we use HCL Software’s Harbor container registry. Also we strongly recommend that you [install container runtime](https://opensource.hcltechsw.com/connections-doc/admin/install/upgrade_considerations.html#section_sqh_ktx_bvb) (containerd installation playbook is already mentioned in the previous step), Follow the steps in [migrating from Docker to containerd](https://kubernetes.io/docs/tasks/administer-cluster/migrating-from-dockershim/change-runtime-containerd/), [upgrade helm to version 3.7.2](https://opensource.hcltechsw.com/connections-doc/admin/install/upgrade_considerations.html#section_bqv_2vx_bvb) and [upgrade kubernetes](https://opensource.hcltechsw.com/connections-doc/admin/install/upgrade_considerations.html#section_avm_v5x_bvb) before moving to Component pack 8.


### Preparation if upgrading from Component Pack v7
If upgrading from Component Pack v7, for v8 we need to upgrade MongoDB from v3 to v5 and OpenSearch replaces ElasticSearch7. So we need to backup data. This is a manual step. Please refer below links:

[Backup mongo3 data](https://opensource.hcltechsw.com/connections-doc/admin/install/cp_install_services_tasks.html#backup_mongo3)

[Backup ElasticSearch 7 data](https://opensource.hcltechsw.com/connections-doc/admin/install/cp_install_services_tasks.html#backup_es7)

Also, remove ingresses before upgrading from Component Pack v7, otherwise the infrastructure will fail:

```
kubectl delete ingress -n connections $(kubectl get ingress -n connections | awk '{print $1}' | grep -vE "NAME")
```

### Preparation if upgrading to Kubernetes 1.25
<details>
  <summary> Click to expand if you are upgrading Kubernetes to v1.25 </summary>

>As PodSecurityPolicy was deprecated in Kubernetes v1.21, and removed from Kubernetes in v1.25, the following charts should be uninstalled before upgrading to Kubernetes v1.25.
>
>```
>k8s-psp
>infrastructure
>opensearch-master
>opensearch-data
>opensearch-client
>kudos-boards-cp
>```
>
>First, check if the chart is already deployed:
>```
>helm ls --namespace connections | grep <chart name> | grep -i DEPLOYED
>```
>
>If found, delete the chart using below command:
>```
>helm uninstall <chart name> --namespace connections
>```
>For more details see [PodSecurityPolicy is removed](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.25.md#podsecuritypolicy-is-removed-pod-security-admission-graduates-to-stable).
>
>Ensure you reconfigure NFS by running playbook playbooks/third_party/setup-nfs.yml.
</details>

Follow [Kubernetes official document](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/) on how to upgrade kubernetes version. Kubernetes can be upgraded using below playbook.  Do NOT skip MINOR versions when upgrading Kubernetes.   Add 'upgrade_version' variable in the [inventory file](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx8/db2/group_vars/all.yml) to the target version:

```
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/third_party/kubernetes/upgrade-kubernetes.yml
```

### Running the Component Pack playbook
Access to the HCL Harbor registry is needed to install the Component Pack. You can provide the Harbor credentials (and Quay credentials if enabling Huddo Boards) as environment variables.

```
set HARBOR_USERNAME=<<harbor username>>
set HARBOR_USERNAME=<<Harbor password>>

set QUAY_USERNAME=<<quay username>>
set QUAY_SECRET=<<quay password>>
```

Add Harbor variables to the [inventory file](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/environments/examples/cnx8/db2/group_vars/all.yml#L85-L86)

Then execute

```
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/setup-component-pack-complete-harbor.yml
```

Follow the steps in [Installing MongoDB 5 for Component Pack](https://opensource.hcltechsw.com/connections-doc/admin/install/installing_mongodb_5_for_component_pack_8.html) till the point the image is imported into containerd. This is a manual step.

### Data migration if upgrading from Component Pack v7
If upgrading from Component Pack v7, to migrate data from MongoDB 3 to MongoDB 5, [perform these steps](https://opensource.hcltechsw.com/connections-doc/admin/install/migrating_data_mongodb_v3_v5.html). This is a manual step.

To migrate data from Elasticsearch 7 to OpenSearch, [perform these steps](https://opensource.hcltechsw.com/connections-doc/admin/install/cp_migrate_data_from_es7_to_opensearch.html). This is a manual step.

After this we will delete all the pods using below command on the kubernetes master node. This command will restart all the CP pods.

```
kubectl delete pods -n connections $(kubectl get pods -n connections | awk '{print $1}' | grep -vE "NAME|bootstrap")
```

### Running post install playbook
Now run post installation tasks.  Once your Component Pack installation is done, run this playbook to set up some post installation:

```
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/hcl/connections-post-install.yml
```

Once this is done, log in to your HCL Connections 8 installation, just to confirm that all is fine.


## Final words

As you probably already noticed, same playbooks can be used for both installations and upgrades, and it is designed that way. Worst case scenario that can happen is that some services will be restarted while playbooks are ensuring that everything is the way it is described.

And this gives you already the idea - it is very easy, this way, to deploy if needed new build every day, or even multiple times per day, by ensuring that you are simply having a new package uploaded to the right folder, without even changing anything in Ansible itself.
