

# FoundationDb Image


Reference: https://apple.github.io/foundationdb/index.html

Dockerfile based on: https://github.com/apple/foundationdb/blob/master/packaging/docker/Dockerfile

Image Size: 328MB

FoundationDB Requirements: 
* 4GiB RAM per FoundationDB server process


WARNING: The default docker bridge network has automatic DNS resolution disabled to maintain container isolation. 
In other words "ping containerName" or "dig containerName" will not work when using the default bridge network


* Data location: /var/lib/foundationdb/data/$ID
* Logs location: /var/log/foundationdb
* Config location: /etc/foundationdb/foundationdb.conf
* Cluster file location: /etc/foundationdb/fdb.cluster


### Cluster File

The difficulty in dockerizing FoundationDB is the cluster file:

The cluster file contains a connection string consisting of a cluster identifier and a comma-separated list of IP addresses (not hostnames) specifying the coordination servers. The format for the file is:

```
description:ID@IP:PORT,IP:PORT,..
```

This means you must know the public IP of all the machines in the cluster before starting any of the docker images


### Other Details

The fdbserver server process is run and monitored on each server by the fdbmonitor daemon.
fdbmonitor and fdbserver itself are controlled by the foundationdb.conf file located at:
/etc/foundationdb/foundationdb.conf 

Whenever the foundationdb.conf file changes, the fdbmonitor daemon automatically detects the changes 
and starts, stops, or restarts child processes as necessary.

* Ext4 filesystems should be mounted with mount options defaults,noatime,discard.
* fdbmonitor doesn’t open any network connections. 
* Each fdbserver process opens exactly one port


/etc/foundationdb/foundationdb.conf should have a [fdbserver.<ID>]  sections for each core.
 and remember 4GiB ECC RAM are required per FoundationDB server process


```
## EXAMPLE
## foundationdb.conf 
##
## Configuration file for FoundationDB server processes

[fdbmonitor]
user = foundationdb
group = foundationdb

[general]
cluster_file = /etc/foundationdb/fdb.cluster
# The maximum number of seconds that fdbmonitor will delay before restarting a failed process.
restart_delay = 60
# how quickly fdbmonitor backs off when a process dies repeatedly.
restart_backoff = 60.0
# processes will be restarted whenever the configuration file changes.
kill_on_configuration_change = true
# write log events when processes start or terminate
disable_lifecycle_logging = false

## restart_backoff and restart_delay_reset_interval default to the value that is used for restart_delay
# initial_restart_delay = 0
# restart_delay_reset_interval = 60

## Default parameters for individual fdbserver processes
[fdbserver]
# The location of the fdbserver binary.
command = /usr/sbin/fdbserver
# The publicly visible IP:Port of the process.
public_address = auto:$ID
# The IP:Port that the server socket should bind to
# If public, it will be the same as the public_address.
listen_address = public
datadir = /var/lib/foundationdb/data/$ID
logdir = /var/log/foundationdb
# logsize = 10MiB
# maxlogssize = 100MiB
# class =
# memory = 8GiB
# storage_memory = 1GiB
# cache_memory = 2GiB
# locality_machineid =
# locality_zoneid =
# locality_data_hall =
# locality_dcid =
# io_trust_seconds = 20


## An individual fdbserver process with id 4500
## Parameters set here override defaults from the [fdbserver] section
[fdbserver.4500]

[backup_agent]
command = /usr/lib/foundationdb/backup_agent/backup_agent

[backup_agent.1]

```


# Application Image Example (Python)

Reference: https://github.com/apple/foundationdb/tree/master/packaging/docker/samples/python

```
# retrieve counter
curl http://0.0.0.0:5000/counter # 0

# increment counter
curl -X POST http://0.0.0.0:5000/counter/increment # 1
curl -X POST http://0.0.0.0:5000/counter/increment # 2

# retrieve counter
curl http://0.0.0.0:5000/counter # 2
```

