FROM openjdk:8u201-jre-alpine

# Versions of Hazelcast Jet and Hazelcast IMDG plugins
ARG JET_VERSION=3.1
ARG CACHE_API_VERSION=1.1.0
ARG HZ_KUBE_VERSION=1.4
ARG HZ_EUREKA_VERSION=1.1.1
ARG HZ_AWS_VERSION=2.4

# Build constants
ARG JET_HOME="/opt/hazelcast-jet"
ARG JET_JAR="hazelcast-jet-${JET_VERSION}.jar"
ARG CACHE_API_JAR="cache-api-${CACHE_API_VERSION}.jar"
ARG HZ_AWS_API_JAR="hazelcast-aws-${HZ_AWS_VERSION}.jar"

# Install bash & curl
RUN apk add --no-cache bash curl \
 && rm -rf /var/cache/apk/*

# Set up build directory
RUN mkdir -p ${JET_HOME}/lib
WORKDIR ${JET_HOME}

# Download & install Hazelcast Jet
RUN curl -svf -o ${JET_HOME}/lib/${JET_JAR} \
         -L https://repo1.maven.org/maven2/com/hazelcast/jet/hazelcast-jet/${JET_VERSION}/${JET_JAR}

# Download & install Hazelcast AWS Module
RUN curl -svf -o ${JET_HOME}/lib/${HZ_AWS_API_JAR} \
         -L https://repo1.maven.org/maven2/com/hazelcast/hazelcast-aws/${HZ_AWS_VERSION}/${HZ_AWS_API_JAR}

# Download & install JCache
RUN curl -svf -o ${JET_HOME}/lib/${CACHE_API_JAR} \
         -L https://repo1.maven.org/maven2/javax/cache/cache-api/${CACHE_API_VERSION}/${CACHE_API_JAR}

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
           dependency:unpack \
 && cd .. \
 && rm -rf $JET_HOME/mvnw \
 && rm -rf ~/.m2 \
 && chmod -R +r $JET_HOME \
 && mv $JET_HOME/hazelcast-jet-$JET_VERSION/* $JET_HOME/ \ 
 && rm -rf $JET_HOME/hazelcast-jet-$JET_VERSION 

COPY logging.properties ${JET_HOME}/logging.properties

# Runtime constants
ENV CLASSPATH_DEFAULT "${JET_HOME}:${JET_HOME}/*:${JET_HOME}/lib:${JET_HOME}/lib/*"
ENV JAVA_OPTS_DEFAULT "-Djava.net.preferIPv4Stack=true -Djava.util.logging.config.file=${JET_HOME}/logging.properties"

# Runtime environment variables
ENV MIN_HEAP_SIZE ""
ENV MAX_HEAP_SIZE ""
ENV CLASSPATH ""
ENV JAVA_OPTS ""
ENV PATH $JET_HOME/bin:$PATH
ENV LOGGING_LEVEL ""

### Expose port
EXPOSE 5701

# Start Hazelcast Jet server
CMD ["bash", "-c", "set -euo pipefail \
      && eval JAVA_OPTS=\\\"${JAVA_OPTS}\\\" \
      && eval CLASSPATH=\\\"${CLASSPATH}\\\" \
      && if [[ \"x${CLASSPATH}\" != \"x\" ]]; then export CLASSPATH=\"${CLASSPATH}:${CLASSPATH_DEFAULT}\"; else export CLASSPATH=\"${CLASSPATH_DEFAULT}\"; fi \
      && if [[ \"x${JAVA_OPTS}\" != \"x\" ]]; then export JAVA_OPTS=\"${JAVA_OPTS} ${JAVA_OPTS_DEFAULT}\"; else export JAVA_OPTS=\"${JAVA_OPTS_DEFAULT}\"; fi \
      && if [[ \"x${MIN_HEAP_SIZE}\" != \"x\" ]]; then export JAVA_OPTS=\"-Xms${MIN_HEAP_SIZE} ${JAVA_OPTS}\"; fi \
      && if [[ \"x${MAX_HEAP_SIZE}\" != \"x\" ]]; then export JAVA_OPTS=\"-Xmx${MAX_HEAP_SIZE} ${JAVA_OPTS} \"; fi \
      && if [[ \"x${LOGGING_LEVEL}\" != \"x\" ]]; then sed -i \"s/java.util.logging.ConsoleHandler.level = INFO/java.util.logging.ConsoleHandler.level = ${LOGGING_LEVEL}/g;s/.level= INFO/.level= ${LOGGING_LEVEL}/g\" logging.properties; fi \
      && echo \"########################################\" \
      && echo \"# JAVA_OPTS=${JAVA_OPTS}\" \
      && echo \"# CLASSPATH=${CLASSPATH}\" \
      && echo \"# starting now....\" \
      && echo \"########################################\" \
      && set -x \
      && exec java -server ${JAVA_OPTS} com.hazelcast.jet.server.StartServer \
     "]
