FROM registry.access.redhat.com/ubi8/ubi
MAINTAINER Hazelcast, Inc. Jet Integration Team <info@hazelcast.com>

ENV USER_NAME="jet" \
      USER_UID=10001

# Versions of Hazelcast Jet and Hazelcast IMDG plugins
ARG JET_VERSION=4.1
ARG CACHE_API_VERSION=1.1.1
ARG HZ_EUREKA_VERSION=2.0.1
ARG JMX_PROMETHEUS_AGENT_VERSION=0.14.0

# Build constants
ARG JET_HOME="/opt/hazelcast-jet-enterprise"
ARG JET_JAR="hazelcast-jet-enterprise-${JET_VERSION}.jar"
ARG CACHE_API_JAR="cache-api-${CACHE_API_VERSION}.jar"

LABEL name="hazelcast/hazelcast-jet-enterprise-openshift-rhel" \
      vendor="Hazelcast, Inc." \
      version="8.1" \
      architecture="x86_64" \
      release="${JET_VERSION}" \
      url="http://www.hazelcast.com" \
      summary="Hazelcast Jet Enterprise Openshift Image, certified to RHEL 8" \
      description="Starts a standalone Hazelcast Jet Enterprise server instance to form a cluster based on kubernetes discovery inside Openshift" \
      io.k8s.description="Starts a standalone Hazelcast Jet Enterprise server instance to form a cluster based on kubernetes discovery inside Openshift" \
      io.k8s.display-name="Hazelcast Jet Enterprise" \
      io.openshift.expose-services="5701:tcp" \
      io.openshift.tags="jet,java8,kubernetes,rhel8"

COPY licenses /licenses
COPY description.md /tmp/
COPY mvnw ${JET_HOME}/mvnw

RUN mkdir -p ${JET_HOME} && \
      ### Disable subscription-manager plugin to prevent redundant logs
      sed -i 's/^enabled=.*/enabled=0/g' /etc/dnf/plugins/subscription-manager.conf && \
      dnf config-manager --disable && \
      dnf update -y  && rm -rf /var/cache/dnf && \
      dnf -y update-minimal --security --sec-severity=Important --sec-severity=Critical --setopt=tsflags=nodocs && \
      ### Add your package needs to this installation line
      dnf -y --setopt=tsflags=nodocs install java-1.8.0-openjdk-devel apr openssl &> /dev/null && \
      ### Install go-md2man to help markdown to man conversion
      dnf -y --setopt=tsflags=nodocs install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm &> /dev/null && \
      dnf -y --setopt=tsflags=nodocs install golang-github-cpuguy83-go-md2man &> /dev/null && \
      go-md2man -in /tmp/description.md -out /help.1 && \
      dnf -y remove golang-github-cpuguy83-go-md2man && \
      dnf -y clean all 

WORKDIR ${JET_HOME}

