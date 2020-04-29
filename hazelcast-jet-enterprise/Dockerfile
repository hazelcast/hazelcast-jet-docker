FROM openjdk:8u201-jre-alpine

# Versions of Hazelcast Jet and Hazelcast IMDG plugins
ARG JET_VERSION=4.1
ARG CACHE_API_VERSION=1.1.1
ARG HZ_EUREKA_VERSION=1.1.2
ARG JMX_PROMETHEUS_AGENT_VERSION=0.12.0

# Build constants
ARG JET_HOME="/opt/hazelcast-jet-enterprise"
ARG JET_JAR="hazelcast-jet-enterprise-${JET_VERSION}.jar"
ARG CACHE_API_JAR="cache-api-${CACHE_API_VERSION}.jar"
ARG HZ_AWS_API_JAR="hazelcast-aws-${HZ_AWS_VERSION}.jar"

# Install bash & curl
RUN apk add --no-cache bash curl \
 && rm -rf /var/cache/apk/*

# Set up build directory
RUN mkdir -p ${JET_HOME}
WORKDIR ${JET_HOME}

# Download and install Hazelcast Jet Enterprise and Hazelcast plugins
# (hazelcast-eureka, jcache-api and prometheus agent) with dependencies
# Use Maven Wrapper to fetch dependencies specified in mvnw/dependency-copy.xml
RUN curl -svf -o ${JET_HOME}/maven-wrapper.tar.gz \
         -L https://github.com/takari/maven-wrapper/archive/maven-wrapper-0.3.0.tar.gz \
 && tar zxf maven-wrapper.tar.gz \
 && rm -fr maven-wrapper.tar.gz \
 && mv maven-wrapper* mvnw
COPY mvnw ${JET_HOME}/mvnw
RUN cd mvnw \
 && chmod +x mvnw \
 && sync \
 && ./mvnw -f dependency-copy.xml \
           -Dhazelcast-eureka-version=${HZ_EUREKA_VERSION} \
           -Dhazelcast-jet-version=${JET_VERSION} \
           -Djcache-version=${CACHE_API_VERSION} \
           -Dprometheus-java-version=${JMX_PROMETHEUS_AGENT_VERSION} \
           dependency:copy-dependencies \
           dependency:unpack \
 && cd .. \
 && rm -rf $JET_HOME/mvnw \
 && rm -rf ~/.m2 \
 && chmod -R +r $JET_HOME \
 && mv $JET_HOME/hazelcast-jet-enterprise-$JET_VERSION/* $JET_HOME/ \
 && rm -rf $JET_HOME/hazelcast-jet-enterprise-$JET_VERSION

COPY jmx_agent_config.yaml ${JET_HOME}/jmx_agent_config.yaml
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
