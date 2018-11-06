FROM openjdk:8u171-jre-alpine

# Versions of Hazelcast Jet and Hazelcast IMDG plugins
ARG JET_VERSION=0.8-SNAPSHOT
ARG CACHE_API_VERSION=1.0.0
ARG HZ_KUBE_VERSION=1.2
ARG HZ_EUREKA_VERSION=1.0.2
ARG HZ_AWS_VERSION=2.1.0

# Build constants
ARG JET_HOME="/opt/hazelcast-jet"
ARG JET_JAR="hazelcast-jet-${JET_VERSION}.jar"
ARG CACHE_API_JAR="cache-api-${CACHE_API_VERSION}.jar"
ARG HZ_AWS_API_JAR="hazelcast-aws-${HZ_AWS_VERSION}.jar"

# Install bash & curl
RUN apk add --no-cache bash curl \
 && rm -rf /var/cache/apk/*

# Set up build directory
RUN mkdir -p ${JET_HOME}
WORKDIR ${JET_HOME}

# Download & install Hazelcast AWS Module
RUN curl -svf -o ${JET_HOME}/${HZ_AWS_API_JAR} \
         -L https://repo1.maven.org/maven2/com/hazelcast/hazelcast-aws/${HZ_AWS_VERSION}/${HZ_AWS_API_JAR}

# Download & install JCache
RUN curl -svf -o ${JET_HOME}/${CACHE_API_JAR} \
         -L https://repo1.maven.org/maven2/javax/cache/cache-api/${CACHE_API_VERSION}/${CACHE_API_JAR}

# Download and install Hazelcast Jet and Hazelcast plugins (hazelcast-kubernetes and hazelcast-eureka) with dependencies
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
           -Dhazelcast-jet-version=${JET_VERSION} \
           -Dhazelcast-kubernetes-version=${HZ_KUBE_VERSION} \
           -Dhazelcast-eureka-version=${HZ_EUREKA_VERSION} \
           dependency:copy-dependencies \
 && cd .. \
 && rm -rf $JET_HOME/mvnw \
 && rm -rf ~/.m2 \
 && chmod -R +r $JET_HOME

# Runtime constants
ENV CLASSPATH_DEFAULT "${JET_HOME}:${JET_HOME}/*"
ENV JAVA_OPTS_DEFAULT "-Djava.net.preferIPv4Stack=true"

# Runtime environment variables
ENV MIN_HEAP_SIZE ""
ENV MAX_HEAP_SIZE ""
ENV CLASSPATH ""
ENV JAVA_OPTS ""

ADD server.sh /$JET_HOME/server.sh
ADD submit.sh /$JET_HOME/submit.sh
RUN chmod +x /$JET_HOME/server.sh
RUN chmod +x /$JET_HOME/submit.sh

### Expose port
EXPOSE 5701

# Start Hazelcast Jet server
CMD ["./server.sh"]
