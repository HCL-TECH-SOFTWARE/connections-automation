#!/bin/bash

set -o errexit
set -o pipefail
#set -o xtrace

MASTER_HOSTNAME=""
REDIS_PORT="30379"
REDIS_SECRET=""
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
	logIt "Usage: ./updateRedisJSON.sh [OPTION]"
	logIt "This script will prepare the JSON configuration files needed to configure HCL Connections for communicating Redis traffic to Homepage"
        logIt "Execute this script on the HCL Connections Deployment manager"
	logIt ""
	logIt "Options are:"
	logIt "-m    | --master			Hostname/IPAddress of the external Kubernetes load balancer in an HA environment or the Kubernetes worker in single node environment  Required."
	logIt "-po   | --port				The external port that Redis is running on within Kubernetes. Required.  Default value : 30379"
        logIt "-pa   | --path				The absolute path to the Update folder.  Default value : /opt/HCL/Connections/shared/configuration/update"

	logIt ""
	logIt "-pw   | --password			Password for Redis Secret.  Must match value in Kubernetes secret.  Optional."


	logIt ""
	logIt "sample usage (Redis Host and Redis Port) : ./updateRedisJSON.sh -m <Kubernetes load balancer Hostname/IPAddress> -po <Redis Port>"
	logIt ""
	logIt "sample usage (Redis Host, Redis Port and Redis Password) : ./updateRedisJSON.sh -m <Kubernetes load balancer Hostname/IPAddress> -po <Redis Port> -pw <Redis Secret>"
	logIt ""

	exit 1
}

updateJSON() {

	if [ -f placeholder.json.1 ]; then
		rm -rf placeholder.json.1
	fi

	if [ -f ${orgId}masterRedis.json ]; then
		rm -rf ${orgId}masterRedis.json
	fi

	if [ -f ${orgId}pwRedis.json ]; then
		rm -rf ${orgId}pwRedis.json
	fi

	sed "s/REDIS_HOST/${MASTER_HOSTNAME}/" masterRedis.json > placeholder.json.1

	sed "s/REDIS_PORT/${REDIS_PORT}/" placeholder.json.1 > ${orgId}masterRedis.json

 	cp -av ${orgId}masterRedis.json ${PATH_TOUPDATE_FOLDER}

	if [ ${redis_secret} = true ]; then

		if [ ${encode_password} = true ]; then
			REDIS_SECRET=`echo -n ${REDIS_SECRET} | base64`
		        REDIS_SECRET="~@64${REDIS_SECRET}"
		fi

		sed "s/REDIS_SECRET/${REDIS_SECRET}/" pwRedis.json > ${orgId}pwRedis.json

		cp -av ${orgId}pwRedis.json ${PATH_TOUPDATE_FOLDER}

	fi

	if [ ${clear_redis_secret} = true ]; then

		sed "s/REDIS_SECRET//" pwRedis.json > ${orgId}pwRedis.json

		cp -av ${orgId}pwRedis.json ${PATH_TOUPDATE_FOLDER}
	fi
}

redis_secret=false
clear_redis_secret=false
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
			REDIS_PORT="$2"
			shift
			;;
		-pw|--password)
			REDIS_SECRET="$2"
			redis_secret=true
			shift
			;;
		-unencoded|--unencoded)
			encode_password=false
                        ;;
                -cl|--clearpassword)
			clear_redis_secret=true
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


if [ "${MASTER_HOSTNAME}" = "" -o "${REDIS_PORT}" = "" -o "${PATH_TOUPDATE_FOLDER}" = "" ]; then
	logErr "Missing Kubernetes Master Hostname, Redis Port or Path to Update Folder"

	logErr "MASTER_HOSTNAME = ${MASTER_HOSTNAME}"
	logErr "REDIS_PORT = ${REDIS_PORT}"
        logErr "PATH_TOUPDATE_FOLDER = ${PATH_TOUPDATE_FOLDER}"

	logErr ""

	usage

	exit 5
fi

if [ ${redis_secret} = true -a ${clear_redis_secret} = true ]; then
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
logIt "	1. Log in to WAS. Browse to Applications "
logIt "	2. Restart Common"
logIt "	3. Restart News"
logIt " "
echo "Clean exit"
exit 0
