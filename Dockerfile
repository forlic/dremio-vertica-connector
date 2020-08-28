FROM openjdk:8-jdk as run

LABEL org.label-schema.name='dremio/dremio-oss'
LABEL org.label-schema.description='Dremio OSS.'

ARG DOWNLOAD_URL=http://download.dremio.com/community-server/4.7.2-202008180758160892-1a34c463/dremio-community-4.7.2-202008180758160892-1a34c463.tar.gz
RUN \
  mkdir -p /opt/dremio \
  && mkdir -p /var/lib/dremio \
  && mkdir -p /var/run/dremio \
  && mkdir -p /var/log/dremio \
  && mkdir -p /opt/dremio/data \
  \
  && groupadd --system dremio \
  && useradd --base-dir /var/lib/dremio --system --gid dremio dremio \
  && chown -R dremio:dremio /opt/dremio/data \
  && chown -R dremio:dremio /var/run/dremio \
  && chown -R dremio:dremio /var/log/dremio \
  && chown -R dremio:dremio /var/lib/dremio \
  && wget -q "${DOWNLOAD_URL}" -O dremio.tar.gz \
  && tar vxfz dremio.tar.gz -C /opt/dremio --strip-components=1 \
  && rm -rf dremio.tar.gz

COPY ./target/dremio-verticaarp-plugin-4.5.jar /opt/dremio/jars
ADD https://www.vertica.com/client_drivers/10.0.x/10.0.0-0/vertica-jdbc-10.0.0-0.jar /opt/dremio/jars/3rdparty
RUN chmod 664 /opt/dremio/jars/3rdparty/vertica-jdbc-10.0.0-0.jar 
COPY ./logback.xml /opt/dremio/conf

EXPOSE 9047/tcp
EXPOSE 31010/tcp
EXPOSE 45678/tcp

USER dremio
WORKDIR /opt/dremio
ENV DREMIO_HOME /opt/dremio
ENV DREMIO_PID_DIR /var/run/dremio
ENV DREMIO_GC_LOGS_ENABLED="no"
ENV DREMIO_LOG_DIR="/var/log/dremio"
ENV SERVER_GC_OPTS="-XX:+PrintGCDetails -XX:+PrintGCDateStamps"
ENTRYPOINT ["bin/dremio", "start-fg"]
