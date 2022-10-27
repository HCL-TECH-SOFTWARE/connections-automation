#!/bin/bash

set -o errexit
set -o pipefail
#set -o xtrace

MASTER_HOSTNAME=""
REDIS_PORT=""
IHS_FQHN=""
REDIS_SECRET=""
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
	logIt "Usage: ./configureRedis.sh [OPTION]"
	logIt "This script will configure IBM Connections for communicating Redis traffic to OrientMe"
	logIt ""
	logIt "Options are:"
	logIt "-m    	| --master		Kubernetes Master Server Hostname/IPAddress : The IP/Hostname of the Kubernetes master server. Required."
	logIt "-po   	| --port		The external port that Redis is running on within Kubernetes. Required."
	logIt "-ic   	| --ic_internal		FQHN of Connections HTTP server.  Include http / https  Required."

	logIt ""
	logIt "-pw   	| --password		Password for Redis Secret.  Must match value in Kubernetes secret.  Optional."
	logIt "-cl   	| --clearpassword	Clear Password for Redis Secret.  Optional. Cannot be used with -pw option."
	logIt "-ic_u	| --ic_user          	IC User with Auth Privlidges to configure the IBM Connections Highway Settings. Optional. If specified, must use -ic_p|--ic_pass option.."
	logIt "-ic_p	| --ic_pass             Password for IC User with Auth Privlidges to configure the IBM Connections Highway Settings. Optional. If specified, must use -ic_u|--ic_user option.."

	logIt ""
	logIt "sample usage (set Redis Host and Redis Port) : ./configureRedis.sh -m <Master Server Hostname/IPAddress> -po <Redis Port> -ic <FQHN of Connections HTTP server> -ic_u wasadmin -ic_p passw0rd"
	logIt ""
	logIt "sample usage (set Redis Host, Redis Port and Redis Password) : ./configureRedis.sh -m <Master Server Hostname/IPAddress> -po <Redis Port> -ic <FQHN of Connections HTTP server> -pw <Redis Secret> -ic_u wasadmin -ic_p passw0rd"
	logIt ""
	logIt "sample usage (Clear Redis Password - needed if disabling redis authenication after it is enabled) : ./configureRedis.sh -m <Master Server Hostname/IPAddress> -po <Redis Port> -ic <FQHN of Connections HTTP server> -cl -ic_u wasadmin -ic_p passw0rd"
	logIt ""




	exit 1
}

configureRedis() {


	auth_command=""
	if [[ ${ic_auth} = true ]]; then
		auth_command="-u ${IC_USER}:${IC_PASS}"
	fi

	echo "Setting c2.export.redis.host"

	confighost_response=`curl --insecure ${auth_command} -w '%{http_code}' --output /dev/null -v -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "settingName=c2.export.redis.host&settingValue=${MASTER_HOSTNAME}" "${IHS_FQHN}/homepage/orgadmin/adminapi.jsp"`

        if [[ ${confighost_response} -ne 200 ]]; then
                logErr "redis config failed. Reason : ${confighost_response}."

		if [ ${ignoreResponseCode} = false ]; then

			if [[ ${confighost_response} -eq 302 ]]; then
				logErr ${errorMsg302}
			fi

			echo "Exiting"
	                exit 2
		else
			echo "Ignoring error. Proceeding."
		fi
        fi

	echo "Setting c2.export.redis.port"

	configport_response=`curl --insecure ${auth_command} -w '%{http_code}' --output /dev/null -v -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "settingName=c2.export.redis.port&settingValue=${REDIS_PORT}" "${IHS_FQHN}/homepage/orgadmin/adminapi.jsp"`

	if [[ ${confighost_response} -ne 200 ]]; then
                logErr "redis config failed. Reason : ${confighost_response}."

                if [ ${ignoreResponseCode} = false ]; then

			if [[ ${confighost_response} -eq 302 ]]; then
                        	logErr ${errorMsg302}
			fi

                        echo "Exiting"
                        exit 2
                else
                        echo "Ignoring error. Proceeding."
                fi
        fi

	if [ ${redis_secret} = true ]; then

		echo "Setting c2.export.redis.pass"

		configpass_response=`curl --insecure ${auth_command} -w '%{http_code}' --output /dev/null -v -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "settingName=c2.export.redis.pass&settingValue=${REDIS_SECRET}" "${IHS_FQHN}/homepage/orgadmin/adminapi.jsp"`

		if [[ ${confighost_response} -ne 200 ]]; then
                	logErr "redis config failed. Reason : ${confighost_response}."

	                if [ ${ignoreResponseCode} = false ]; then

				if [[ ${confighost_response} -eq 302 ]]; then
                        		logErr ${errorMsg302}
				fi

        	                echo "Exiting"
                	        exit 2
	                else
        	                echo "Ignoring error. Proceeding."
                	fi
	        fi
	fi

	if [ ${clear_redis_secret} = true ]; then

		echo "Clearing c2.export.redis.pass"

		configpass_response=`curl --insecure ${auth_command} -w '%{http_code}' --output /dev/null -v -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "settingName=c2.export.redis.pass&settingValue=" "${IHS_FQHN}/homepage/orgadmin/adminapi.jsp"`

		if [[ ${confighost_response} -ne 200 ]]; then
                logErr "redis config failed. Reason : ${confighost_response}."

	                if [ ${ignoreResponseCode} = false ]; then
				if [[ ${confighost_response} -eq 302 ]]; then
					logErr ${errorMsg302}
                                fi

        	                echo "Exiting"
                	        exit 2
	                else
        	                echo "Ignoring error. Proceeding."
                	fi
	        fi
	fi



}

redis_secret=false
clear_redis_secret=false
ic_auth=false
ignoreResponseCode=false
errorMsg302="Received a 302 response.  Possible root cause : You have specified http against a SSL/TLS protected IBM Connections Server. Please re-run the script, ensuring to specify https when setting the -ic parameter, should the IBM Connections Server be SSL/TLS protected."

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
		-ic|--ic_internal)
			IHS_FQHN="$2"
			shift
			;;
		-pw|--password)
			REDIS_SECRET="$2"
			redis_secret=true
			shift
			;;
		-cl|--clearpassword)
			clear_redis_secret=true
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


if [ "${MASTER_HOSTNAME}" = "" -o "${REDIS_PORT}" = "" -o "${IHS_FQHN}" = "" ]; then
	logErr "Missing Kubernetes Master Hostname, Redis Port, or IC HTTP server definitions"

	logErr "MASTER_HOSTNAME = ${MASTER_HOSTNAME}"
	logErr "REDIS_PORT = ${REDIS_PORT}"
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

if [ ${redis_secret} = true -a ${clear_redis_secret} = true ]; then
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
	configureRedis

) 2>&1 | tee -a /var/log/configureRedis.log


echo "Clean exit"
exit 0
