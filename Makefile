################################################################################
# Variables
################################################################################
.PHONY: default bertha-build alpine-build

default:
	@echo "docker"

# ________________________________________________________________________________
# DEPLOY
# ________________________________________________________________________________
#build: bertha-build alpine-build fdb-build
build: fdb-build
	echo "built"

deploy:
	echo "deploy"
	#docker push lfmunoz4/bertha:${BERTHA_VERSION}
	#docker push lfmunoz4/alpine:${ALPINE_VERSION}
	docker push lfmunoz4/fdb:${FDB_VERSION}

# ________________________________________________________________________________
# FOUNDATIONDB
# 	based on: https://github.com/apple/foundationdb/blob/master/packaging/docker/h
# ________________________________________________________________________________
FDB_VERSION=1.0.0
fdb-build:
	cd foundationdb/build; docker build -t lfmunoz4/fdb:${FDB_VERSION} .
	# cd foundationdb/app; docker build -t lfmunoz4/fdbapp:1.0.0 .

fdb-rm:
	-docker stop fdb
	docker image rm lfmunoz4/fdb:${FDB_VERSION}
	# docker image rm lfmunoz4/fdbapp:1.0.0

fdb-run:
	docker run -d --rm --name fdb -p 4600:4500 lfmunoz4/fdb:${FDB_VERSION}
	# docker run -it --rm --name fdbapp -p 5000:5000 -e FDB_CLUSTER_FILE_CONTENTS="docker:docker@172.17.0.2:4500" lfmunoz4/fdbapp:1.0.0

fdb-start:
	docker start fdb

fdb-stop:
	docker stop fdb


# ________________________________________________________________________________
# BERTHA
# ________________________________________________________________________________
BERTHA_VERSION=1.0.0
bertha-build:
	cd build; docker build -t lfmunoz4/bertha:${BERTHA_VERSION} .

bertha-rm:
	docker image rm lfmunoz4/bertha:${BERTHA_VERSION}

bertha-run:
	docker run --rm -it --name bertha -w /project lfmunoz4/bertha:${BERTHA_VERSION} /bin/bash

bertha-start:
	docker start bertha

bertha-stop:
	docker stop bertha

bertha-pause:
	docker pause bertha

bertha-unpause:
	docker unpause bertha


# ________________________________________________________________________________
# ALPINE
# 	based on: https://github.com/arvindr226/alpine-ssh
# ________________________________________________________________________________
ALPINE_VERSION=1.0.0
alpine-build:
	cd alpine ; docker build -t lfmunoz4/alpine:${ALPINE_VERSION} .

alpine-rm:
	docker image rm lfmunoz4/alpine:${ALPINE_VERSION}

alpine-run:
	docker run -d --rm --name alpine -p 2222:22 lfmunoz4/alpine:${ALPINE_VERSION}

alpine-start:
	docker start alpine

alpine-stop:
	docker stop alpine

alpine-pause:
	docker pause alpine

alpine-unpause:
	docker unpause alpine
