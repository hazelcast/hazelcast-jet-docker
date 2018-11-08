#!/bin/bash
PID=0
sigterm_handler() {
  echo "Jet Term Handler received shutdown signal. Signaling jet instance on PID: ${PID}"
  if [ ${PID} -ne 0 ]; then
    kill "${PID}"
  fi
}

if [ "x$MIN_HEAP_SIZE" != "x" ]; then
	JAVA_OPTS="$JAVA_OPTS -Xms${MIN_HEAP_SIZE}"
fi

if [ "x$MAX_HEAP_SIZE" != "x" ]; then
	JAVA_OPTS="$JAVA_OPTS -Xmx${MAX_HEAP_SIZE}"
fi

if [ "x$JET_LICENSE_KEY" != "x" ]; then
	JAVA_OPTS="$JAVA_OPTS -Dhazelcast.enterprise.license.key=${JET_LICENSE_KEY}"
fi

# if we receive SIGTERM (from docker stop) or SIGINT (ctrl+c if not running as daemon)
# trap the signal and delegate to sigterm_handler function, which will notify jet instance process
trap sigterm_handler SIGTERM SIGINT

JAR_FILE=$1
shift

export CLASSPATH=$JAR_FILE:$CLASSPATH_DEFAULT:$CLASSPATH/*

echo "########################################"
echo "# RUN_JAVA=$RUN_JAVA"
echo "# JAVA_OPTS=$JAVA_OPTS"
echo "# CLASSPATH=$CLASSPATH"
echo "# starting now...."
echo "########################################"

java -server $JAVA_OPTS com.hazelcast.jet.server.JetBootstrap $JAR_FILE $@  &
PID="$!"
# wait on jet instance process
wait ${PID}
# if a signal came up, remove previous traps on signals and wait again (noop if process stopped already)
trap - SIGTERM SIGINT
wait ${PID}
