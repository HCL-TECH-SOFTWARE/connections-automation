# AWS ALB Migration Guide for HCL Connections 8.0

> **Note:** This guide uses `anotherdomain.net` as an example ALB domain to illustrate scenarios where your ALB is on a different domain than internal hosts. This is not mandatory—use your actual domain as needed.

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Architecture Overview](#2-architecture-overview)
3. [Infrastructure Components](#3-infrastructure-components)
4. [ALB Listener Rules Design](#4-alb-listener-rules-design)
5. [Ansible Automation](#5-ansible-automation)
6. [Verification & Testing](#6-verification--testing)
7. [Hostname Migration](#7-hostname-migration-cnx_application_ingress)

---

## 1. Executive Summary

This guide documents the migration of the HCL Connections 8.0 frontend load balancer from **Nginx** (on `web1.internal.example.com`) to an **AWS Application Load Balancer (ALB)** at `connections.anotherdomain.net`.

### Key Decisions

| Decision | Rationale |
|----------|-----------|
| ALB as frontend LB | Native AWS integration, ACM certificate management, no server to maintain |
| Simplified routing | Mirrors the proven Nginx pattern |
| Kept HAProxy for K8s NodePort LB | Still needed by IHS to reach K8s services on `web1` |

---

## 2. Architecture Overview

### High-Level Topology

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                 INTERNET                                    │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     │
                    ┌────────────────▼─────────────────┐
                    │         AWS ALB (:443)            │
                    │  connections.anotherdomain.net    │
                    │  TLS: ACM Certificate             │
                    │  Policy: TLS13-1-2-2021           │
                    │  Idle Timeout: 300s                │
                    └──┬──────────┬──────────┬────────┬┘
                       │          │          │        │
          P2-P4        │ Default  │   P5     │        │ P6-P7
          Customizer   │ All else │ Grafana  │        │ Collabora WS
                       │          │          │        │
              ┌────────▼───┐ ┌────▼──────┐ ┌▼──────────┐ ┌───▼────────────┐
              │ HAProxy    │ │ IHS 9     │ │ HAProxy    │ │ HAProxy        │
              │ :30301     │ │ :443      │ │ :31111     │ │ :32443         │
              │ (mw-proxy) │ │ (WAS+CP)  │ │ (grafana)  │ │ (collabora)   │
              └─────┬──────┘ └──┬─────┬──┘ └─────┬─────┘ └───────┬───────┘
                    │           │     │           │               │
                    ▼           │     │           ▼               ▼
              ┌───────────┐    │     │     ┌───────────┐  ┌───────────────┐
              │ K8s Pod   │    │     │     │ K8s Pod   │  │ K8s Traefik   │
              │ mw-proxy  │    │     │     │ Grafana   │  │ → Collabora   │
              │ :30301    │    │     │     │ :31111    │  │   Online Pod  │
              └───────────┘    │     │     └───────────┘  └───────────────┘
                               │     │
               ┌───────────────┘     └───────────────┐
               │ WAS Plugin match                    │ ProxyPass match
               │ (/homepage, /files, etc.)           │ (/social, /cnxadmin,
               ▼                                     │  /wps, /BluePrintModule, etc.)
      ┌──────────────────┐                           ▼
      │                  │                 ┌───────────────────┐
      │     WebSphere    │                 │  HAProxy :32443   │
      │     App Server   │                 │  → K8s Traefik    │
      │                  │                 │  → CP Pods        │
      │                  │                 │  → CNX CEC  │
      └────────┬─────────┘                 └───────────────────┘
               │ Login only
               ▼
      ┌──────────────────┐
      │  OpenLDAP :636   │
      │  (LDAPS)         │
      └──────────────────┘
```

### Network Diagram with IPs and Ports

```
┌────────────────────────────────────────────────────────────────────────────┐
│ AWS ALB (internet-facing)                                                  │
│ DNS: connections.anotherdomain.net                                         │
│ ACM Cert: arn:aws:acm:us-east-1:**********:certificate/******-...         │
│ Subnets: subnet-****, subnet-********                                     │
│ VPC: vpc-**** (us-east-2)                                                 │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│  Target Groups:                                                            │
│  ┌─────────────────────────┬──────────────────┬───────────────────────┐    │
│  │ TG: {name}-mw-proxy     │ Protocol: HTTP   │ Port: 30301          │    │
│  │ Target: web1            │ Health: GET /    │ Codes: 200,301       │    │
│  ├─────────────────────────┼──────────────────┼───────────────────────┤    │
│  │ TG: {name}-grafana      │ Protocol: HTTP   │ Port: 31111          │    │
│  │ Target: web1            │ Health: /grafana/│ Codes: 200,302       │    │
│  ├─────────────────────────┼──────────────────┼───────────────────────┤    │
│  │ TG: {name}-collabora    │ Protocol: HTTPS  │ Port: 32443          │    │
│  │ Target: web1            │ Health: GET /    │ Codes: 200,302       │    │
│  ├─────────────────────────┼──────────────────┼───────────────────────┤    │
│  │ TG: {name}-connections  │ Protocol: HTTPS  │ Port: 443            │    │
│  │ Target: connections1    │ Health: GET /    │ Codes: 200,301,302   │    │
│  └─────────────────────────┴──────────────────┴───────────────────────┘    │
│                                                                            │
│  web1.internal.example.com (HAProxy)                                       │
│  ├── :30301  → K8s NodePort → mw-proxy Pod (from ALB P2-P4)               │
│  ├── :31111  → K8s NodePort → Grafana Pod (from ALB P5)                   │
│  ├── :32443  → K8s NodePort → Traefik Ingress (from IHS + ALB P6-P7)     │
│  ├── :32080  → K8s NodePort → Traefik Ingress HTTP                        │
│  ├── :30099  → K8s NodePort → OpenSearch                                  │
│  └── :30379  → K8s NodePort → Valkey (Redis replacement)                  │
│                                                                            │
│  connections1.internal.example.com (IHS + WAS)                             │
│  ├── :443   → IHS VirtualHost (SSL)                                       │
│  │           ├── WAS Plugin routes → WAS AppSrv01 :9080                   │
│  │           └── ProxyPass routes  → HAProxy :32443 (CP + CEC paths)      │
│  └── :9080  → WAS HTTP Transport                                          │
│                                                                            │
│  cp1.internal.example.com (K8s Master + Worker)                            │
│  ├── :6443  → Kubernetes API Server                                       │
│  ├── :32443 → Traefik HTTPS (NodePort)                                    │
│  ├── :30301 → mw-proxy (NodePort)                                         │
│  └── :31111 → Grafana (NodePort)                                          │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Infrastructure Components

| Component | Host | Role |
|-----------|------|------|
| **AWS ALB** | `connections.anotherdomain.net` | Internet-facing L7 load balancer, TLS termination |
| **HAProxy** | `web1.internal.example.com` | L4 TCP proxy to K8s NodePorts |
| **IBM HTTP Server** | `connections1.internal.example.com` | Web tier, WAS plugin host, CP reverse proxy |
| **WebSphere ND** | `connections1.internal.example.com` | Application server (Connections EARs) |
| **Kubernetes** | `cp1.internal.example.com` | Component Pack (single-node master+worker) |
| **Traefik** | K8s Pod (NodePort 32443/32080) | K8s Ingress Controller with middleware CRDs |
| **OpenLDAP** | LDAP server (port 636 LDAPS) | Authentication directory |
| **DB2** | DB2 server | Connections databases |
| **OpenSearch** | K8s StatefulSet (NodePort 30099) | Search indexing and retrieval |
| **MongoDB** | K8s StatefulSet (mongo7) | Orient-Me data, appregistry, userprefs |

### K8s Services & NodePorts

| Service | NodePort | Protocol | Backend Pods |
|---------|----------|----------|--------------|
| `cnx-ingress-traefik` | 32080 (HTTP), 32443 (HTTPS) | TCP | Traefik ingress controller |
| `mw-proxy` | 30301 (HTTP), 30443 (HTTPS) | TCP | Customizer/mw-proxy |
| `grafana` | 31111 | HTTP | Grafana dashboard |
| `opensearch-cluster-master` | 30099 | HTTPS | OpenSearch cluster |
| `haproxy-valkey` | 30379 | TCP | Valkey (cache) |

### K8s Ingress Resources

| Ingress Name | Host Pattern | Paths | Traefik Middlewares |
|---|---|---|---|
| `cnx-ingress-orient-me` | `*.internal.example.com`, `*.anotherdomain.net` | `/social`, `/itm`, `/community_suggestions/...` | None |
| `cnx-ingress-appreg-client` | same | `/appreg` | `strip-appreg` (replacePathRegex) |
| `cnx-ingress-appreg-service` | same | `/appregistry` | None |
| `cnx-ingress-admin-portal` | same | `/cnxadmin` | None |
| `cnx-ingress-tailored-exp` | same | `/te-creation-wizard`, `/comm-template` | `buffering-comm-template`, `strip-comm-template` |
| `cnx-ingress-msteams` | same | `/teams-share-service`, `/teams-share-ui`, `/teams-tab`, etc. | None |
| `cnx-ingress-jsonapi` | same | `/jsonapi` | None |
| `connections-outlook-desktop-addin-ingress` | same | `/outlook-addin` | `connections-outlook-desktop-addin-ingress-strip` |
| `cnx-ingress-web-engine` | same | `/wps`, `/BluePrintModule` | None (uses `ServersTransport` CRD for backend HTTPS) |
| `cnx-ingress-web-engine-blue-print` | same | `/BluePrintModule` | None |

### Traefik Middleware CRDs

| Middleware Name | Type | Spec |
|---|---|---|
| `buffering-comm-template` | Buffering | `maxRequestBodyBytes: 20971520, memRequestBodyBytes: 20971520` |
| `strip-comm-template` | ReplacePathRegex | `^/comm-template(.*)` → `$1` |
| `strip-appreg` | ReplacePathRegex | `^/appreg(.*)` → `$1` |
| `connections-outlook-desktop-addin-ingress-strip` | ReplacePathRegex | `^/outlook-addin/?(.*)` → `/$1` |

---

## 4. ALB Listener Rules Design

### Final Rules (7 priorities + default)

| Priority | Condition | Action | Target Group | Port |
|----------|-----------|--------|-------------|------|
| **P1** | `/robots.txt` | Fixed response: `User-agent: *\nDisallow: /\n` | — | — |
| **P2** | `/files/customizer*`, `/files/app*`, `/communities/service/html*`, `/forums/html*`, `/search/web*` | Forward | `{name}-mw-proxy` | 30301 |
| **P3** | `/homepage/web*`, `/social/home*`, `/mycontacts*`, `/wikis/home*`, `/blogs*` | Forward | `{name}-mw-proxy` | 30301 |
| **P4** | `/news*`, `/activities/service/html*`, `/profiles/html*`, `/viewer*` | Forward | `{name}-mw-proxy` | 30301 |
| **P5** | `/grafana*` | Forward | `{name}-grafana` | 31111 |
| **P6** | `/cool/adminws`, `/cool/ws`, `/cool/*/ws`, `/controller/adminws`, `/controller/ws` | Forward | `{name}-collabora` | 32443/32080 |
| **P7** | `/controller/*/ws` | Forward | `{name}-collabora` | 32443/32080 |
| **Default** | Everything else (incl. `/browser/*`, `/hosting/*`, non-WS `/cool/*`, `/wps*`, `/BluePrintModule*`) | Forward | `{name}-connections` | 443 (HTTPS) |

> **Note**: P2-P4 are split into 3 rules because AWS ALB limits each rule to **5 condition values** maximum. The 14 Customizer paths require 3 rules.
>
> **Note**: P6-P7 are split into 2 rules for the same reason (6 WebSocket patterns total). AWS ALB `path-pattern` uses glob wildcards (`*` matches any characters including `/`), not regex. The nginx rule `^/(cool|controller)/(adminws|ws|.+/ws)$` is approximated as 6 glob patterns.

### Why Only WebSocket Paths Go to HAProxy (P6-P7)

Collabora Online serves two categories of traffic:

| Path Category | Examples | Handling |
|---|---|---|
| **WebSocket** (upgrade) | `/cool/{docid}/ws`, `/cool/adminws`, `/controller/ws` | P6-P7 → HAProxy:32443 → Traefik → collabora-online pod |
| **HTTP** (static/discovery) | `/browser/*`, `/hosting/*`, `/cool/hosting/discovery` | Default → IHS → ProxyPass → HAProxy:32443 → Traefik |

Routing all Collabora HTTP paths directly through the ALB (as in the previous P6 rule) bypassed IHS path rewrites. Sending only the WebSocket upgrade paths via P6-P7 ensures HTTP paths continue to benefit from IHS `ProxyPass` and `ProxyPassReverse` handling.

---

## 5. Ansible Automation

### Role Location

```
roles/third_party/aws-alb/
├── configure-alb/
│   ├── tasks/
│   │   └── Create-AWS-ALB.yml     # Main task file
│   └── vars/
│       └── main.yml               # Variables with defaults
├── cnx_instanceids/               # Gathers IHS/WAS EC2 instance IDs
├── k8s_instanceids/               # Gathers HAProxy EC2 instance IDs
└── migrate-hostname/              # Post-ALB hostname migration
    ├── tasks/main.yml
    └── vars/main.yml
```

### Variables Reference

#### ALB Configuration (`configure-alb/vars/main.yml`)

| Variable | Default | Description |
|----------|---------|-------------|
| `vpcid` | — | AWS VPC ID |
| `subnetid` | — | ALB subnet IDs (list, must span 2+ AZs) |
| `certificatearn` | — | ACM TLS certificate ARN for ALB listener |
| `hostedzone` | — | Route53 hosted zone for DNS record |
| `region` | `us-east-2` | AWS region |
| `idle_timeout` | `300` | ALB idle timeout (seconds) |
| `ssl_policy` | `ELBSecurityPolicy-TLS13-1-2-2021-06` | TLS policy (1.2 + 1.3) |
| `cp_tls_enable` | `false` (inherits `ingress_nginx_tls_enable`) | When `true`, mw-proxy and Collabora TGs use HTTPS ports |
| `mw_proxy_port` | `30301` | mw-proxy HTTP NodePort |
| `mw_proxy_port_https` | `30443` | mw-proxy HTTPS NodePort (used when `cp_tls_enable: true`) |
| `controller_https_node_port` | `32443` | Traefik HTTPS NodePort (Collabora TG port when TLS enabled) |
| `controller_http_node_port` | `32080` | Traefik HTTP NodePort (Collabora TG port when TLS disabled) |
| `sg_frontend_lb` | — | Security group ID for HAProxy instance |
| `sg_ihs_server` | — | Security group ID for IHS instance |
| `alb_name` | *(auto-derived from CNX instance Name tag)* | Override ALB name prefix |

#### Inventory (`group_vars/all.yml`)

| Variable | Description |
|----------|-------------|
| `cnx_application_ingress` | Public-facing FQDN (ALB hostname) |
| `cnx_component_pack_ingress` | Internal HAProxy FQDN |
| `nginx_custom_cert_sans` | Comma-separated SANs for HAProxy self-signed cert |
| `lb_type` | Set to `alb` for ALB deployments |
| `cp_tls_enable` | Enable TLS on K8s ingress |
| `frontend_fqdn` | Derived from `cnx_application_ingress` |
| `load_balancer_dns` | Derived from `k8s_load_balancers` group |

#### Hostname Migration (`migrate-hostname/vars/main.yml`)

| Variable | Default | Description |
|----------|---------|-------------|
| `profile_name` | `Dmgr01` | WAS DMGR profile name |
| `was_cellname` | `ConnectionsCell` | WAS cell name |
| `was_install_location` | `/opt/IBM/WebSphere/AppServer` | WAS install path |

### Resources Created by the Playbook

1. **Security Group**: `{name}-app-alb-sg` (allows HTTP/HTTPS from 0.0.0.0/0)
2. **Target Groups**: `{name}-mw-proxy`, `{name}-grafana`, `{name}-collabora`, `{name}-connections`
3. **ALB**: `{name}-app-alb` (internet-facing, 2 subnets)
4. **Listener Rules**: P1-P7 + default (as documented above)
5. **Route53 A Record**: ALIAS to ALB DNS name
6. **Security Group Rules**: ALB → HAProxy (30301, 31111, 32443), ALB → IHS (443)

### Running the Playbook

```bash
# Ensure you have the necessary AWS permissions or an IAM role configured on the controller

# Run ALB creation
ansible-playbook -i environments/<env>/inventory.ini \
  playbooks/third_party/aws-alb/setup-app-load-balancer.yml
```

---

## 6. Verification & Testing

### Post-Migration Checklist

| # | Test | Command | Expected |
|---|------|---------|----------|
| 1 | ALB responds | `curl -kI https://connections.anotherdomain.net/` | 302 → `/homepage` |
| 2 | WAS login | `curl -kI https://connections.anotherdomain.net/homepage` | 302 → `/homepage/login` |
| 3 | Customizer | `curl -kI https://connections.anotherdomain.net/homepage/web/` | 200 (via mw-proxy) |
| 4 | Orient-Me | `curl -kI https://connections.anotherdomain.net/social` | 200 (via IHS→Traefik) |
| 5 | Admin Portal | `curl -kI https://connections.anotherdomain.net/cnxadmin/` | 200 (SPA loads) |
| 6 | App Registry | `curl -kI https://connections.anotherdomain.net/appreg/` | 302 → login |
| 7 | Outlook Add-in | `curl -kI https://connections.anotherdomain.net/outlook-addin` | 200 |
| 8 | Grafana | `curl -kI https://connections.anotherdomain.net/grafana/` | 302 → grafana login |
| 9 | Robots.txt | `curl -k https://connections.anotherdomain.net/robots.txt` | `User-agent: *\nDisallow: /` |
| 10 | comm-template API | `curl -kI https://connections.anotherdomain.net/comm-template/isTemplateAdmin` | 302 → login (NOT 404) |
| 11 | CEC Web Engine | `curl -kI https://connections.anotherdomain.net/wps/portal` | 200 or 302 (via IHS→Traefik→CNX CEC) |

---

## 7. Hostname Migration (cnx_application_ingress)

After creating the ALB, you need to migrate the Connections application from the old internal hostname (e.g. `web1.example.com`) to the new ALB hostname (e.g. `connections.anotherdomain.net`).

### What Changes

| Area | Before | After |
|------|--------|-------|
| `cnx_application_ingress` | `web1.example.com` | `connections.anotherdomain.net` |
| `nginx_custom_cert_sans` | `*.internal.example.com,*.example.com` | `*.internal.example.com,*.example.com,*.anotherdomain.net` |
| WAS `dynamicHosts` | `https://web1.example.com` | `https://connections.anotherdomain.net` |
| WAS SSO domain | `.example.com` | `.example.com;.anotherdomain.net` |
| OAuth redirect URIs | `web1.example.com` in `connections-outlook-desktop`, `kudosboards` | `connections.anotherdomain.net` |
| TinyEditors `allowed-origins` | `web1.example.com` in `application.conf` | `connections.anotherdomain.net` |
| Huddo Boards Customizer ext | `web1.example.com` in `settings.js` | `connections.anotherdomain.net` |
| K8s `connections-env` `ic.host` | `web1.example.com` | `connections.anotherdomain.net` |
| K8s Ingress `host:` rules | `web1.example.com` | `connections.anotherdomain.net` |
| HAProxy self-signed cert SANs | `*.example.com` | `*.example.com,*.anotherdomain.net` |
| CNX CEC | `web1.example.com` | `connections.anotherdomain.net` |

### Steps

1. Update `cnx_application_ingress` and `nginx_custom_cert_sans` in `group_vars/all.yml`
2. Run the migration playbook, passing the **old hostname** via extra-vars:

   Access to the HCL Harbor registry is needed to migrate NGINX to ALB as it Re-deploy few Component Pack Helm charts. You can provide the Harbor credentials (and Quay credentials if enabling Huddo Boards) as environment variables.

   ```bash
   export HARBOR_USERNAME=<your-harbor-username>
   export HARBOR_SECRET=<your-harbor-password>

   export QUAY_USERNAME=<your-quay-username>
   export QUAY_SECRET=<your-quay-password>
   ```

   Then add the Harbor variables to your inventory's `group_vars/all.yml`:

   ```yaml
   component_pack_helm_repository:                  https://hclcr.io/chartrepo/cnx
   docker_registry_url:                             hclcr.io/cnx
   docker_registry_username:                        "{{ lookup('env','HARBOR_USERNAME') }}"
   docker_registry_password:                        "{{ lookup('env','HARBOR_SECRET') }}"
   ```

   Then execute:

   ```bash
   ansible-playbook -i environments/<env>/inventory.ini \
     playbooks/third_party/aws-alb/migrate-nginx-to-alb.yml \
     -e cnx_application_ingress_old=web1.example.com
   ```

> **Note:** `cnx_application_ingress_old` is required for OAuth redirect URI, TinyEditors, and Huddo Boards Customizer updates. If omitted, those steps emit a warning and are skipped.

### What the Playbook Does

| Step | Hosts | Action |
|------|-------|--------|
| 0 | `k8s_load_balancers` | Stop and disable Nginx (replaced by HAProxy + ALB) |
| 1 | `k8s_load_balancers` | Regenerate HAProxy self-signed cert with updated SANs, restart HAProxy |
| 2–4 | `dmgr` | Update `LotusConnections-config.xml` `dynamicHosts`, WAS SSO domains, WAS trust store |
| 5 | `dmgr` | Update OAuth `redirect_uri` for `connections-outlook-desktop` and `kudosboards` |
| 6 | `dmgr` | Update TinyEditors `allowed-origins` in `application.conf` |
| 7 | `nfs_servers` (delegated) | Update Huddo Boards Customizer extension `settings.js` |
| 8 | `component_pack_master` | Re-deploy Component Pack Helm charts (`connections-env`, ingress host rules) |
| 8a | `component_pack_master` | Re-run CNX CEC install + configure-ingress (picks up new `frontend_fqdn` automatically) |
| 9 | `dmgr` | Synchronize WAS nodes |
| 10–12 | `dmgr` + `was_servers` | Restart DMGR → Node Agents → CNX Clusters |

---

