####
#### Build stage - downloads dependencies using maven
####
FROM maven:3.6-openjdk-11

WORKDIR /tmp/build

# Versions of Hazelcast Jet and Hazelcast IMDG plugins
ARG JET_VERSION=4.1
ARG CACHE_API_VERSION=1.1.1
ARG HZ_EUREKA_VERSION=2.0.1
ARG JMX_PROMETHEUS_AGENT_VERSION=0.12.0

ADD dependency-copy.xml /tmp/build/

# Download and install Hazelcast Jet and Hazelcast plugins
#(hazelcast-eureka, jcache-api and prometheus agent) with dependencies
RUN mvn -f dependency-copy.xml \
      -Dhazelcast-eureka-version=${HZ_EUREKA_VERSION} \
      -Dhazelcast-jet-version=${JET_VERSION} \
      -Djcache-version=${CACHE_API_VERSION} \
      -Dprometheus-java-version=${JMX_PROMETHEUS_AGENT_VERSION} \
      dependency:copy-dependencies \
      dependency:unpack && \
      mv hazelcast-jet-enterprise-${JET_VERSION} hazelcast-jet-enterprise && \
      chmod -R +r .

####
#### Final stage - creates final image
####
FROM openjdk:11.0.7-jre-slim

ARG JET_HOME="/opt/hazelcast-jet-enterprise"
# Needs to be duplicated in both stages
ARG JMX_PROMETHEUS_AGENT_VERSION=0.12.0

COPY --from=0 /tmp/build/hazelcast-jet-enterprise ${JET_HOME}/
COPY log4j2.properties jmx_agent_config.yaml ${JET_HOME}/config/
RUN echo 'hazelcastDownloadId=docker' > "${JET_HOME}/lib/hazelcast-download.properties"

ENV PATH=$JET_HOME/bin:$PATH \
 CLASSPATH_DEFAULT="" \
 CLASSPATH="" \
 JAVA_OPTS_DEFAULT="-Djava.net.preferIPv4Stack=true -XX:MaxRAMPercentage=80.0" \
 JAVA_OPTS="" \
 JET_HOME=$JET_HOME \
 JET_MODULES="" \
 JET_LICENSE_KEY="" \
 LOGGING_LEVEL="info" \
 PROMETHEUS_PORT="" \
 PROMETHEUS_AGENT_VERSION="$JMX_PROMETHEUS_AGENT_VERSION" \
 PROMETHEUS_CONFIG=$JET_HOME/config/jmx_agent_config.yaml

### Expose port
EXPOSE 5701

# Start Hazelcast Jet server
CMD ["bash", "-c", "set -euo pipefail \
      && if [[ \"x${CLASSPATH}\" != \"x\" ]]; then export CLASSPATH=\"${CLASSPATH}:${CLASSPATH_DEFAULT}\"; else export CLASSPATH=\"${CLASSPATH_DEFAULT}\"; fi \
      && if [[ \"x${JAVA_OPTS}\" != \"x\" ]]; then export JAVA_OPTS=\"${JAVA_OPTS_DEFAULT} ${JAVA_OPTS}\"; else export JAVA_OPTS=\"${JAVA_OPTS_DEFAULT}\"; fi \
      && if [[ \"x${JET_LICENSE_KEY}\" != \"x\" ]]; then export JAVA_OPTS=\"-Dhazelcast.enterprise.license.key=${JET_LICENSE_KEY} ${JAVA_OPTS} \"; fi \
      && if [[ \"x${PROMETHEUS_PORT}\" != \"x\" ]]; then export JAVA_OPTS=\"-javaagent:${JET_HOME}/lib/jmx_prometheus_javaagent-$PROMETHEUS_AGENT_VERSION.jar=${PROMETHEUS_PORT}:${PROMETHEUS_CONFIG} ${JAVA_OPTS} \"; fi \
      && set -x \
      && jet-start \
     "]
