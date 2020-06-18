# Hazelcast Jet Enterprise Docker Images

[Hazelcast Jet](https://jet-start.sh) is a distributed computing
platform built for high-performance stream processing and fast batch
processing. It embeds Hazelcast In-Memory Data Grid (IMDG) to provide a
lightweight package of a processor and a scalable in-memory storage.

Visit [Hazelcast Jet Website](https://jet-start.sh) to learn more about
the architecture and use-cases.

## Hazelcast Jet Enterprise Quick Start

For the simplest end-to-end scenario, you can create a Hazelcast Jet
Enterprise cluster with two Docker containers and access it from the
client application.

Please request trial license
[here](https://hazelcast.com/hazelcast-enterprise-download/) or contact
sales@hazelcast.com.

```bash
docker run -e JET_LICENSE_KEY=<your_license_key> -p 5701:5701 hazelcast/hazelcast-jet-enterprise
docker run -e JET_LICENSE_KEY=<your_license_key> -p 5702:5701 hazelcast/hazelcast-jet-enterprise
```

For Hazelcast Jet Management Center
```bash
$ docker run -e MC_LICENSE_KEY=<your_license_key> -p 8081:8081 hazelcast/hazelcast-jet-management-center
```

Note that:

* each container must publish the `5701` port under a different host
  machine port (`5701` and `5702` in the example)
* `<host_ip>` needs to be the host machine address that will be used for
  the Hazelcast communication

After setting up the cluster, you can start the client application to
check it works correctly.

Please go to the [Hazelcast Jet website](https://jet-start.sh/docs/next/operations/docker)
for more thorough documentation regarding the configuration, job
submission, docker-compose and packaging.

## Hazelcast Jet Management Center

Please see [Hazelcast Jet Management Center
Repository](https://github.com/hazelcast/hazelcast-jet-management-center-docker)
for Dockerfile definitions and have a look at available images on
[Docker
Hub](https://store.docker.com/community/images/hazelcast/hazelcast-jet-management-center)
page.

## Kubernetes Deployment

Hazelcast Jet Management Center is prepared to work in the Kubernetes
environment. For details, please check:

* [Hazelcast Jet Kubernetes Code Sample](examples/kubernetes)
