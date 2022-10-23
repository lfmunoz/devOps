
FROM foundationdb/foundationdb:6.2.19 as fdb
FROM python:3.8

COPY --from=fdb /usr/lib/libfdb_c.so /usr/lib
COPY --from=fdb /usr/bin/fdbcli /usr/bin

RUN apt-get update; \
    apt-get install -y dnsutils; \ 
    mkdir -p /app

WORKDIR /app

COPY requirements.txt /app
COPY start.bash /app
COPY server.py /app

RUN pip install -r requirements.txt; \
    chmod +x /app/server.py; \
    chmod +x /app/start.bash

ENV FDB_VERSION 6.2.19
ENV FDB_API_VERSION 620

CMD /app/start.bash
