#!/bin/bash

# Copyright 2026 HCLTech
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o pipefail
#set -o xtrace

MASTER_HOSTNAME=""
CACHE_SERVICE_PORT=""
IHS_FQHN=""
CACHE_SERVICE_PASS=""
IC_USER=""
IC_PASS=""

logErr() {
	logIt "ERRO: " "$@"
}

logInfo() {
	logIt "INFO: " "$@"
}

logIt() {
	echo "$@"
}

usage() {
	logIt ""
	logIt "Usage: ./configureCacheService.sh [OPTION]"
	logIt "This script will configure HCL Connections for communicating Cache Service traffic to Homepage"
	logIt ""
	logIt "Options are:"
	logIt "-m    	| --master	The host name or IP address of the external Kubernetes load balancer (eg. HAProxy) in an HA environment or the worker node in a single node environment. Required."
	logIt "-po   	| --port		The external port that haproxy-valkey is running on. The default port is 30379. Required."
	logIt "-ic   	| --ic_internal		FQHN of the Connections deployment.  Include http / https  Required."

	logIt ""
	logIt "-pw   	| --password	Password for Cache Service Secret.  Must match value in Kubernetes secret cache-service-secret.  Optional."
	logIt "-ic_u	| --ic_user     Admin user with Auth privilege to configure the HCL Connections Highway Settings. Optional. If specified, must use -ic_p|--ic_pass option.."
	logIt "-ic_p	| --ic_pass     Password for admin user with Auth privilege to configure the HCL Connections Highway Settings. Optional. If specified, must use -ic_u|--ic_user option.."

	logIt ""
	logIt "sample usage (set Cache Service Host and Port) : ./configureCacheService.sh -m <Kubernetes load balancer Hostname/IPAddress> -po <Cache Service Port> -ic <FQHN of Connections HTTP server> -ic_u wasadmin -ic_p passw0rd"
	logIt ""
	logIt "sample usage (set Cache Service Host, Port and Password) : ./configureCacheService.sh -m <Kubernetes load balancer Hostname/IPAddress> -po <Cache Service Port> -ic <FQHN of Connections deployment> -pw <Cache Service password> -ic_u wasadmin -ic_p passw0rd"
	logIt ""

	exit 1
}

