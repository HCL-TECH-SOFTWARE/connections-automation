
# Installing HCL API Gateway with Ansible

This guide explains how to deploy and configure Apache APISIX and HCL API Gateway on HCL Connections Component Pack using the provided Ansible automation.

> **Note:** For general setup, prerequisites, and Ansible usage, see the [README](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/README.md) and [Quick Start Guide](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/QUICKSTART.md).

---

## Prerequisites

- A running HCL Connections 8 environment with Component Pack installed.
- Access to the HCL Harbor registry for API Gateway images.
- Inventory and group_vars files updated with your environment’s hostnames and credentials.

Set your Harbor credentials as environment variables before running the playbook:

```sh
export HARBOR_USERNAME=<your-harbor-username>
export HARBOR_SECRET=<your-harbor-password>
```

Alternatively, set `docker_registry_username` and `docker_registry_password` in your inventory or group_vars.

---

## 1. Configure Inventory

For this example, users can override the default settings by using our sample inventory [in this folder](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/environments/examples/cnx8/db2).

Update your `inventory.ini` and `group_vars/all.yml` to match your environment.

Key variables for APISIX deployment (can be set in inventory, group_vars, or via `-e`):

| Variable Name                | Description                              | Default Value           |
|------------------------------|------------------------------------------|-------------------------|
| apisix_release_name          | Helm release name for APISIX core        | apisix                  |
| apisix_namespace             | Kubernetes namespace for APISIX          | apisix                  |
| apisix_etcd_replicaset       | Number of etcd replicas                  | 3                       |
| hcl_api_gateway_release_name | Helm release name for HCL API Gateway    | hcl-api-gateway         |
| apisix_route_path            | API route path                           | /connections/api/v2     |

---

## 2. Install APISIX and HCL API Gateway

Run the following playbook to deploy both Apache APISIX and HCL API Gateway:

```sh
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/hcl/harbor/setup-deploy-apisix.yml
```

You can override any variable at runtime using the `-e` flag:

```sh
ansible-playbook -i <your-inventory> playbooks/hcl/harbor/setup-deploy-apisix.yml -e "apisix_namespace=my-namespace apisix_release_name=my-release"
```

---

## 3. Post-Deployment: Verify and Test

### Access Swagger UI

- Open: `https://<your-host>/connections/api/v2/explorer/`
- Use the **"Authorize"** button to authenticate and test endpoints.

### Test API Endpoints

- Expand an endpoint, click **"Try it out"**, fill parameters, and click **"Execute"**.
- Review the response, status code, headers, and body.

---
## 4. Uninstall APISIX and HCL API Gateway

To completely remove the HCL API Gateway deployment, including Helm releases, Kubernetes resources, PersistentVolumes, StorageClasses, and NFS data, run the following playbook:

```sh
ansible-playbook -i <your-inventory> playbooks/hcl/cleanup/cleanup-hcl-api-gateway.yml
```

### What Gets Cleaned Up

The uninstall playbook performs the following cleanup operations:

**Kubernetes Resources (on k8s_masters[0]):**
- Uninstalls HCL API Gateway Helm release (`hcl-api-gateway`)
- Uninstalls Core APISIX Helm release (`apisix`)
- Deletes APISIX secrets in the namespace
- Removes ETCD PersistentVolumes (based on replica count)
- Deletes APISIX StorageClass

**NFS Data (on nfs_servers):**
- Removes APISIX ETCD NFS directories (e.g., `/pv-connections/apisix-etcd-*`)
- Cleans up NFS export entries from `/etc/exports`
- Re-exports NFS filesystems

### Customization Options

You can override cleanup behavior using variables:

| Variable Name         | Description                           | Default Value    |
|-----------------------|---------------------------------------|------------------|
| apisix_namespace      | Kubernetes namespace to clean up      | apisix           |
| apisix_release_name   | Core APISIX Helm release name         | apisix           |
| hcl_api_gateway_release_name | HCL API Gateway release name   | hcl-api-gateway  |
| apisix_etcd_replicaset | Number of ETCD replicas to remove    | 3                |
| preserve_nfs_data     | Preserve NFS data (true/false)        | true             |
| persistentVolumePath  | Base path for NFS PVs                 | pv-connections   |

---