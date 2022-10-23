#! /bin/bash


FDB_CLUSTER_FILE=${FDB_CLUSTER_FILE:-/etc/foundationdb/fdb.cluster}
mkdir -p $(dirname $FDB_CLUSTER_FILE)

if [[ -n "$FDB_CLUSTER_FILE_CONTENTS" ]]; then
	echo "$FDB_CLUSTER_FILE_CONTENTS" > $FDB_CLUSTER_FILE
elif [[ -n $FDB_COORDINATOR ]]; then
	coordinator_ip=$(dig +short $FDB_COORDINATOR)
	if [[ -z "$coordinator_ip" ]]; then
		echo "Failed to look up coordinator address for $FDB_COORDINATOR" 1>&2
		exit 1
	fi
	coordinator_port=${FDB_COORDINATOR_PORT:-4500}
	echo "docker:docker@$coordinator_ip:$coordinator_port" > $FDB_CLUSTER_FILE
else
	echo "docker:docker@127.0.0.1:4500" > $FDB_CLUSTER_FILE
fi


service foundationdb start ; sleep 3
fdbcli --exec "configure new single memory ; status"
tail -f /var/log/foundationdb/*

