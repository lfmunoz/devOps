################################################################################
# Variables
################################################################################
.PHONY: default bertha-build alpine-build

default:
	@echo "docker"

# ________________________________________________________________________________
# DEPLOY
# ________________________________________________________________________________
build: bertha-build alpine-build
	echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

deploy:
	docker push lfmunoz/bertha:${BERTHA_VERSION}

# ________________________________________________________________________________
# BERTHA
# ________________________________________________________________________________
BERTHA_VERSION=1.0.0
bertha-build:
	cd build; docker build -t lfmunoz/bertha:${BERTHA_VERSION} .

bertha-rm:
	docker image rm lfmunoz/bertha:${BERTHA_VERSION}

bertha-run:
	docker run --rm -it --name bertha -w /project lfmunoz/bertha:${BERTHA_VERSION} /bin/bash

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
	cd alpine ; docker build -t lfmunoz/alpine:${ALPINE_VERSION} .

alpine-rm:
	docker image rm lfmunoz/alpine:${ALPINE_VERSION}

alpine-run:
	docker run -d --name alpine -p 2222:22 lfmunoz/alpine:${ALPINE_VERSION}

alpine-start:
	docker start alpine

alpine-stop:
	docker stop alpine

alpine-pause:
	docker pause alpine

alpine-unpause:
	docker unpause alpine
