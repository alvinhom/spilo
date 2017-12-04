#!/bin/bash

DOCKER_IP=$(hostname --ip-address)

haproxy -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid -D
CONFD="confd -prefix=/service/$SCOPE -interval=10 -backend"

# parse the ETCD_HOSTS var and split into confd options -node host
array=($(echo "$ETCD_HOSTS" | tr ',' '\n'))
opts=""
for i in "${!array[@]}"
do
    p=" -node ${array[i]}"
    opts=$opts$p
done

echo "$opts"

array=($(echo "$ETCD_HOSTS" | tr ',' '\n'))
while true
do
   for i in "${!array[@]}"
   do
      h1=${array[i]}
      echo $h1
      if curl -s --cacert ${ETCD_CACERT} "$h1"/v2/members | jq -r '.members[0].clientURLs[0]' | grep -q http; then
         echo "found etcd member ${array[i]}"
         break 2
      else
        sleep 1
      fi
   done
done

#while ! curl -s --cacert ${ETCD_CACERT} ${ETCD_HOST}/v2/members | jq -r '.members[0].clientURLs[0]' | grep -q http; do
#    sleep 1
#done
exec $CONFD etcd $opts
