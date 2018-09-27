# Hazelcast Jet Docker Image

[Hazelcast Jet](http://jet.hazelcast.org) is a distributed computing
platform built for high-performance stream processing and fast batch
processing. It embeds Hazelcast In-Memory Data Grid (IMDG) to provide
a lightweight package of a processor and a scalable in-memory storage.

Visit [Hazelcast Jet Website](http://jet.hazelcast.org) to learn more
about the architecture and use-cases.

## Quick Start

For the simplest end-to-end scenario, you can create a Hazelcast Jet cluster with two Docker containers and access it from the client application.

```
$ docker run -e JAVA_OPTS="-Dhazelcast.local.publicAddress=<host_ip>:5701" -p 5701:5701 hazelcast/hazelcast-jet
$ docker run -e JAVA_OPTS="-Dhazelcast.local.publicAddress=<host_ip>:5702" -p 5702:5701 hazelcast/hazelcast-jet
```

Note that:
* each container must publish the `5701` port under a different host machine port (`5701` and `5702` in the example)
* `<host_ip>` needs to be the host machine address that will be used for the Hazelcast communication

After setting up the cluster, you can start the client application to check it works correctly.

## Hazelcast Jet Defined Environment Variables

### MAX_HEAP_SIZE

You can give environment variables to the Hazelcast Jet member within your Docker command. Currently, we support the variables  `MIN_HEAP_SIZE` and `MAX_HEAP_SIZE` inside our start script. An example command is as follows:

```
$ docker run -e MIN_HEAP_SIZE="1g" hazelcast/hazelcast-jet
```

### JAVA_OPTS

As shown below, you can use `JAVA_OPTS` environment variable if you need to pass multiple VM arguments to your Hazelcast Jet member.

```
$ docker run -e JAVA_OPTS="-Xms512M -Xmx1024M" hazelcast/hazelcast-jet
```

## Configuration

### Using Custom Hazelcast Jet Configuration File

If you need to configure Hazelcast Jet with your own `hazelcast-jet.xml`, you need to mount the folder that has `hazelcast-jet.xml`. You also need to pass the `hazelcast-jet.xml` file path to `hazelcast.jet.config` in `JAVA_OPTS` parameter. Please see the following example:

```
$ docker run -e JAVA_OPTS="-Dhazelcast.jet.config=/opt/hazelcast-jet/config_ext/hazelcast-jet.xml" -v PATH_TO_LOCAL_CONFIG_FOLDER:/opt/azelcast-jet/config_ext hazelcast/hazelcast-jet
```

### Using Custom Hazelcast IMDG Configuration File

Similar to providing custom Hazelcast Jet configuration, If you need to configure the underlying Hazelcast IMDG instance with your own `hazelcast.xml`, you need to mount the folder that has `hazelcast.xml`. You also need to pass the `hazelcast.xml` file path to `hazelcast.config` in `JAVA_OPTS` parameter. Please see the following example:

```
$ docker run -e JAVA_OPTS="-Dhazelcast.config=/opt/hazelcast/config_ext/hazelcast.xml" -v PATH_TO_LOCAL_CONFIG_FOLDER:/opt/hazelcast/config_ext hazelcast/hazelcast-jet
```


### Extending CLASSPATH with new jars or files

If you have custom jars or files to put into classpath of docker container, you can simply use `CLASSPATH` environment variable and pass it via `docker run` command. Please see the following example:

```
$ docker run -e CLASSPATH="/opt/hazelcast-jet/CLASSPATH_EXT/" -v PATH_TO_LOCAL_CONFIG_FOLDER:/opt/hazelcast-jet/CLASSPATH_EXT hazelcast/hazelcast-jet
```

## Hazelcast Jet Management Center

Please see [Hazelcast Jet Management Center Repository](https://github.com/hazelcast/hazelcast-jet-management-center-docker) for Dockerfile definitions and have a look at available images on [Docker Hub](https://store.docker.com/community/images/hazelcast/hazelcast-jet-management-center) page.


## Kubernetes Deployment

Hazelcast Jet Management Center is prepared to work in the Kubernetes environment. For details, please check:

* [Hazelcast Jet Kubernetes Code Sample](https://github.com/hazelcast/hazelcast-jet-code-samples/)