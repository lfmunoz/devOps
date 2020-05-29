FROM ubuntu:18.04
MAINTAINER Luis Munoz <lfmunoz4@gmail.com>

ARG FDB_VERSION="6.2.19"
ARG FDB_WEBSITE="https://www.foundationdb.org"

WORKDIR /root
COPY start.bash /root

# Install dependencies
RUN set -eux; \
	\
	apt-get update; \
	apt-get install --yes --no-install-recommends \
	ca-certificates \
	dnsutils \
	curl; \
	rm -r /var/lib/apt/lists/*; \
	\
	curl $FDB_WEBSITE/downloads/$FDB_VERSION/ubuntu/installers/foundationdb-clients_$FDB_VERSION-1_amd64.deb -o fdb-clients-$FDB_VERSION.deb; \
    curl $FDB_WEBSITE/downloads/$FDB_VERSION/ubuntu/installers/foundationdb-server_$FDB_VERSION-1_amd64.deb -o fdb-servers-$FDB_VERSION.deb; \
	dpkg -i fdb-clients-$FDB_VERSION.deb; \
    dpkg -i fdb-servers-$FDB_VERSION.deb; \
    rm -rf /root/*.deb; \
	\
	chmod +x /root/start.bash

EXPOSE 4500
CMD /root/start.bash




