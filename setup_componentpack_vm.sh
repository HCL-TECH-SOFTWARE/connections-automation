#!/bin/bash

internal_host='componentpack.internal'
internal_vagrant_ip='10.172.13.5'
internal_download_port=8001
hostname=$(hostname)

echo "Setting up host name in environments/examples/vagrant/vagrant_componentpack_inventory to ${hostname}"
sed -i '' "s/my-local-hostname/${hostname}/" environments/examples/vagrant/vagrant_componentpack_inventory

cat /etc/hosts | grep ${internal_host} &> /dev/null
if [ "$?" = 0 ]
then
  echo "Host ${internal_host} found in /etc/hosts"
else
  echo "Host ${internal_host} not found in /etc/hosts. Please add it and assign ${internal_vagrant_ip} to it."
  exit 100
fi

cat /etc/hosts | grep ${internal_host} | grep ${internal_vagrant_ip}  &> /dev/null
if [ "$?" = 0 ]
then
  echo "Host ${internal_host} has ${internal_vagrant_ip} assigned. Proceeding..."
else
  echo "Host ${internal_host} does not have ${internal_vagrant_ip} assigned. Please fix it in /etc/hosts"
  exit 101
fi

netstat -na | grep 8001 | grep LISTEN &> /dev/null
if [ "$?" = 0 ]
then
  echo "Port ${internal_download_port} is open. Would be used for downloading the packages during the installation."
else
  echo "Port ${internal_download_port} is not open. If that is used in environments/examples/vagrant/vagrant_componentpack_inventory then your package download will fail. Will continue executing Vagrant in 10 seconds."
  sleep 10
fi

export VAGRANT_VAGRANTFILE=Vagrantfile.componentpack 
vagrant up --provision
