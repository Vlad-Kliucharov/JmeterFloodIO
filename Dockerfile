FROM alpine
ARG JMETER_VERSION="5.5"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN ${JMETER_HOME}/bin
ARG JMETER_PLUGINS_MANAGER_VERSION="1.6"
ENV JMETER_LIB_FOLDER ${JMETER_HOME}/lib/
ENV JMETER_PLUGINS_FOLDER ${JMETER_LIB_FOLDER}/ext/
ENV MIRROR_HOST http://mirrors.ocf.berkeley.edu/apache/jmeter
ENV JMETER_DOWNLOAD_URL ${MIRROR_HOST}/binaries/apache-jmeter-${JMETER_VERSION}.tgz
RUN     apk update \
        && apk upgrade \
        && apk add dos2unix \
        && apk add ca-certificates \
        && update-ca-certificates \
        && apk add --update openjdk8-jre tzdata curl unzip bash \
        && echo "Europe/Kyiv" >  /etc/timezone \
        && rm -rf /var/cache/apk/* \
        && mkdir -p /tmp/dependencies  \
        && curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
        && mkdir -p /opt  \
        && tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt \
        && rm -rf /tmp/dependencies
WORKDIR ${JMETER_PLUGINS_FOLDER}
RUN wget https://github.com/sfakrudeen78/JMeter-InfluxDB-Writer/releases/download/v-1.2.2/JMeter-InfluxDB-Writer-plugin-1.2.2.jar
ENV PATH $PATH:$JMETER_BIN
WORKDIR ${JMETER_HOME}
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]