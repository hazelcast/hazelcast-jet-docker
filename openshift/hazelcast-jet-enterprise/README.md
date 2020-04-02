# Hazelcast Jet Enterprise OpenShift

Hazelcast Jet Enterprise is available on the OpenShift platform in a
form of a dedicated Docker image
[`registry.connect.redhat.com/hazelcast/hazelcast-jet-enterprise-4`](https://access.redhat.com/containers/?tab=overview#/registry.connect.redhat.com/hazelcast/hazelcast-jet-enterprise-4)
published in [Red Hat Container
Catalog](https://access.redhat.com/containers/).

## Quick Start

Create an OpenShift secret with the Hazelcast Jet Enterprise License
Key.

    $ oc create secret generic jet-license-key --from-literal=key=LICENSE-KEY-HERE

Creates secret to allow access to Red Hat Container Catalog.

    $ oc create secret docker-registry rhcc \
       --docker-server=registry.connect.redhat.com \
       --docker-username=<red_hat_username> \
       --docker-password=<red_hat_password> \
       --docker-email=<red_hat_email>
    $ oc secrets link default rhcc --for=pull

Then, here's an example of a simple template that can be used to start a
Hazelcast cluster (don't forget to replace `<project-name>` of
`HAZELCAST_KUBERNETES_SERVICE_DNS` and `<image-version>` in the
template).

```
apiVersion: v1
kind: Template
objects:
- apiVersion: v1
  kind: ConfigMap
  metadata:
    name: hazelcast-jet-configuration
  data:
    hazelcast.yaml: |-
        hazelcast:
        network:
            join:
            multicast:
                enabled: false
            kubernetes:
                enabled: true
                namespace: default
                service-name: hazelcast-jet-service

- apiVersion: apps/v1
  kind: StatefulSet
  metadata:
    name: hazelcast-jet
    labels:
      app: hazelcast-jet
  spec:
    replicas: 2
    selector:
      matchLabels:
        app: hazelcast-jet
    template:
      metadata:
        labels:
          app: hazelcast-jet
      spec:
        containers:
        - name: hazelcast-jet
          image: registry.connect.redhat.com/hazelcast/hazelcast-jet-enterprise-4:<image-version>
          ports:
          - name: hazelcast-jet
            containerPort: 5701
          livenessProbe:
            httpGet:
              path: /hazelcast/health/node-state
              port: 5701
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /hazelcast/health/node-state
              port: 5701
            initialDelaySeconds: 180
            periodSeconds: 10
            timeoutSeconds: 1
            successThreshold: 1
            failureThreshold: 1
          volumeMounts:
          - name: hazelcast-jet-storage
            mountPath: /data/hazelcast-jet
          env:
          - name: HAZELCAST_KUBERNETES_SERVICE_DNS
            value: hazelcast-jet-service.<project-name>.svc.cluster.local
          - name: JET_LICENSE_KEY
            valueFrom:
              secretKeyRef:
                name: jet-license-key
                key: key
          - name: JAVA_OPTS
            value: "-Dhazelcast.rest.enabled=true -Dhazelcast.config=/data/hazelcast-jet/hazelcast.yaml"
        volumes:
        - name: hazelcast-jet-storage
          configMap:
            name: hazelcast-jet-configuration
              items:
                - key: hazelcast.yaml
                  path: hazelcast.yaml

- apiVersion: v1
  kind: Service
  metadata:
    name: hazelcast-jet-service
  spec:
    type: ClusterIP
    clusterIP: None
    selector:
      app: hazelcast-jet
    ports:
    - protocol: TCP
      port: 5701
```

If you save it as `hazelcast-jet.yaml`, then use the following command to
start the cluster.

    $ oc new-app -f hazelcast-jet.yaml

**Note**: _You should always use `<kubernetes>` discovery in OpenShift;
defining static IPs usually does not make sense, since POD IP is
dynamically assigned._
