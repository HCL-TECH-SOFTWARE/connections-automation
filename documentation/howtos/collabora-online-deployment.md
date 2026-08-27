
# Collabora Online Deployment Guide (Ansible & Helm)

This guide explains how to deploy Collabora Online Enterprise Edition on HCL Connections using the provided Ansible automation. It covers deployment, post-deployment verification, and troubleshooting (including WebSocket support).

> **Note:** For general setup, prerequisites, and Ansible usage, see the [README](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/README.md) and [Quick Start Guide](https://github.com/HCL-TECH-SOFTWARE/connections-automation/blob/main/documentation/QUICKSTART.md).

---

## Prerequisites

- A running HCL Connections 8 CR15 environment with ingress controller installed.
- Access to the HCL Harbor registry for Collabora Online Enterprise Edition licensed images and charts.
- Inventory and `group_vars` files updated with your environment’s hostnames and credentials.

Set your Harbor credentials as environment variables before running the playbook:

```bash
export HARBOR_USERNAME=<your-harbor-username>
export HARBOR_SECRET=<your-harbor-password>
```

Alternatively, set `docker_registry_username` and `docker_registry_password` in your inventory or `group_vars`. If both are provided, the environment variables take precedence.

---

## 1. Configure Inventory

For this example, users can override the default settings by using our sample inventory [in this folder](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/environments/examples/cnx8/db2).

Update your `inventory.ini` and `group_vars/all.yml` to match your environment.

Key variables for the Collabora deployment (can be set in inventory, `group_vars`, or via `-e`):

| Variable Name              | Description                                                                                       | Default Value      |
|----------------------------|---------------------------------------------------------------------------------------------------|--------------------|
| `collabora_release_name`   | Helm release name for Collabora Online.                                                           | `collabora-online` |
| `collabora_namespace`      | Kubernetes namespace for Collabora Online.                                                        | `connections`      |
| `collabora_replica_count`  | Number of Collabora Online replicas.                                                              | `2`                |
| `lb_type`                  | Load balancer type. Accepted values: `clb`, `alb`. Empty means no LB-specific overrides applied.  | `''`               |
| `docker_registry_username` | Harbor username (alternative to `HARBOR_USERNAME`).                                               | _unset_            |
| `docker_registry_password` | Harbor password (alternative to `HARBOR_SECRET`).                                                 | _unset_            |

---

## 2. Install Collabora Online Enterprise Edition

Run the following playbook to deploy Collabora Online:

```bash
ansible-playbook -i environments/examples/cnx8/db2/inventory.ini playbooks/hcl/harbor/setup-collabora.yml
```

You can override any variable at runtime using the `-e` flag:

```bash
ansible-playbook -i <your-inventory> playbooks/hcl/harbor/setup-collabora.yml -e collabora_release_name=my-release
```

If using an AWS load balancer:

```bash
ansible-playbook -i <your-inventory> playbooks/hcl/harbor/setup-collabora.yml -e collabora_release_name=my-release -e "lb_type=alb"
```

---

## 2b. Deploying on OpenShift

OpenShift 4.x enforces Security Context Constraints (SCCs). By default every pod in a namespace is admitted under `restricted-v2`, which forbids the two things the Collabora umbrella chart needs out of the box:

- `cool-controller` hard-codes `runAsUser: 1001`, which is outside a project's assigned UID range.
- The `collabora-online` pods build a per-document sandbox (Linux user namespaces + `chroot`), which needs kernel capabilities that `restricted-v2` does not grant.

### One-time SCC bindings (cluster administrator)

Run these once per namespace, alongside the existing HCL Component Pack SCC bindings. `$ns` is the namespace Collabora is deployed into (default `connections`):

```bash
ns=connections

# Collabora Online — same shape as the existing bindings for mongodb7 / apisix / traefik
oc adm policy add-scc-to-user anyuid     system:serviceaccount:$ns:collabora-online-cool-controller
oc adm policy add-scc-to-user privileged system:serviceaccount:$ns:collabora-online
```

## 3. Post-Deployment: Verify and Test

### Check pods and services

```bash
kubectl -n <collabora_namespace> get pods,svc
```

All Collabora pods should be `Running` and `Ready`.

### Verify WOPI discovery endpoints

```bash
curl -kI https://<your-host>/hosting/discovery
```

### Access the Collabora Online dashboard

- Admin Dashboard: `https://<your-host>/browser/dist/admin/admin.html`
- Admin Cluster Overview: `https://<your-host>/browser/dist/admin/adminClusterOverview.html`


## 4. Troubleshooting

### WebSocket connection fails

Symptom in the browser console:

```
WebSocket connection to 'wss://<your-host>/cool/.../ws' failed:
WebSocket is closed before the connection is established.
```

## 6. Uninstall / Rollback

To remove the Collabora Online release:

```bash
helm -n <collabora_namespace> uninstall <collabora_release_name>
```


