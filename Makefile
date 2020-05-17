################################################################################
# Variables
################################################################################
.PHONY: default bertha-build alpine-build

default:
	@echo "docker"

# ________________________________________________________________________________
# DEPLOY
# ________________________________________________________________________________
#build: bertha-build alpine-build
build: 
	echo "build disabled"

deploy:
	echo "deploy disabled"
	#docker push lfmunoz4/bertha:${BERTHA_VERSION}
	#docker push lfmunoz4/alpine:${ALPINE_VERSION}

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
	docker run -d --name alpine -p 2222:22 lfmunoz4/alpine:${ALPINE_VERSION}

alpine-start:
	docker start alpine

alpine-stop:
	docker stop alpine

alpine-pause:
	docker pause alpine

alpine-unpause:
	docker unpause alpine
