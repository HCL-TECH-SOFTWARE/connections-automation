#!/bin/bash
set -o errexit

# Support different invocation locations associated with this script at different times
support_dir="`dirname \"$0\"`"
echo
cd "${support_dir}" > /dev/null
echo "Changed location to support:"
echo "  `pwd`"
echo "  (relative path:  ${support_dir})"
echo

echo "Configuring NFS..."
touch /etc/exports #If not exist, will create it
cp -n /etc/exports /etc/exports.bkp
IFS='\.' read -a DEC_IP <<< "$(hostname -i)"
VOLUMES=$(cat volumes.txt)
for VOLUME in $VOLUMES; do
 sed -i "/${VOLUME////\\/}/d" /etc/exports
 echo "$VOLUME        ${DEC_IP[0]}.${DEC_IP[1]}.0.0/255.255.0.0(rw,root_squash)" >> /etc/exports
done

echo "NFS is ready to be configured."
