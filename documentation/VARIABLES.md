#### This page outlines the required and optional variables in group_vars/all.yml.

See [Sample Inventories](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/environments/examples) where some of these variables are used.
## Table of contents

[LDAP Variables](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/documentation/VARIABLES.md#ldap-variables)

[Database Variables](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/documentation/VARIABLES.md#database-variables)

[DB2 Variables](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/documentation/VARIABLES.md#db2-variables)

[Oracle Variables](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/documentation/VARIABLES.md#oracle-variables)

[MSSQL Variables](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/documentation/VARIABLES.md#mssql-variables)

[WebSphere Variables](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/documentation/VARIABLES.md#websphere-variables)

[IHS Variables](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/documentation/VARIABLES.md#ihs-variables)

[IIM Variables](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/documentation/VARIABLES.md#iim-variables)

[SDI Variables](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/documentation/VARIABLES.md#sdi-variables)

[Connections Variables](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/documentation/VARIABLES.md#connections-variables)

[Docs Variables](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/documentation/VARIABLES.md#docs-variables)

[Component Pack Infra Variables](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/documentation/VARIABLES.md#component-pack-infra-variables)

[Component Pack Variables](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/documentation/VARIABLES.md#component-pack-variables)

[NFS Variables](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/documentation/VARIABLES.md#nfs-variables)

[Cleanup Variables](https://github.com/HCL-TECH-SOFTWARE/connections-automation/tree/main/documentation/VARIABLES.md#cleanup-variables)

### LDAP Variables
Name | Default | Description
---- | --------| -------------
setup_fake_ldap_users | true | true creates dummy ldap users
ldap_bind_pass | password | Password for simple authentication
ldap_realm | dc=cnx,dc=pnp-hcl,dc=com | This directive specifies the DN suffix of queries that will be passed to this backend database
ldap_admin_user | Admin | Ldap admin user
ldap_nr_of_users | 2500 | Ldap number of users to be created
ldap_userid | jjones | User id for the ldap users. It is postfixed with the user number. e.g. with default ldap_userid as 'jjones', user1 will be created with user id - jjones1
ldap_user_password | password | Password for the ldap users
ldap_user_admin_password | password | Ldap user admin password
ldap_user_mail_domain | connections.example.com | Ldap user email domain
ldap_setup_internal | false | true sets up internal users

### Database Variables
Name | Default | Description
---- | --------| -------------
db_type | DB2 | Database type to be passed to the Connections installer
db_username | LCUSER | Database user to be passed to the Connections installer
db_password | password | Database user password to be passed to the Connections installer
db_port | 50000 | TCP/IP service port
db_hostname | *none* - required | Database hostname
db_jdbc_file | /opt/IBM/db2/V11.1/java | Database JDBC driver path

### DB2 Variables
Name | Default | Description
---- | --------| -------------
db2_download_location | *none* - required | DB2 install kit location to download
setup_db2_jdbc | false | true will install jdbc drivers to WAS nodes
db2_user | db2inst1 | DB2 Instance owner
db2_installation_folder | /opt/IBM/db2/V11.1 | DB2 installation folder path
db2_instance_homedir | /home/db2inst1 | DB2 Instance owner home directory
db2_package_name | v11.1.4fp5_linuxx64_universal_fixpack.tar.gz | DB2 package name
db2_license_file | CNB23ML.zip | DB2 license file name
db2_instance | inst1 | logical Database Manager environment for DB2
db2_instance_type | ese | DB2 instance type
db2_instance_group | db2group | DB2 instance group
db2_instance_autostat | YES |  True will enable the DB2 database instance for automatically start
db2_instance_svcname | db2c_db2inst1 | DB2 instance service name
db2_instance_port | 50000 | TCP/IP service port
db2_instance_fcm_port | 60000 | port used by the Fast Communications Manager
db2_instance_max_lnodes | 6 | Maximum node counts
db2_instance_text_search | NO | Yes configures integrated Db2 Text Search server
db2_instance_fenced_user | db2fenc1 | Fenced user to run user defined functions (UDFs) and stored procedures outside of the address space used by the Db2 database
db2_instance_fenced_group | db2group | Fenced user group
db2_instance_fenced_homedir | /home/db2fenc1 | Fenced user home directory
db2_instance_default_lang | EN | DB2 instance default language
install_latest_db2 | false | true will install IBM DB2 v11.5.6 and false will install IBM DB2 v11.1

### Oracle Variables
Name | Default | Description
---- | --------| -------------
oracle_download_location | *none* - required | Oracle database download location
setup_oracle_jdbc | false | true will install jdbc drivers to WAS nodes
ora_rsp_oracle_base | /opt/oracle | Oracle database base location
ora_rsp_oracle_home | /opt/oracle/product/19.0.1/db_1 | Oracle database home location
ora_rsp_starter_db_name | LSCONN | Global Database Name
oracle_package_name | LINUX.X64_193000_db_home.zip | Installer package name
ora_rsp_install_option | INSTALL_DB_AND_CONFIG | The installation option can be - INSTALL_DB_SWONLY, INSTALL_DB_AND_CONFIG, UPGRADE_DB
ora_rsp_unix_group_name | oinstall | Provide values for the OS groups to which OSDBA privileges needs to be granted
ora_rsp_inventory_location | /opt/oracle |
ora_rsp_data_location | default( '/opt/oracle/data' ) | Database file location: directory for datafiles, control files, redo logs
ora_rsp_data_rcvry_location | default( '/opt/oracle/recovery' ) | Backup and recovery location
ora_rsp_install_edition | EE | Installation Edition of the component e.g. EE : Enterprise Edition, SE : Standard Edition, SEONE : Standard Edition One, PE : Personal Edition (WINDOWS ONLY)
ora_rsp_exec_root_script | false | true for automatic root script execution
ora_rsp_root_config_method | SUDO | Specify the configuration method to be used for automatic root script execution
ora_rsp_starter_db_type | GENERAL_PURPOSE | Starter database type - GENERAL_PURPOSE, TRANSACTION_PROCESSING, DATAWAREHOUSE
ora_rsp_starter_db_name | LSCONN | Starter database name
ora_rsp_starter_charset | AL32UTF8 | Database character set
ora_rsp_use_auto_mem_mgmt | false | true means use auto memory management
ora_rsp_auto_mem_limit | 2048 | Specify the total memory allocation for the database
ora_rsp_enable_recovery | true | true means enable recovery
ora_rsp_storage_type | FILE_SYSTEM_STORAGE | Storage type can be - FILE_SYSTEM_STORAGE, ASM_STORAGE
oracledb_exporter_version | oracledb_exporter.0.3.0rc1-ora18.5.linux-amd64 | Oracle database exporter version
oracledb_exporter_release | 0.3.0rc1 | Binary release version
oracledbexp_extraction_folder | /home/oracle | Oracle database exporter extraction folder path
oracle_bashrc_file_path | /home/oracle/.bashrc | bashrc file path
metrics_port | 9161 | Port to get metrics from the Oracle database
oracledb_port | 1521 | TCP/IP service port

### MSSQL Variables
Name | Default | Description
---- | --------| -------------
setup_mssql_jdbc | false | true will install jdbc drivers to WAS nodes
mssql_sa_password | Pa55w0rd | MSSQL user specified password
mssql_accept_eula | Y | Y confirm your acceptance of the End-User Licensing Agreement
mssql_pid | evaluation | Set the SQL Server edition or product key. Possible values include: Evaluation, Developer, Express, Web, Standard, Enterprise
mssql_jdbc_installation_folder | /opt/mssql/jdbc/lib | MSSQL installation folder path
mssql_jdbc_package_name | sqljdbc_6.0.8112.200_enu.tar.gz | MSSQL package name
mssql_jdbc_tdi_enable | true | true downloads legacy drivers for TDI JRE
mssql_create_admin_user | true | true creates extra admin user for MSSQL
upgrade_tdi_jre | false | true upgrades jre

### WebSphere Variables
Name | Default | Description
---- | --------| -------------
was_repository_url | *none* - required | WebSphere install kit download location
was_fixes_repository_url | *none* - required | WebSphere Fix Pack kit location to download
was_version | 8.5.5000.20130514_1044 | WebSphere Base version
was_fp_version | 8.5.5019.20210118_0346 | WebSphere Fix Pack version
java_version | 8.0.6015.20200826_0935 | (only for Java upgrade during FP16/18 install)
was_username | wasadmin | WAS admin user
was_password | password | WAS admin user password
was_install_location | /opt/IBM/WebSphere/AppServer | WebSphere program folder
dmgr_hostname | *none* - required | Deployment Manager hostname, typically `{{ hostvars[groups['db_servers'][0]]['inventory_hostname'] }}`
dmgr_soap_port | 8879 | Deployment Manager soap port


### IHS Variables
Name | Default | Description
---- | --------| -------------
ihs_repository_url | *none* - required | IHS install kit download location
ihs_fixes_repository_url | *none* - required | IHS Fix Pack kit location to download
ihs_version | 8.5.5019.20210118_0346 | IHS Fix Pack version
ihs_username | ihsadmin | IHS admin user
ihs_password | *none* - required | IHS admin user password


### IIM Variables
Name | Default | Description
---- | --------| -------------
iim_repository_url | *none* - required | IIM install kit download location
tmp_dir | /opt/IBM/Binaries | Folder to extract installation kits
iim_install_location | /opt/IBM/InstallationManager | IIM program folder
imshared_location | /opt/IBM/IMShared | IIM config folder
iim_bin_file | agent.installer.linux.gtk.x86_64_1.9.1003.20200730_2125.zip | IIM program zip
iim_version | 1.9.1003.20200730_2125 | IIM version
iim_keep_fetched_files | false | IIM var, true will keep downloaded files if error occurs
iim_preserve_artifacts | false | IIM var, true will keep the files that are required to run uninstall


### SDI Variables
Name | Default | Description
---- | --------| -------------
tdi_download_location | *none* - required | SDI install kit download location
tdi_package_name | SDI_7.2_XLIN86_64_ML.tar | SDI install kit file
tdi_user_install_dir | /opt/IBM/TDI/V7.20 | SDI program folder
tdi_upgrade_enable | true | Enable SDI FP install
tdi_upgrade_package_name | 7.2.0-ISS-SDI-FP0006.zip | SDI FP install kit file
tdi_upgrade_package_bin | SDI-7.2-FP0006.zip | SDI FP file to provide to installer
tdi_upgrade_package_folder_name | 7.2.0-ISS-SDI-FP0006 | Folder that stores tdi_upgrade_package_bin
tdi_cs_port | 1527 | SDI Derby server port
cnx_updates_enabled | false | true will download `{{ cnx_package }}` (i.e. Connections install kit) again to get the tdisol from there
upgrade_tdi_jre | false | Enable upgrade to SDI JRE 8 (need a separate 6.5CR1 or 7.0 tdisol kit)
tdi_sol_location | /opt/IBM/InstallBinaries/CNX/HCL_Connections_Install/tools/tdisol.tar | path to the tdisol tar to use if not the one from `{{ cnx_package }}` (eg. when upgrade_tdi_jre=true)
jre_package_version | ibm-java-x86_64-80 | JRE package version, used when upgrade_tdi_jre=true
jre_package_name | ibm-java-jre-8.0-5.30-linux-x86_64.tgz | JRE package file, used when upgrade_tdi_jre=true
db_jdbc_file | /opt/IBM/db2/V11.1/java or /opt/IBM/db2/V11.5/java | DB2 JDBC driver folder
oracle_jdbc_location | /opt/oracle | Oracle JDBC driver folder
mssql_jdbc_location | /opt/mssql/jdbc/lib/sqljdbc_4.1/enu/jre7 or /opt/mssql/jdbc/lib/sqljdbc_6.0/enu/jre8 | MSSQL JDBC driver folder


### Connections Variables
Name | Default | Description
---- | --------| -------------
cnx_repository_url | *none* - required | Connections install kit download location
connections_wizards_download_location | *none* - required | Connections Wizard install kit location to download
cnx_package | HCL_Connections_7.0_lin.tar | Connections install kit file
connections_wizards_package_name | HCL_Connections_7.0_wizards_lin_aix.tar | Connections Wizard kit file
setup_connections_wizards | true | true will run the Connections database wizard
cnx_force_repopulation | false | true will drop the Connections databases and recreate them in `setup-connections-wizards.yml` playbook
cnx_major_version | "7" | Connections major version to install
cnx_fixes_version | *none* - optional | If defined (eg. 6.5.0.0_CR1) will install the CR version
cnx_fixes_files | *none* - optional | If defined (eg. HC6.5_CR1.zip") and cnx_fixes_version is set, will download the CR install kit
cnx_application_ingress | *none*  - required | Set as *dynamicHosts* in LotusConnections-config.xml
connections_admin | jjones1 | User to be passed to the Connections installer as admin user
connections_admin_password | password | password for Connections admin user
cnx_deploy_type | small | Connections deployment option (i.e. small/medium/large)
skip_nfs_mount_for_connections | false | false will setup NFS mount points for Connections data and message store
cnx_shared_area | /opt/IBM/SharedArea | Connections shared data location mount point
cnx_shared_area_nfs | /nfs/data/shared | Connections shared data NFS share
cnx_message_store | /opt/HCL/MessageStore | Connections bus SIB location mount point
cnx_message_store_nfs | /nfs/data/messageStores | Connections bus SIB NFS share
cnx_enable_invite | false | true will configure selfregistration-config.xml for Invite
cnx_enable_moderation | false | true will install and configure Moderation
global_moderator | *none* - optional | Global moderator user
cnx_enable_full_icec | false | true will configure full CEC
cnx_enable_lang_selector | false | true will enable and add additional lanaguages to the language selector
cnx_updates_enabled | false | true will upgrade Connections if a new version is available in cnx_repository_url
db_version | "7.0" | Determines the set of databases to create/drop (eg. 7.0, 6.5)
cnx_db_updates_url | *none* - required for 6.5CR1 with DB2 | database schema upgrade zip download location (6.5 CR1 only)
cnx_db_update_file | 65cr1-database-updates.zip | File name to download for database schema upgrade (6.5 CR1 only)
db_type | DB2 | Database type to be passed to the Connections installer
db_username | LCUSER | Database user to be passed to the Connections installer
db_password | password | Database user password to be passed to the Connections installer
db_port | 50000 | Database user password to be passed to the Connections installer
smtp_hostname | *none* - required | <for future use, you can set it to *localhost*>
ifix_apar | *none* - required when install Connections fix | APAR number of fix
ifix_file | *none* - required when install Connections fix | fix file name from `{{ cnx_repository_url }}`
cnx_ifix_installer | updateInstaller.zip | updateInstaller file to download from `{{ cnx_repository_url }}`
cnx_ifix_backup | yes | -featureCustomizationBackedUp option to be provided to the updateInstaller
restrict_reader_access | *none* - optional | true will set application roles to All Authenticated in Application's Realm when running the `connections-restrict-access.yml` playbook
restrict_reader_access__trusted_realms | *none* - optional | true will set application roles to All Authenticated in Trusted Realm when running the `connections-restrict-access.yml` playbook


### Docs Variables
Name | Default | Description
---- | --------| -------------
cnx_docs_download_location | *none* - required | Connections Docs kit download location
cnx_docs_package_name | IBMConnectionsDocs_2.0.1.zip | Connections Docs install kit file
hcl_program_folder | /opt/HCL | Location to store Docs program folders
conversion_install_folder | DocsConversion | Conversion program folder name
editor_install_folder | DocsEditor | Editor program folder name
viewer_install_folder | DocsViewer | Viewer program folder name
proxy_install_folder | DocsProxy | Docs Proxy program folder name
setup_connections_docs | false | true will run the Connections Docs database setup in `setup-connections-wizards.yml` playbook
cnx_docs_force_repopulation | false | true will drop the Docs databases and recreate it in setup-connections-wizards.yml playbook
docs_username | docsuser | Docs database user
docs_password | *none* - required | Password for the user to be created for job target creation
sudo_group | *none* - required | Group for the user to be created for job target creation
nfs_docs_setup | true | true will create the NFS mount points for Connections data, Docs and Viewer data, must be true if `skip_nfs_mount_for_connections` is false (default)
conversion_cluster_name | HCLConversionCluster | Conversion cluster name
editor_cluster_name | HCLEditorCluster | Docs cluster name
viewer_cluster_name | HCLViewerCluster | Docs Viewer cluster name
docs_proxy_cluster_name | HCLDocsProxyCluster | Docs Proxy cluster name
db_concord_username | DOCSUSER | Docs database user
db_concord_password | *none* - required | Docs database user password
docs_url  | *none* - required | Docs frontend hostname, typically the same as `{{ cnx_application_ingress }}`
docs_shared_storage_type | nfs | Set to `nfs` if Docs data is a NFS share, `local` if it is a local directory
docs_data_remote_path | /nfs/docs_data| NFS share of Docs data dir, `{{ docs_shared_storage_type }}` must be nfs to use it
docs_data_local_path | /mnt/docs_data | path of local location to Docs data dir, if `{{ docs_shared_storage_type }}` is `nfs`, `{{ docs_data_remote_path }}` will mount to this directory
viewer_shared_storage_type | nfs | Set to `nfs` if Docs Viewer data is a NFS share, `local` if it is a local directory
viewer_data_remote_path | /nfs/viewer_data | NFS share of Docs Viewer data dir, `{{ viewer_shared_storage_type }}` must be nfs to use it
viewer_data_local_path | /mnt/viewer_data | path of local location to Docs Viewer data dir, if `{{ viewer_shared_storage_type }}` is `nfs`, `{{ viewer_data_remote_path }}` will mount to this directory
cnx_shared_storage_type | nfs | Set to `nfs` if Connections data is a NFS share to the Docs server, `local` if it is a local directory
cnx_data_remote_path | /nfs/data/shared | NFS share of Connections data dir, `{{ cnx_shared_storage_type }}` must be `nfs` to use it
cnx_data_local_path | /mnt/cnx_data | path of local location to Connections data dir, if `{{ cnx_shared_storage_type }}` is `nfs`, `{{ cnx_data_remote_path }}` will mount to this directory
cnx_data_path_on_cnx_server | /opt/IBM/SharedArea | local path of Connections data on the Connections server (i.e. where Docs extensions will be installed)

### Component Pack Infra Variables
Name | Default | Description
---- | --------| -------------
containerd_version | 1.4.4-3.1.el7 | Containerd version to be installed
docker_version | 19.03.15-3.el7 | Docker version to be installed
registry_port | 5000 | The registry defaults to listening on port 5000
setup_docker_registry | true | true sets up docker registry
docker_registry_url | {{ hostvars[groups['docker_registry'][0]]['inventory_hostname'] }}:5000 | Docker Registry url
registry_user | admin | Docker Registry user name
registry_password | password | Docker Registry user password
overlay2_enabled | true | true enables OverlayFS storage driver
kubernetes_version | 1.19.11 | Kubernetes version to be installed
kube_binaries_install_dir | /usr/bin | kuberneters binary install directory
kube_binaries_download_url | https://storage.googleapis.com/kubernetes-release/release | kuberneters binary download path
ic_internal | localhost | Connections server internal frontend host (eg. IHS host)
load_balancer_dns | localhost | Specify a DNS name for the control plane.
pod_subnet | 192.168.0.0/16 | Specify range of IP addresses for the pod network. If set, the control plane will automatically allocate CIDRs for every node.
kubectl_user |  ansible_env['SUDO_USER'] | Kubectl is setup for all the users listed here
calico_version | 3.11 | Calico version to be installed
calico_install_latest | true | true installs/Upgrades Calico to the latest version
helm_version | 3.6.1 | Helm version to be installed
haproxy_version | 2.4.0 | HAProxy version to be installed


### Component Pack Variables
Name | Default | Description
---- | --------| -------------
component_pack_download_location | http://localhost:8000 | Component Pack zip download location
component_pack_package_name | hybridcloud_latest.zip | Component Pack zip file name
component_pack_extraction_folder | /opt/hcl-cnx-component-pack | location to extract the Component Pack zip
enable_pod_auto_scaling | true | Scale the number of replicas based on the number of workers
cp_replica_count | 1 | replica count to set in Helm charts for infrastructure, Orient Me and other apps
skip_pod_checks | true | True will check if pods are in Running state during setup_infrastructure
skip_connections_integration | false | True will skip profiles migration for Orient Me, Activities Plus, Outlook Desktop Plugin, ES metrics and MS Teams integration
skip_configure_redis | false | True will skip Redis configuration. Redis is required for Orient Me, so only skip if you do not plan to deploy Orient Me
credentials_name | myregkey | Kubernetes secret name for Docker registry credentials
es_key_password | password | Elasticsearch Key password
es_ca_password | password | Elasticsearch CA password
redis_secret | password |  Redis secret used in bootstrap
search_secret | password | search secret used in bootstrap
solr_secret | password | Solr secret used in bootstrap
default_namespace | connections | Kubernetes namespace
nfsMasterAddress | hostvars[groups['nfs_servers'][0]]['ansible_default_ipv4']['address'] | NFS master IP
persistentVolumePath | pv-connections | Persistent volume location to be created
ingress_multi_domain_enabled | false | Set to true when frontend is on a different domain as the Component Pack nodes
setup_installation | true | True will prepare generated charts location, download and extract the Component Pack zip
setup_images | true | True will run setupImages.sh to push images to Docker registry
setup_credentials | true | True will create namespace and setup credentials for Docker registry
setup_connections_volumes | true | True will setup connections-volumes
setup_psp | true | True will setup Kubernetes PSP
setup_bootstrap | true | True will run bootstrap to creates secrets and certificates for various components
setup_connections_env | true | True will setup connections-env configmap
setup_infrastructure | true | True will setup infrastructure for Orient Me and other apps
setup_customizer | true | True will deploy mw-proxy and setup customizations
elasticsearch_default_version | 7 | Default ElasticSearch version
elasticsearch_default_port | 30098 | ElasticSearch port
setup_elasticsearch | false | True will deploy ElasticSearch 5 (for Connections 6.5CR1)
setup_elasticsearch7 | true | True will deploy ElasticSearch 7 (for Connections 7)
setup_ingress | false | True will setup old ingress controller (for Connections 6.5CR1)
setup_community_ingress | true | True will setup community ingress controller (for Connections 7 onwards)
setup_tailored_exp | true | True will deploy Tailored Experience features for communities (for Connections 7 onwards)
setup_orientme | true | True will deploy Orient Me (make sure the corresponding setup_elasticsearch7 var is set to true)
setup_sanity | true | True will deploy sanity-watcher
setup_kudosboards | true | True will deploy Activities Plus, must have a license key (defined in kudos_boards_licence) for the feature to work
kudos_boards_licence | *none* | Activities Plus license key
setup_elasticstack | false | True will setup ElasticStack
setup_elasticstack7 | false | True will setup ElasticStack7
setup_outlook_addin | true | True will deploy Outlook Desktop Plugin
enable_es_metrics | true | True will configure ElasticSearch
enable_gk_flags | true | True will configure Tailored Experience features for communities (for Connections 7 onwards)
setup_teams | true | True will deploy Microsoft Teams integration (for Connections 7 onwards)
setup_ms_teams_extensions | true | True will Microsoft Teams extensions (for Connections 7 onwards)
integrations_msteams_tenant_id | changeme | Tenant ID to configure Microsoft Teams integration
integrations_msteams_client_id | changeme | Client ID to configure Microsoft Teams integration
integrations_msteams_client_secret | changeme | Kubernetes secret name for Microsoft Teams integration
integrations_msteams_auth_schema | 0 | Auth schema to configure Microsoft Teams integration


### NFS Variables
Name | Default | Description
---- | --------| -------------
preserve_nfs_data | true | true will preserve NFS data when running the cleanup playbooks


### Cleanup Variables
Name | Default | Description
---- | --------| -------------
preserve_nfs_data | true | true will preserve NFS data
force_destroy_kubernetes | false | True will remove Kubernetes and Helm when running the corresponding cleanup playbook
force_destroy_containerd_images | false | True will remove the images in containerd (if any) when running the corresponding cleanup playbook
force_destroy_ihs | false | True will remove IHS when running the cleanup playbook
force_destroy_websphere | false | True will remove WebSphere (including Connections) when running the corresponding cleanup playbook
force_destroy_docs | false | True will delete Docs NFS data when running the corresponding cleanup playbook
force_destroy_db2 | false | True will kill all DB2 process and delete DB2 folder when running the corresponding cleanup playbook
force_destroy_oracle | false | True will kill all Oracle process and delete Oracle folder when running the corresponding cleanup playbook
persistentVolumePath | pv-connections | Persistent volume location to be created
helm_install_dir | /opt/helm | Helm install directory
ansible_cache | /tmp/k8s_ansible | Ansible cache location
kube_dir | /root/.kube | Kubernetes directory path
docker_registry_dir | /etc/docker/registry | Docker registry directory path
kubernetes_etc_dir | /etc/kubernetes | Kubernetes directory path
etcd_dir | /var/lib/etcd | etcd directory
db2_instance_fenced_homedir | /home/db2fenc1 | Fenced user home directory
db2_instance_homedir | /home/db2inst1 | DB2 Instance owner home directory
db_installation_folder_dir | /opt/IBM/db2 | DB2 installation directory
ihs_install_location | /opt/IBM/HTTPServer | IHS installation directory
iim_install_location | /opt/IBM/InstallationManager | IIM program folder
var_ibm_base_location | /var/ibm | var IBM base location
websphere_base_location | /opt/IBM/WebSphere | Websphere base location
imshared_location | /opt/IBM/IMShared | IIM config folder
ora_rsp_oracle_base | /opt/oracle | Oracle database base location
oraclfmap_oracle_base | /opt/ORCLfmap | Oracle database ORCLfmap location
oracltab_oracle_base | /etc/oratab | Oracle database oracltab base location
orainst_oracle_base | /etc/oraInst.loc | Oracle database orainst base location
oracle_temp | /tmp/.oracle | Oracle temp folder path
nfs_master_source | /pv-connections | Persistent volume location to be deleted
cnx_message_store | /opt/HCL/MessageStore | Connections bus SIB location mount point
cnx_message_store_nfs | /nfs/data/messageStores | Connections bus SIB NFS share
cnx_shared_area | /opt/IBM/SharedArea | Connections shared data location mount point
cnx_shared_area_nfs | /nfs/data/shared | Connections shared data NFS share
customizer_js_files_mount | /mnt/customizations | Customization files mount point folder in Component Pack
viewer_data_local_path | /mnt/viewer_data | path of local location to Docs Viewer data dir, if {{ viewer_shared_storage_type }} is nfs, {{ viewer_data_remote_path }} will mount to this directory
viewer_data_remote_path | /nfs/viewer_data | NFS share of Docs Viewer data dir, {{ viewer_shared_storage_type }} must be nfs to use it
docs_data_remote_path | /nfs/docs_data | NFS share of Docs data dir, {{ docs_shared_storage_type }} must be nfs to use it
docs_data_local_path | /mnt/docs_data | path of local location to Docs data dir, if {{ docs_shared_storage_type }} is nfs, {{ docs_data_remote_path }} will mount to this directory
cnx_data_remote_path | /nfs/data/shared | NFS share of Connections data dir, {{ cnx_shared_storage_type }} must be nfs to use it
cnx_data_local_path | /mnt/cnx_data | path of local location to Connections data dir, if {{ cnx_shared_storage_type }} is nfs, {{ cnx_data_remote_path }} will mount to this directory
nfs_master_files_mount | /mnt/pv-connections | Persistent volume mount point folder in Component Pack
cnx_install_base_dir | /opt/HCL/ | Base directory of connections installation
