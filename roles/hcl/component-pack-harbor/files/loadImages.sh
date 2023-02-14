#!/bin/bash

set -o errexit
set -o pipefail

DOCKER_REGISTRY=""

usage() {
    echo -e "This script will load, tag and push the required docker images;\n"
    echo -e "Usage: ./loadImages.sh [OPTION];\n"
    echo -e "Required options:\n"
    echo -e "-dr       | --dockerRegistry      Name of the Docker registry. Required.;\n"
    echo -e "-u        | --user                Docker registry user. Required.\n"
    echo -e "-p        | --password            Docker registry user password. Required.\n"
    exit 1
}

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
            -dr|--dockerRegistry)
                    if [ -z "$2" ]; then
                            echo "ERROR: You must pass a docker registry value when using the flags -dr or --dockerRegistry"
                            usage
                            exit 1
                    fi
                    DOCKER_REGISTRY="$2"
                    shift
                    ;;
            -u|--user)
                    if [ -z "$2" ]; then
                            echo "ERROR: You must pass a username when using the flags -u or --user"
                            usage
                            exit 1
                    fi
                    USER="$2"
                    shift
                    ;;
            -p|--password)
                    if [ -z "$2" ]; then
                            echo "ERROR: You must pass a password when using the flags -p or --password"
                            usage
                            exit 1
                    fi
                    PASSWORD="$2"
                    shift
                    ;;
    esac
    shift
done

if [ "${DOCKER_REGISTRY}" = "" -o "${USER}" = "" -o "${PASSWORD}" = "" ]; then
    echo "ERROR: Missing either Docker registry, user or password definitions."
    echo ""
    usage
    exit 1
fi

# login to docker registry
docker login -u ${USER} -p ${PASSWORD} ${DOCKER_REGISTRY}
l_status=$?

if [ $l_status -ne 0 ]; then
        echo "login to ${DOCKER_REGISTRY} failed!!!"
        exit 127
fi

	if [[ ${DOCKER_REGISTRY} == *"amazonaws.com" ]]; then
	repos=(
               admin-portal
               analysis-service
               appregistry-client
               appregistry-service
               bootstrap
               mongodb5-sidecar
               connections-outlook-desktop
               community-suggestions
               community-template-service
               middleware-haproxy
               minio
               indexing-service
               itm-services
               kudosboards-boards
               kudosboards-core
               kudosboards-boards-event
               kudosboards-licence
               kudosboards-notification
               kudosboards-provider
               kudosboards-user
               kudosboards-webfront
               middleware-graphql
               middleware-jsonapi
               middleware-mongodb5
               middleware-mongodb5-sidecar
               mw-proxy
               opensearch
               kudosboards-activity-migration
               orient-web-client
               people-idmapping
               people-datamigration
               people-relationship
               people-scoring
               middleware-redis-sentinel
               middleware-redis
               retrieval-service
               te-creation-wizard
               teams-share-service
               teams-share-ui
               teams-tab-api
               teams-tab-ui
               )
	for repo in ${repos[@]} ; do
		aws ecr describe-repositories --repository-names ${repo} --region $(echo ${DOCKER_REGISTRY} | cut -d. -f4) || aws ecr create-repository --repository-name $repo --region 		$(echo ${DOCKER_REGISTRY} | cut -d. -f4)
        done
	fi

load_images() {
    if [ "$1" = "" ]; then
        echo "usage:  load_images imageTar"
        exit 100
    fi

    echo "Loading $1 ..."
    docker load -i $1
}

# loop through the images directory to load the images to docker
cd images
arr=(*.tar)
for f in "${arr[@]}"; do
    load_images $f
done


# retag and push to local registry
tag_and_push_all () {
    IFS=$'\n'
    all_hclcr_tags=$(docker images "hclcr.io\/cnx\/*" --format "{{.Repository}}:{{.Tag}}")

    for tag in $all_hclcr_tags; do
        if [[ $tag != *"IMAGE ID"* ]]; then
            newtag=$(echo $tag | sed 's/hclcr.io\/cnx\//'${DOCKER_REGISTRY}'\//')
            echo "retag $tag to $newtag"
            docker tag $tag $newtag
            docker push $newtag
        fi
    done

}

tag_and_push_all

echo -e "\nClean exit\n"
exit 0
