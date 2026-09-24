# CNX CEC Role Variables

This document lists user-configurable variables for the CNX CEC roles. Variables not listed here are internal to role logic and should not be overridden. Only set a variable in `group_vars/all.yml` when you need to override its default.

---

## 1. Registry Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| cnx_cec_docker_registry_url | `hclcr.io` | Harbor OCI registry URL for container images. |
| cnx_cec_docker_registry_username | (value of `docker_registry_username`) | Username for Docker registry authentication. |
| cnx_cec_docker_registry_password | (value of `docker_registry_password`) | Password for Docker registry authentication. |
| cnx_cec_image_pull_secret_name | `cnx-cec-docker-image-pull-secret` | Name of the Kubernetes image pull secret. |
| cnx_cec_docker_registry_email | `changeme@example.com` | Email for Docker registry secret. |

---

## 2. Container Images

| Variable | Default | Description |
|----------|---------|-------------|
| cnx_cec_web_engine_image_tag | `''` (chart default) | Tag for the CNX CEC web engine image. Leave empty to use Helm chart defaults. |
| cnx_cec_web_engine_image_path | `''` (chart default) | Image path for the web engine container. |
| cnx_cec_logging_image_tag | `''` (chart default) | Tag for the logging sidecar image. |
| cnx_cec_logging_image_path | `''` (chart default) | Image path for the logging sidecar container. |

---

## 3. Helm Chart Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| cnx_cec_helm_repository | `{{ cnx_cec_docker_registry_url }}/cnx-cec` | Helm chart repository URL. |
| cnx_cec_helm_chart_name | `hcl-cnx-cec-deployment` | Name of the Helm chart to deploy. |
| cnx_cec_helm_repo_username | (value of registry username) | Username for Helm repo authentication. |
| cnx_cec_helm_repo_password | (value of registry password) | Password for Helm repo authentication. |

---

## 4. Web Engine Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| cnx_cec_web_engine_release_name | `cnx-cec` | Helm release name. |
| cnx_cec_web_engine_context_root | `wps` | Context root for the web engine. |
| cnx_cec_web_engine_home_path | `portal` | Home path for the web engine. |
| cnx_cec_web_engine_personalized_home_path | `myportal` | Personalized home path. |
| cnx_cec_web_engine_admin_user | (derived from LDAP config) | Admin user for the web engine. |
| cnx_cec_web_engine_admin_password | (derived from LDAP config) | Admin password for the web engine. |
| cnx_cec_web_engine_connections_admin_user_dn | `uid=<connections_admin>,<ldap_realm>` | Connections admin user DN used for CEC integration. |
| cnx_cec_web_engine_service_port_https | `9443` | HTTPS port for the web engine service. |
| cnx_cec_web_engine_service_port_http | `9080` | HTTP port for the web engine service. |
| cnx_cec_web_engine_volume_name | `rwovol-web-engine-customization` | Name for the customization volume. |
| cnx_cec_web_engine_volume_storage_class | `manual` | Storage class for volumes. |
| cnx_cec_web_engine_volume_storage_capacity | `100Gi` | Storage capacity for volumes. |
| cnx_cec_web_engine_volume_access_mode | `ReadWriteOnce` | Access mode for volumes. |
| cnx_cec_web_engine_volume_reclaim_policy | `Retain` | Reclaim policy for volumes. |

---

## 5. LDAP Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| cnx_cec_web_engine_ldap_type | `other` | Type of LDAP to use: `none`, `dx` (DX openLDAP), or `other` (custom LDAP). |
| cnx_cec_web_engine_basic_registry_enabled | `true` | Enable the default basic registry. Set to `false` when your LDAP has duplicate principals. |
| cnx_cec_web_engine_ldap_server | (first LDAP server in group) | LDAP server hostname. Only used when `ldap_type` ≠ `none`. |
| cnx_cec_web_engine_ldap_bind_user | `cn=Admin,dc=cnx,dc=pnp-hcl,dc=com` | LDAP bind user DN. |
| cnx_cec_web_engine_ldap_bind_pass | `password` | LDAP bind password. |
| cnx_cec_web_engine_ldap_realm | `dc=cnx,dc=pnp-hcl,dc=com` | LDAP realm (base DN). |
| cnx_cec_web_engine_ldap_login_properties | `uid;mail` | LDAP login properties. |
| cnx_cec_web_engine_ldap_server_port | `389` | LDAP server port. |
| cnx_cec_web_engine_ldap_realm_name | `defaultWIMFileBasedRealm` | LDAP realm name. |
| cnx_cec_web_engine_ldap_search_filter | `(&(uid=%v)(objectclass=inetOrgPerson))` | LDAP user search filter. |
| cnx_cec_web_engine_ldap_group_filter | `(&(cn=%v)(objectclass=groupOfUniqueNames))` | LDAP group filter. |
| cnx_cec_web_engine_ldap_map_guid | `uid` | LDAP GUID mapping attribute. |
| cnx_cec_web_engine_ldap_map_uid | `cn` | LDAP UID mapping attribute. |

---

## 6. Database Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| cnx_cec_web_engine_use_external_db | `true` | Use external DB2 database for web engine. Set to `false` to use embedded Derby. |
| db_username | `lcuser` | Database username. |
| db_password | `password` | Database password. |
| db_hostname | (first DB server in group) | Database hostname. |
| db_port | `50000` (`50001` on SLES) | Database port. |
| db_group | `db2group` | Database group. |
| cnx_cec_web_engine_db2_max_active_databases | `256` | Max active databases for DB2 tuning in CEC DB setup. |
| cnx_cec_web_engine_drop_db_tables_on_startup | `false` | Drop DB tables on startup. Set to `true` for clean-slate testing environments. |

---

## 7. SSO Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| cnx_cec_web_engine_enable_sso | `true` when `ldap_type` ≠ `none`, else `false` | Enable SSO between Connections and CNX CEC using LTPA. Automatically enabled when LDAP is configured. |
| cnx_cec_web_engine_ltpa_secret_name | `cnx-cec-ltpa-secret` | LTPA secret name in Kubernetes. |

---

## 8. LTPA Key Export and Import

| Variable | Default | Description |
|----------|---------|-------------|
| ltpa_keys_location | `/tmp/<user>/cnx-cec/ltpa` | Base directory for exported LTPA key files. |
| ltpa_keys_file_name | `cnx-ltpa-<timestamp>.keys` | LTPA key filename. Generated uniquely per run. |
| ltpa_keys_password | `password` | Password for LTPA key export. |

---

## 9. Trust Store Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| trust_store_secret_name | `connections-trust-secret` | Trust store secret name in Kubernetes. |

---

**How to override:** Set any variable in `group_vars/all.yml`, `host_vars`, or with `-e` on the command line. Variables with role defaults (`cnx_cec_web_engine_use_external_db`, `cnx_cec_web_engine_enable_sso`, `cnx_cec_web_engine_drop_db_tables_on_startup`) only need to be set when overriding the default value.
