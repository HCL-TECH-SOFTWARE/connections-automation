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
CACHE_SERVICE_PORT="30379"
CACHE_SERVICE_TYPE="cache.service"
CACHE_SERVICE_PASS=""
orgId="00000000-0000-0000-0000-000000000000"
PATH_TOUPDATE_FOLDER="/opt/HCL/Connections/shared/configuration/update"


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
	logIt "Usage: ./updateCacheServiceJSON.sh [OPTION]"
	logIt "This script will prepare the JSON configuration files needed to configure HCL Connections for communicating Cache Service traffic to Homepage"
	logIt "It generates configuration files based on the specified cache service type"
    logIt "Execute this script on the HCL Connections Deployment manager"
	logIt ""
	logIt "Options are:"
	logIt "-m    | --master			Hostname/IPAddress of the external Kubernetes load balancer in an HA environment or the Kubernetes worker in single node environment  Required."
	logIt "-po   | --port			The external port that Cache Service (Valkey) is running on within Kubernetes. Required.  Default value : 30379"
	logIt "-t    | --type			Cache service type: 'redis' or 'cache.service'. Default: cache.service"
	logIt "					  - 'redis' for Connections v7, v8 CR12 and below (c2.export.redis.*)"
	logIt "					  - 'cache.service' for Connections v8 CR13+ (c2.export.cache.service.*)"
    logIt "-pa   | --path			The absolute path to the Update folder.  Default value : /opt/HCL/Connections/shared/configuration/update"

	logIt ""
	logIt "-pw   | --password		Password for Cache Service Secret.  Must match value in Kubernetes secret cache-service-secret.  Optional."


	logIt ""
	logIt "sample usage (Cache Service Host and Cache Service Port) : ./updateCacheServiceJSON.sh -m <Kubernetes load balancer Hostname/IPAddress> -po <Cache Service Port> -t cache.service"
	logIt ""
	logIt "sample usage (Cache Service Host, Cache Service Port and Cache Service Password) : ./updateCacheServiceJSON.sh -m <Kubernetes load balancer Hostname/IPAddress> -po <Cache Service Port> -t redis -pw <Cache Service Password>"
	logIt ""

	exit 1
}

