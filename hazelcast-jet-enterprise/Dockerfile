FROM alpine:3.11

# Versions of Hazelcast Jet and Hazelcast IMDG plugins
ARG JET_VERSION=4.1-SNAPSHOT
ARG CACHE_API_VERSION=1.1.1
ARG HZ_EUREKA_VERSION=1.1.2
ARG JMX_PROMETHEUS_AGENT_VERSION=0.12.0

# Build constants
ARG JET_HOME="/opt/hazelcast-jet-enterprise"
ARG JET_INSTALL_NAME="hazelcast-jet-enterprise-${JET_VERSION}"
ARG JET_JAR="hazelcast-jet-enterprise-${JET_VERSION}.jar"
ARG JET_ZIP="hazelcast-jet-enterprise-${JET_VERSION}.zip"

# Install bash & curl
RUN echo "Updating Alpine system" \
    && apk upgrade --update-cache --available \
    && echo "Installing new APK packages" \
    && apk add openjdk11-jre maven bash curl procps nss \
    && rm -rf /var/cache/apk/*

# Set up build directory
RUN mkdir -p ${JET_HOME}
COPY *.xml *.yaml ${JET_HOME}/
WORKDIR ${JET_HOME}

# Download & install Hazelcast Jet
RUN curl -svf -o ${JET_HOME}/${JET_ZIP} \
         -L https://jet-test-env.s3.amazonaws.com/${JET_ZIP} \
 && unzip ${JET_ZIP} \
         -x ${JET_INSTALL_NAME}/code-samples/* \
         -x ${JET_INSTALL_NAME}/demo/* \
         -x ${JET_INSTALL_NAME}/docs/* \
 && rm -rf ${JET_ZIP} \
 && mv $JET_HOME/${JET_INSTALL_NAME}/* $JET_HOME/ \
 && rm -rf $JET_HOME/${JET_INSTALL_NAME}/


# Download and install Hazelcast plugins (hazelcast-kubernetes and hazelcast-eureka) with dependencies
# Use Maven Wrapper to fetch dependencies specified in mvnw/dependency-copy.xml
RUN mvn -f dependency-copy.xml \
      -Dhazelcast-eureka-version=${HZ_EUREKA_VERSION} \
      -Dhazelcast-jet-version=${JET_VERSION} \
      -Djcache-version=${CACHE_API_VERSION} \
      -Dprometheus-java-version=${JMX_PROMETHEUS_AGENT_VERSION} \
      dependency:copy-dependencies \
 && echo "Maven clean-up" \
 && apk del maven \
 && rm -rf ~/.m2 \
 && rm -f dependency-copy.xml \
 && chmod -R +r $JET_HOME \ 
 && cp -r $JET_HOME/$JET_INSTALL_NAME/lib/* $JET_HOME/lib \
 && rm -rf $JET_HOME/$JET_INSTALL_NAME/

# Runtime constants
ENV CLASSPATH_DEFAULT "${JET_HOME}:${JET_HOME}/*:${JET_HOME}/lib:${JET_HOME}/lib/*"
ENV JAVA_OPTS_DEFAULT "-Djava.net.preferIPv4Stack=true"

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

# Start Hazelcast Jet server
CMD ["bash", "-c", "set -euo pipefail \
      && eval JAVA_OPTS=\\\"${JAVA_OPTS}\\\" \
      && eval CLASSPATH=\\\"${CLASSPATH}\\\" \
      && if [[ \"x${CLASSPATH}\" != \"x\" ]]; then export CLASSPATH=\"${CLASSPATH}:${CLASSPATH_DEFAULT}\"; else export CLASSPATH=\"${CLASSPATH_DEFAULT}\"; fi \
      && if [[ \"x${JAVA_OPTS}\" != \"x\" ]]; then export JAVA_OPTS=\"${JAVA_OPTS_DEFAULT} ${JAVA_OPTS}\"; else export JAVA_OPTS=\"${JAVA_OPTS_DEFAULT}\"; fi \
      && if [[ \"x${PROMETHEUS_PORT}\" != \"x\" ]]; then export JAVA_OPTS=\"-javaagent:${JET_HOME}/dependencies/jmx_prometheus_javaagent.jar=${PROMETHEUS_PORT}:${PROMETHEUS_CONFIG} ${JAVA_OPTS} \"; fi \
      && if [[ \"x${JET_LICENSE_KEY}\" != \"x\" ]]; then export JAVA_OPTS=\"-Dhazelcast.enterprise.license.key=${JET_LICENSE_KEY} ${JAVA_OPTS} \"; fi \
      && if [[ \"x${JET_LICENCE_KEY}\" != \"x\" ]]; then export JAVA_OPTS=\"-Dhazelcast.enterprise.license.key=${JET_LICENCE_KEY} ${JAVA_OPTS} \"; fi \
      && if [[ \"x${LOGGING_LEVEL}\" != \"x\" ]]; then sed -i \"s/logger.jet.level=info/logger.jet.level=${LOGGING_LEVEL}/g;s/rootLogger.level=info/rootLogger.level=${LOGGING_LEVEL}/g\" $JET_HOME/config/log4j2.properties; fi \
      && set -x \
      && jet-start \
     "]
