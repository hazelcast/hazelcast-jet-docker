FROM openjdk:8u201-jre-alpine

# Versions of Hazelcast Jet and Hazelcast IMDG plugins
ARG JET_VERSION=4.0-SNAPSHOT
ARG CACHE_API_VERSION=1.1.0
ARG HZ_KUBE_VERSION=1.4
ARG HZ_EUREKA_VERSION=1.1.1
ARG HZ_AWS_VERSION=2.4
ARG JMX_PROMETHEUS_AGENT_VERSION=0.11.0

# Build constants
ARG JET_HOME="/opt/hazelcast-jet-enterprise"
ARG JET_INSTALL_NAME="hazelcast-jet-enterprise-${JET_VERSION}"
ARG JET_JAR="hazelcast-jet-enterprise-${JET_VERSION}.jar"
ARG JET_ZIP="hazelcast-jet-enterprise-${JET_VERSION}.zip"
ARG CACHE_API_JAR="cache-api-${CACHE_API_VERSION}.jar"
ARG HZ_AWS_API_JAR="hazelcast-aws-${HZ_AWS_VERSION}.jar"

# Install bash & curl
RUN apk add --no-cache bash curl \
 && rm -rf /var/cache/apk/*

# Set up build directory
RUN mkdir -p ${JET_HOME}/dependencies
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


# Download & install Hazelcast AWS Module
RUN curl -svf -o ${JET_HOME}/dependencies/${HZ_AWS_API_JAR} \
         -L https://repo1.maven.org/maven2/com/hazelcast/hazelcast-aws/${HZ_AWS_VERSION}/${HZ_AWS_API_JAR}

# Download & install JCache
RUN curl -svf -o ${JET_HOME}/dependencies/${CACHE_API_JAR} \
         -L https://repo1.maven.org/maven2/javax/cache/cache-api/${CACHE_API_VERSION}/${CACHE_API_JAR}

# Installing JMX Prometheus Agent
RUN curl -svf -o ${JET_HOME}/dependencies/jmx_prometheus_javaagent.jar \
         -L https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_PROMETHEUS_AGENT_VERSION}/jmx_prometheus_javaagent-${JMX_PROMETHEUS_AGENT_VERSION}.jar

# Download and install Hazelcast plugins (hazelcast-kubernetes and hazelcast-eureka) with dependencies
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
           -Dhazelcast-kubernetes-version=${HZ_KUBE_VERSION} \
           -Dhazelcast-eureka-version=${HZ_EUREKA_VERSION} \
           -Dhazelcast-jet-version=${JET_VERSION} \
           dependency:copy-dependencies \
 && cd .. \
 && rm -rf $JET_HOME/mvnw \
 && rm -rf ~/.m2 \
 && chmod -R +r $JET_HOME

COPY logging.properties ${JET_HOME}/logging.properties
COPY jmx_agent_config.yaml ${JET_HOME}/jmx_agent_config.yaml

# Runtime constants
ENV CLASSPATH_DEFAULT "${JET_HOME}:${JET_HOME}/lib/${JET_JAR}:${JET_HOME}/dependencies:${JET_HOME}/dependencies/*"
ENV JAVA_OPTS_DEFAULT "-Djava.net.preferIPv4Stack=true -Djava.util.logging.config.file=${JET_HOME}/logging.properties"

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
      && if [[ \"x${LOGGING_LEVEL}\" != \"x\" ]]; then sed -i \"s/java.util.logging.ConsoleHandler.level = INFO/java.util.logging.ConsoleHandler.level = ${LOGGING_LEVEL}/g;s/.level= INFO/.level= ${LOGGING_LEVEL}/g\" logging.properties; fi \
      && echo \"########################################\" \
      && echo \"# JAVA_OPTS=${JAVA_OPTS}\" \
      && echo \"# CLASSPATH=${CLASSPATH}\" \
      && echo \"# starting now....\" \
      && echo \"########################################\" \
      && set -x \
      && exec java -server ${JAVA_OPTS} com.hazelcast.jet.server.JetMemberStarter \
     "]