# Download and install Hazelcast Jet Enterprise and Hazelcast plugins
# (hazelcast-eureka, jcache-api and prometheus agent) with dependencies
RUN cd mvnw && \
      chmod +x mvnw && \
      sync && \
      ./mvnw -B -f dependency-copy.xml \
      -Dhazelcast-eureka-version=${HZ_EUREKA_VERSION} \
      -Dhazelcast-jet-version=${JET_VERSION} \
      -Djcache-version=${CACHE_API_VERSION} \
      -Dprometheus-java-version=${JMX_PROMETHEUS_AGENT_VERSION} \
      dependency:copy-dependencies \
      dependency:unpack && \
      cd .. && \
      rm -rf $JET_HOME/mvnw && \
      rm -rf ~/.m2 && \
      useradd -l -u $USER_UID -r -g 0 -d $JET_HOME -s /sbin/nologin -c "${USER_UID} application user" $USER_NAME && \
      chown -R $USER_UID:0 $JET_HOME && \
      chmod -R g=u "$JET_HOME" && \
      chmod -R +r $JET_HOME && \
      mv $JET_HOME/hazelcast-jet-enterprise-$JET_VERSION/* $JET_HOME/ && \
      rm -rf $JET_HOME/hazelcast-jet-enterprise-$JET_VERSION

COPY jmx_agent_config.yaml ${JET_HOME}/jmx_agent_config.yaml
COPY hazelcast.yaml ${JET_HOME}/config/hazelcast.yaml
COPY log4j2.properties ${JET_HOME}/config/log4j2.properties

# Runtime constants
ENV CLASSPATH_DEFAULT "${JET_HOME}:${JET_HOME}/*:${JET_HOME}/lib:${JET_HOME}/lib/*"
ENV JAVA_OPTS_DEFAULT "-Djava.net.preferIPv4Stack=true -Dhazelcast.logging.type=log4j2 -Dlog4j.configurationFile=file:$JET_HOME/config/log4j2.properties -Djet.home=$JET_HOME -Dhazelcast.config=$JET_HOME/config/hazelcast.yaml -Dhazelcast.client.config=$JET_HOME/config/hazelcast-client.yaml -Dhazelcast.jet.config=$JET_HOME/config/hazelcast-jet.yaml"

# Runtime environment variables
ENV JET_HOME $JET_HOME
ENV CLASSPATH ""
ENV JAVA_OPTS ""
ENV JET_LICENSE_KEY ""
ENV JET_LICENCE_KEY ""
ENV PATH $JET_HOME/bin:$PATH
ENV LOGGING_LEVEL ""
ENV PROMETHEUS_PORT ""
ENV PROMETHEUS_CONFIG $JET_HOME/jmx_agent_config.yaml

### Switch to jet user
USER $USER_UID

### Expose port
EXPOSE 5701

# Start Hazelcast Jet Enterprise server
CMD ["bash", "-c", "set -euo pipefail \
      && eval JAVA_OPTS=\\\"${JAVA_OPTS}\\\" \
      && eval CLASSPATH=\\\"${CLASSPATH}\\\" \
      && if [[ \"x${CLASSPATH}\" != \"x\" ]]; then export CLASSPATH=\"${CLASSPATH}:${CLASSPATH_DEFAULT}\"; else export CLASSPATH=\"${CLASSPATH_DEFAULT}\"; fi \
      && if [[ \"x${JAVA_OPTS}\" != \"x\" ]]; then export JAVA_OPTS=\"${JAVA_OPTS_DEFAULT} ${JAVA_OPTS}\"; else export JAVA_OPTS=\"${JAVA_OPTS_DEFAULT}\"; fi \
      && if [[ \"x${PROMETHEUS_PORT}\" != \"x\" ]]; then export JAVA_OPTS=\"-javaagent:${JET_HOME}/lib/jmx_prometheus_javaagent.jar=${PROMETHEUS_PORT}:${PROMETHEUS_CONFIG} ${JAVA_OPTS} \"; fi \
      && if [[ \"x${JET_LICENSE_KEY}\" != \"x\" ]]; then export JAVA_OPTS=\"-Dhazelcast.enterprise.license.key=${JET_LICENSE_KEY} ${JAVA_OPTS} \"; fi \
      && if [[ \"x${JET_LICENCE_KEY}\" != \"x\" ]]; then export JAVA_OPTS=\"-Dhazelcast.enterprise.license.key=${JET_LICENCE_KEY} ${JAVA_OPTS} \"; fi \
      && if [[ \"x${LOGGING_LEVEL}\" != \"x\" ]]; then sed -i \"s/logger.jet.level=info/logger.jet.level=${LOGGING_LEVEL}/g;s/rootLogger.level=info/rootLogger.level=${LOGGING_LEVEL}/g\" $JET_HOME/config/log4j2.properties; fi \
      && echo \"########################################\" \
      && echo \"# JAVA_OPTS=${JAVA_OPTS}\" \
      && echo \"# CLASSPATH=${CLASSPATH}\" \
      && echo \"# starting now....\" \
      && echo \"########################################\" \
      && set -x \
      && exec java -server ${JAVA_OPTS} com.hazelcast.jet.server.JetMemberStarter \
      "]