configureCacheService() {
	auth_command=""
	if [[ ${ic_auth} = true ]]; then
		auth_command="-u ${IC_USER}:${IC_PASS}"
	fi

	# Track success for backward compatibility logic
	redis_success=true
	cache_service_success=true

	echo ""
	echo "================================================================================"
	echo "CONFIGURING CACHE SERVICE"
	echo "================================================================================"

	# Try to configure redis (backward compatibility CNX Blue stack v7 or v8 CR12 or below)
	echo ""
	echo "> Attempting to configure c2.export.redis settings (backward compatibility)..."
	
	confighost_response=`curl --insecure ${auth_command} -w '%{http_code}' --output /dev/null -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "settingName=c2.export.redis.host&settingValue=${MASTER_HOSTNAME}" "${IHS_FQHN}/homepage/orgadmin/adminapi.jsp"`
	
	if [[ ${confighost_response} -ne 200 ]]; then
		echo "  [WARN] Failed to set c2.export.redis.host (${confighost_response})"
		redis_success=false
	else
		echo "  [OK] Successfully set config: c2.export.redis.host"
	fi

	configport_response=`curl --insecure ${auth_command} -w '%{http_code}' --output /dev/null -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "settingName=c2.export.redis.port&settingValue=${CACHE_SERVICE_PORT}" "${IHS_FQHN}/homepage/orgadmin/adminapi.jsp"`

	if [[ ${configport_response} -ne 200 ]]; then
		echo "  [WARN] Failed to set c2.export.redis.port (${configport_response})"
		redis_success=false
	else
		echo "  [OK] Successfully set config: c2.export.redis.port"
	fi

	if [ ${cache_service_pass} = true ]; then
		configpass_response=`curl --insecure ${auth_command} -w '%{http_code}' --output /dev/null -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "settingName=c2.export.redis.pass&settingValue=${CACHE_SERVICE_PASS}" "${IHS_FQHN}/homepage/orgadmin/adminapi.jsp"`

		if [[ ${configpass_response} -ne 200 ]]; then
			echo "  [WARN] Failed to set c2.export.redis.pass (${configpass_response})"
			redis_success=false
		else
			echo "  [OK] Successfully set config: c2.export.redis.pass"
		fi
	fi

	if [ ${clear_cache_service_pass} = true ]; then
		echo "  [WARN] Clearing the redis password is discouraged."
		configpass_response=`curl --insecure ${auth_command} -w '%{http_code}' --output /dev/null -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "settingName=c2.export.redis.pass&settingValue=" "${IHS_FQHN}/homepage/orgadmin/adminapi.jsp"`

		if [[ ${configpass_response} -ne 200 ]]; then
			echo "  [WARN] Failed to clear c2.export.redis.pass (${configpass_response})"
			redis_success=false
		else
			echo "  [OK] Successfully cleared c2.export.redis.pass"
		fi
	fi

	if [ "${redis_success}" = true ]; then
		echo "  [OK] Successfully configured c2.export.redis settings"
	else
		echo "  [INFO] c2.export.redis settings were not fully configured (may be expected for newer releases)"
	fi

	# Try to configure cache.service (v8 CR13 and later)
	echo ""
	echo "> Attempting to configure c2.export.cache.service settings..."

	confighost_response=`curl --insecure ${auth_command} -w '%{http_code}' --output /dev/null -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "settingName=c2.export.cache.service.host&settingValue=${MASTER_HOSTNAME}" "${IHS_FQHN}/homepage/orgadmin/adminapi.jsp"`
	
	if [[ ${confighost_response} -ne 200 ]]; then
		echo "  [WARN] Failed to set c2.export.cache.service.host (${confighost_response})"
		cache_service_success=false
	else
		echo "  [OK] Successfully set config: c2.export.cache.service.host"
	fi

	configport_response=`curl --insecure ${auth_command} -w '%{http_code}' --output /dev/null -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "settingName=c2.export.cache.service.port&settingValue=${CACHE_SERVICE_PORT}" "${IHS_FQHN}/homepage/orgadmin/adminapi.jsp"`

	if [[ ${configport_response} -ne 200 ]]; then
		echo "  [WARN] Failed to set c2.export.cache.service.port (${configport_response})"
		cache_service_success=false
	else
		echo "  [OK] Successfully set config: c2.export.cache.service.port"
	fi

	if [ ${cache_service_pass} = true ]; then
		configpass_response=`curl --insecure ${auth_command} -w '%{http_code}' --output /dev/null -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "settingName=c2.export.cache.service.pass&settingValue=${CACHE_SERVICE_PASS}" "${IHS_FQHN}/homepage/orgadmin/adminapi.jsp"`

		if [[ ${configpass_response} -ne 200 ]]; then
			echo "  [WARN] Failed to set c2.export.cache.service.pass (${configpass_response})"
			cache_service_success=false
		else
			echo "  [OK] Successfully set config: c2.export.cache.service.pass"
		fi
	fi

	if [ ${clear_cache_service_pass} = true ]; then
		echo "  [WARN] Clearing the cache service password is discouraged."
		configpass_response=`curl --insecure ${auth_command} -w '%{http_code}' --output /dev/null -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "settingName=c2.export.cache.service.pass&settingValue=" "${IHS_FQHN}/homepage/orgadmin/adminapi.jsp"`

		if [[ ${configpass_response} -ne 200 ]]; then
			echo "  [WARN] Failed to clear c2.export.cache.service.pass (${configpass_response})"
			cache_service_success=false
		else
			echo "  [OK] Successfully cleared c2.export.cache.service.pass"
		fi
	fi

	if [ "${cache_service_success}" = true ]; then
		echo "  [OK] Successfully configured c2.export.cache.service settings"
	else
		echo "  [INFO] c2.export.cache.service settings were not fully configured (may be expected for older releases)"
	fi

	# Evaluate overall success based on backward compatibility logic
	echo ""
	echo "================================================================================"
	if [ "${redis_success}" = false ] && [ "${cache_service_success}" = false ]; then
		echo "[ERROR] Both c2.export.redis and c2.export.cache.service configuration failed."
		echo "================================================================================"
		if [ ${ignoreResponseCode} = false ]; then
			if [[ ${confighost_response} -eq 302 ]]; then
				logErr ${errorMsg302}
			fi
			echo "Exiting"
			exit 2
		else
			echo "Ignoring errors and proceeding."
		fi
	elif [ "${redis_success}" = true ] && [ "${cache_service_success}" = true ]; then
		echo "[SUCCESS] Both c2.export.redis and c2.export.cache.service settings applied"
		echo "================================================================================"
	elif [ "${redis_success}" = true ]; then
		echo "[SUCCESS] c2.export.redis settings applied (backward compatible mode)"
		echo "================================================================================"
	elif [ "${cache_service_success}" = true ]; then
		echo "[SUCCESS] c2.export.cache.service settings applied"
		echo "================================================================================"
	fi

	echo ""
	echo "Cache service configuration completed."
	echo ""
}

