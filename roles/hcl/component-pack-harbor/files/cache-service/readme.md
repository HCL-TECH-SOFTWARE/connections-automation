# Cache Service Configuration Scripts

The Cache Service is automatically configured during the initial Component Pack bootstrap installation.  If manual adjustments are required, use the scripts in this folder to update the connection settings between the HCL Connections server and the Cache Service.

## Scripts

- **`configureCacheService.sh`** - Configures cache service via Homepage API
- **`updateCacheServiceJSON.sh`** - Generates JSON configuration files to configure cache service settings directly on the HCL Connections deployment's WebSphere Deployment Manager (alternative approach)

Both scripts support both Redis (legacy) and Valkey (cache.service) configurations:

For instructions, please refer to the following documentation:
https://help.hcl-software.com/connections/latest/admin/install/cp_config_om_cache_service_enable.html