updateJSON() {

	# Clean up old generated files
	if [ -f placeholder.json.1 ]; then
		rm -rf placeholder.json.1
	fi

	if [ -f placeholder.json.2 ]; then
		rm -rf placeholder.json.2
	fi

	# Determine file prefix based on cache service type
	if [ "${CACHE_SERVICE_TYPE}" = "redis" ]; then
		FILE_PREFIX="redis"
		VERSION_DESC="v7, v8 CR12 and below"
	else
		FILE_PREFIX="cache-service"
		VERSION_DESC="v8 CR13+"
	fi

	if [ -f ${orgId}${FILE_PREFIX}-masterCacheService.json ]; then
		rm -rf ${orgId}${FILE_PREFIX}-masterCacheService.json
	fi

	if [ -f ${orgId}${FILE_PREFIX}-pwCacheService.json ]; then
		rm -rf ${orgId}${FILE_PREFIX}-pwCacheService.json
	fi

	echo ""
	echo "================================================================================"
	echo "GENERATING CACHE SERVICE JSON CONFIGURATION FILES"
	echo "================================================================================"

	# Generate configuration for specified cache service type
	echo ""
	echo "> Generating c2.export.${CACHE_SERVICE_TYPE} configuration (${VERSION_DESC})..."
	sed "s/CACHE_SERVICE_TYPE/${CACHE_SERVICE_TYPE}/" masterCacheService.json > placeholder.json.1
	sed "s/CACHE_SERVICE_HOST/${MASTER_HOSTNAME}/" placeholder.json.1 > placeholder.json.2
	sed "s/CACHE_SERVICE_PORT/${CACHE_SERVICE_PORT}/" placeholder.json.2 > ${orgId}${FILE_PREFIX}-masterCacheService.json
 	cp -av ${orgId}${FILE_PREFIX}-masterCacheService.json ${PATH_TOUPDATE_FOLDER}
	echo "  [OK] Created ${orgId}${FILE_PREFIX}-masterCacheService.json"

	if [ ${cache_service_pass} = true ]; then

		if [ ${encode_password} = true ]; then
			CACHE_SERVICE_PASS=`echo -n ${CACHE_SERVICE_PASS} | base64`
		    CACHE_SERVICE_PASS="~@64${CACHE_SERVICE_PASS}"
		fi

		echo ""
		echo "> Generating password configuration..."
		
		# Generate password file for specified cache service type
		sed "s/CACHE_SERVICE_TYPE/${CACHE_SERVICE_TYPE}/" pwCacheService.json > placeholder.json.1
		sed "s/CACHE_SERVICE_PASS/${CACHE_SERVICE_PASS}/" placeholder.json.1 > ${orgId}${FILE_PREFIX}-pwCacheService.json
		cp -av ${orgId}${FILE_PREFIX}-pwCacheService.json ${PATH_TOUPDATE_FOLDER}
		echo "  [OK] Created ${orgId}${FILE_PREFIX}-pwCacheService.json (${VERSION_DESC})"

	fi

	if [ ${clear_cache_service_pass} = true ]; then

		logInfo ""
		logInfo "Warning: Clearing the cache service password is discouraged."
		
		echo ""
		echo "> Clearing password configuration..."
		
		# Clear password for specified cache service type
		sed "s/CACHE_SERVICE_TYPE/${CACHE_SERVICE_TYPE}/" pwCacheService.json > placeholder.json.1
		sed "s/CACHE_SERVICE_PASS//" placeholder.json.1 > ${orgId}${FILE_PREFIX}-pwCacheService.json
		cp -av ${orgId}${FILE_PREFIX}-pwCacheService.json ${PATH_TOUPDATE_FOLDER}
		echo "  [OK] Created ${orgId}${FILE_PREFIX}-pwCacheService.json (password cleared, ${VERSION_DESC})"
	fi

	echo ""
	echo "================================================================================"
	echo "[SUCCESS] Configuration files generated successfully"
	echo "================================================================================"
	echo ""
	echo "Files created in ${PATH_TOUPDATE_FOLDER}:"
	echo ""
	echo "For ${VERSION_DESC}:"
	echo "  - ${orgId}${FILE_PREFIX}-masterCacheService.json (c2.export.${CACHE_SERVICE_TYPE}.host, c2.export.${CACHE_SERVICE_TYPE}.port)"
	if [ ${cache_service_pass} = true ] || [ ${clear_cache_service_pass} = true ]; then
		echo "  - ${orgId}${FILE_PREFIX}-pwCacheService.json (c2.export.${CACHE_SERVICE_TYPE}.pass)"
	fi
	echo ""
}

cache_service_pass=false
clear_cache_service_pass=false
encode_password=true

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
		-t|--type)
			CACHE_SERVICE_TYPE="$2"
			shift
			;;
		-pw|--password)
			CACHE_SERVICE_PASS="$2"
			cache_service_pass=true
			shift
			;;
		-unencoded|--unencoded)
			encode_password=false
            ;;
        -cl|--clearpassword)
			clear_cache_service_pass=true
            ;;
        -pa|--path)
			PATH_TOUPDATE_FOLDER="$2"
			shift
			;;
		*)
			usage
			;;
	esac
	shift
done


if [ "${MASTER_HOSTNAME}" = "" -o "${CACHE_SERVICE_PORT}" = "" -o "${PATH_TOUPDATE_FOLDER}" = "" ]; then
	logErr "Missing Kubernetes Master Hostname, Cache Service Port or Path to Update Folder"

	logErr "MASTER_HOSTNAME = ${MASTER_HOSTNAME}"
	logErr "CACHE_SERVICE_PORT = ${CACHE_SERVICE_PORT}"
    logErr "PATH_TOUPDATE_FOLDER = ${PATH_TOUPDATE_FOLDER}"

	logErr ""

	usage

	exit 5
fi

if [ "${CACHE_SERVICE_TYPE}" != "redis" -a "${CACHE_SERVICE_TYPE}" != "cache.service" ]; then
	logErr "Invalid cache service type: ${CACHE_SERVICE_TYPE}"
	logErr "Valid values are: 'redis' or 'cache.service'"

	logErr ""

	usage

	exit 6
fi

if [ ${cache_service_pass} = true -a ${clear_cache_service_pass} = true ]; then
	logErr "Can't use -pw with -cl options.  Cannot set password and clear password in the same function."

	usage

	exit 10
fi

(
	updateJSON

) 2>&1 | tee -a /var/log/updateJSON.log

logIt " "
logIt "Next Steps :"
logIt " "
logIt "	1. Log in to the WebSphere Deployment Manager. Browse to Applications "
logIt "	2. Restart Common"
logIt "	3. Restart News"
logIt " "
echo "Clean exit"
exit 0

