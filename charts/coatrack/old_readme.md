# Generic Microservice Chart #

**Latest:**   `0.2.0`



The generic master chart to generate Kubernetes resources for microservices, including extra defaults for our Spring microservices. The types of resources generated are: Deployments, Services, Ingress Rules, ConfigMaps and PVCs. The Chart iterates over 3 lists that you can define in a `values.yaml` file, and if nothing is defined in those lists, it will not generate any resources. For a more complete list of possible options and examples, check out the `values.yaml` file in this repo (Note: do not confuse the default `values.yaml` in this repo with the `values.yaml` that you will be creating to overwrite those values!). Another way of getting the default values is by running:

```
helm show values <file_path | repo/chart-name>
```

**Note:** There is no value to set the namespace of the resources, they will all be deployed in the same namespace of the release. Therefore, do not forget the `-n <namespace>` flag!!

## Installation ##

To install the Chart from this repo, go up a directory (or copy/zip it) and run:

```
helm upgrade --cleanup-on-fail --install <release_name> generic-microservice/ -n <namespace> -f <values_file>
```

## Deployments ##

The `deployments` Values holds a list of deployments, and also affects generated Services and Ingress Rules. The Chart will generate a Deployment and a Service for each item in the `deployments` list, but will only generate an Ingress Rule if the `deployments.ingress` value is set. In most cases, you will probably only need this from the `deployments` value:

```
deployments:
  - configMaps:
      - name: <config_name>
    spring: <true if spring microservice>
    image:
      repository: <image_url_and_name>
      tag: <image_tag>
    imagePullSecrets:
      - name: docker-login
```

This will generate everything you need from a Deployment and Service resource pair, including the selector labels and ports to connect them. It also, by default, uses the name of the release as the name for these resources. Here's a more complex example from the cdn:

```
deployments:
  - name: bxd-media-cdn
    configMaps:
      - name: bxd-media-config
    volumes:
      - name: gluster
        mountPath: /mnt/media
        readOnly: true
        type: |-
          persistentVolumeClaim:
            claimName: bxd-media-pvc
    spring: true
    image:
      repository: docker.bebr.nl/bxd/bxd-media-cdn
      tag: "1" 
    imagePullSecrets:
      - name: docker-login
    ingress:
      hosts:
        - host: cdn.dev.toskr.nl
          paths:
            - path: /
              pathType: Prefix
      tls:
        - hosts:
          - cdn.dev.toskr.nl
          secretName: bxd-cdn-tls
```

As you can see, here we define values to generate a Deployment, Service and Ingress, with extra defaults for spring. To see how to generate the ConfigMap and the PVCs this points to, check the next sections.

**Note:** This setup assumes you have set up the imagePullSecret you specify, the `letsencrypt-prod` ClusterIssuer and the `glusterfs-default` StorageClass. If you don't have them and don't know how to set them up, ask an admin

## Cronjobs ##

As of `0.2.0` you can also set up CronJobs in the same way as you would set up deployments. The common values, such as `name` work the same, and you can check the default chart values for examples of other values which can be set up. In general, if a property of a CronJob exists, there is probably the equivalent of that property as a value in the Chart, but without the extra indentation. The template itself *should* indent everything into its proper place regardless. If you find a value in the documentation of CronJobs which is not templated, ask for an update to the Chart!

## ConfigMaps ##

Considering each Deployment might have multiple ConfigMaps, or, more commonly, the same ConfigMap being used in multiple Deployments, they are generated separately. The structure is simple, `configMaps` holds a list of ConfigMaps to be generated, with only `.name` and `.values` to take into account:

```
configMaps:
  - name: <name>
    values:
      <key1>: <value1>
      <key2>: <value2>
```

**Note:** follow normal ConfigMap rules and add quotes around boolean and numerical values


## PVCs ##

As with ConfigMaps, you can create simple PVCs like this under `pvcs`:

```
pvcs:
  - name: <name>
    size: <size>
```

This will use the default `glusterfs-default` StorageClass and `ReadWriteMany` Access Mode. You can set them using `.storageClass` and `.accessMode` respectively.


## Future Work ##

Helm allows users to create tests for the Release, and the defaults for that are left in this Chart, but they are not enabled. Moreover, better examples should be given in the default `values.yaml` file
