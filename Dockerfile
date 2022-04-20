FROM alpine
ARG JMETER_VERSION="5.4.3"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN  ${JMETER_HOME}/bin
ENV MIRROR_HOST http://mirrors.ocf.berkeley.edu/apache/jmeter
ENV JMETER_DOWNLOAD_URL ${MIRROR_HOST}/binaries/apache-jmeter-${JMETER_VERSION}.tgz
RUN    apk update \
        && apk upgrade \
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
ENV PATH $PATH:$JMETER_BIN
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
WORKDIR	${JMETER_HOME}
ENTRYPOINT ["/entrypoint.sh"]