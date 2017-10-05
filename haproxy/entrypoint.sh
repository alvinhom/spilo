#!/bin/bash

DOCKER_IP=$(hostname --ip-address)

haproxy -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid -D
CONFD="confd -prefix=/service/$SCOPE -interval=10 -backend"
while ! curl -s ${ETCD_HOST}/v2/members | jq -r '.members[0].clientURLs[0]' | grep -q http; do
    sleep 1
done
exec $CONFD etcd -node $ETCD_HOST
