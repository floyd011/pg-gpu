FROM docker.io/nvidia/cuda:13.0.1-devel-rockylinux9

RUN curl -LO https://heterodb.github.io/swdc/yum/rhel9-noarch/heterodb-swdc-1.3-1.el9.noarch.rpm && \
    curl -LO https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    curl -LO https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm && \
    rpm -i heterodb-swdc-1.3-1.el9.noarch.rpm && \
    rpm -i epel-release-latest-9.noarch.rpm && \
    rpm -i pgdg-redhat-repo-latest.noarch.rpm && \
    rm -rf heterodb-swdc-1.3-1.el9.noarch.rpm epel-release-latest-9.noarch.rpm pgdg-redhat-repo-latest.noarch.rpm

RUN dnf -y module disable postgresql && \
    dnf -y install --enablerepo=crb perl-IPC-Run utf8proc-devel gobject-introspection-devel && \
    dnf -y install https://packages.apache.org/artifactory/arrow/almalinux/9/apache-arrow-release-latest.rpm && \
    dnf -y install --enablerepo=crb python3.11 python3.11-pip gcc-c++ redhat-rpm-config make gcc glibc-devel git nano osm2pgsql osmctools mc sudo arrow-devel parquet-devel  && \
    dnf -y install --enablerepo=crb postgresql16-devel postgresql16-server postgis34_16 pg_strom-PG16 postgresql16-contrib postgresql-plpython3 && \
    dnf clean all && dnf clean metadata


RUN echo "postgres ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


ENV PATH /usr/pgsql-16/bin:$PATH
ENV PGDATA /var/lib/pgsql/16/data
ENV PGUSER=postgres
ENV PGPORT=5432
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA"
RUN mkdir -p /opt/osmdata
RUN mkdir -p /opt/osmdata && chown -R postgres:postgres /opt/osmdata && chmod 777 /opt/osmdata

WORKDIR /tmp
RUN git clone --branch v0.8.1 https://github.com/pgvector/pgvector.git && \
   cd pgvector && \
   make  && \
   make install

#RUN git clone https://github.com/timescale/pgai.git --branch extension-0.8.0 && \
 #   cd pgai && \
  #  projects/extension/build.py install

RUN mkdir /docker-entrypoint-initdb.d
COPY postgresql.conf /docker-entrypoint-initdb.d/
COPY pg_hba.conf /docker-entrypoint-initdb.d/
COPY init-db.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/init-db.sh

COPY custom-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/custom-entrypoint.sh
# Set the entrypoint to the custom script
EXPOSE 5432

WORKDIR /app
USER postgres

ENTRYPOINT ["custom-entrypoint.sh"]
# Promenljive okruženja
CMD ["tail" , "-f", "/dev/null"]