cache_service_pass=false
clear_cache_service_pass=false
ic_auth=false
ignoreResponseCode=false
errorMsg302="Received a 302 response.  Possible root cause : You have specified http against a SSL/TLS protected HCL Connections Server. Please re-run the script, ensuring to specify https when setting the -ic parameter, should the HCL Connections Server be SSL/TLS protected."

while [[ $# -gt 0 ]]
do
	key="$1"

	case $key in
		-m|--master)
			MASTER_HOSTNAME="$2"
			shift
			;;
		-po|--port)
			CACHE_SERVICE_PORT="$2"
			shift
			;;
		-ic|--ic_internal)
			IHS_FQHN="$2"
			shift
			;;
		-pw|--password)
			CACHE_SERVICE_PASS="$2"
			cache_service_pass=true
			shift
			;;
		-cl|--clearpassword)
			clear_cache_service_pass=true   # Do not use, not setting a cache service secret is discouraged.
			;;
		-ic_u|--ic_user)
			IC_USER="$2"
			shift
			;;
		-ic_p|--ic_pass)
			IC_PASS="$2"
			shift
			;;
		--ignore_responsecode)
                        ignoreResponseCode=true
                        ;;
		*)
			usage
			;;
	esac
	shift
done


if [ "${MASTER_HOSTNAME}" = "" -o "${CACHE_SERVICE_PORT}" = "" -o "${IHS_FQHN}" = "" ]; then
	logErr "Missing Kubernetes load balancer or worker Hostname, Cache Service Port, or Connections URL"

	logErr "MASTER_HOSTNAME = ${MASTER_HOSTNAME}"
	logErr "CACHE_SERVICE_PORT = ${CACHE_SERVICE_PORT}"
	logErr "IHS_FQHN = ${IHS_FQHN}"


	logErr ""

	usage

	exit 5
fi

if [[ ${IHS_FQHN} != "http://"* ]] && [[ ${IHS_FQHN} != "https://"* ]]; then
    logErr "YOU MUST SPECIFY http:// or https://"
    logErr ""

    usage

    exit 5
fi

if [ ${cache_service_pass} = true -a ${clear_cache_service_pass} = true ]; then
	logErr "Can't use -pw with -cl options.  Cannot set password and clear password in the same function."

	usage

	exit 10
fi

if [[ ${IC_USER} != "" ]] && [[ ${IC_PASS} == "" ]]; then
        logErr "A username has been specified but password has not been specified.  If setting a username, a password must be specified."

        usage

        exit 10
fi

if [[ ${IC_USER} == "" ]] && [[ ${IC_PASS} != "" ]]; then
        logErr "A password has been specified but username has not been specified.  If setting a password, a username must be specified."

        usage

        exit 10
fi

if [[ ${IC_USER} != "" ]] && [[ ${IC_PASS} != "" ]]; then
	ic_auth=true

fi


(
	configureCacheService

) 2>&1 | tee -a /var/log/configureCacheService.log


echo "Clean exit"
exit 0
