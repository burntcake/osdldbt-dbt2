FROM ubuntu
# DDBMS=<drizzle|mysql|pgsql|sapdb>
ENV DDBMS=pgsql
ENV PACKAGES_DEPENDENCIES='build-essential cmake postgresql libpq-dev postgresql-server-dev-9.3'
RUN apt-get update && apt-get install -y $PACKAGES_DEPENDENCIES
# COPY . /osdldbt-dbt2
COPY CMakeLists.txt /osdldbt-dbt2/CMakeLists.txt
COPY CPackConfig.cmake /osdldbt-dbt2/CPackConfig.cmake
COPY README /osdldbt-dbt2/README
COPY README-CMAKE /osdldbt-dbt2/README-CMAKE
COPY README-DRIZZLE /osdldbt-dbt2/README-DRIZZLE
COPY README-LINUX /osdldbt-dbt2/README-LINUX
COPY README-MYSQL /osdldbt-dbt2/README-MYSQL
COPY README-PGPOOL /osdldbt-dbt2/README-PGPOOL
COPY README-POSTGRESQL /osdldbt-dbt2/README-POSTGRESQL
COPY README-RHEL /osdldbt-dbt2/README-RHEL
COPY README-SOLARIS /osdldbt-dbt2/README-SOLARIS
COPY README-SQLITE /osdldbt-dbt2/README-SQLITE
COPY bin /osdldbt-dbt2/bin
COPY doc /osdldbt-dbt2/doc
COPY examples /osdldbt-dbt2/examples
COPY src /osdldbt-dbt2/src
COPY storedproc /osdldbt-dbt2/storedproc
WORKDIR osdldbt-dbt2
RUN cmake -DDBMS=$DDBMS -DDESTDIR=/usr/local
RUN make
RUN make install
RUN make -C storedproc/pgsql/c
RUN make -C storedproc/pgsql/c install
WORKDIR /var/lib/postgresql/
USER postgres
RUN PATH=$PATH:/usr/lib/postgresql/9.3/bin/ && . /osdldbt-dbt2/examples/dbt2_profile && dbt2-pgsql-build-db -w 1
CMD PATH=$PATH:/usr/lib/postgresql/9.3/bin/ && . /osdldbt-dbt2/examples/dbt2_profile && dbt2-run-workload -a pgsql -d 300 -w 1 -o /tmp/result -c 10