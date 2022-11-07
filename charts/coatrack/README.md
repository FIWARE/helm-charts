# Reference Guide #

The chart has templates for the following resources:

* [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
* [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)
* [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
* [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
* [PersistentVolumeClaims](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims) (PVCs)
* [Services](https://kubernetes.io/docs/concepts/services-networking/service/)
* [ServiceAccount](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/), [Role](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole), [RoleBinding](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding) (Templated together since they are only used together in this version)

However, since this chart is all about creating shortcuts from creating all of these resources on their own and configuring them, the available `Values` for the chart are split into only 4 main parts, detailed in their own sections plus sections for any nested properties:

* [Deployments](#markdown-header-deployments)
* [CronJobs](#markdown-header-cronjobs)
* [ConfigMaps](#markdown-header-configmaps)
* [PVCs](#markdown-header-pvcs)

Note: Some defaults depend on values set in `values.yaml` or release parameters, which are written in their helm syntax for accuracy

## Deployments

The `Values` field is `deployments`, which is a List that handles the actual `Deployment` resource and any other resources it might need to operate as described, with the exception of [ConfigMaps](#markdown-header-configmaps), and [PVCs](#markdown-header-pvcs), which have their own section since they can be pointed at by multiple `Deployments` or `CronJobs`.

| Field | Type | Default | Description | Spec Reference |
| --------|---------|-------|------|-------|
| name  | String   | $.Release.Name  | The name of the `Deployment` resource | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta) `.name` |
| labels | Dictionary | {} | Labels to add to the `Deployment` and `Pod` resource beyond the ones added by default by the chart | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta) `.labels` |
| replicaCount | Integer | 1 | The number of `Pods` that the `Deployment` should maintain | [DeploymentSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#deploymentspec-v1-apps) `.replicas` |
| strategy | String | "Recreate" | What to do with the `Pods` when updating the `Deployment` | [DeploymentSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#deploymentspec-v1-apps) `.strategy` |
| podAnnotations | Dictionary String (toYaml) | None | Annotations for the `Pod` | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta) `.annotations` |
| containers | [ContainerList](#markdown-header-containerlists) | None | Optional list of `Containers` for the `Pod`. If only one is needed, you can fill in the values of one of the `Containers` in the [ContainerList](#markdown-header-containerlists) without nesting it under the `.containers` value | [PodSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#podspec-v1-core) `.containers` |
| serviceAccount | [ServiceAccount](#markdown-header-serviceaccount) | None | Name and permissions for a `ServiceAccount` to be used by the `Pods` created by the `Deployment` | [PodSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#podspec-v1-core) `.serviceAccountName` |
| imagePullSecrets | List String (toYaml) | None | `Secrets` containing logins for the `Pods` to pull the image for the `Containers` in them | [PodSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#podspec-v1-core) `.imagePullSecrets` |
| nodeSelector | Dictionary String (toYaml) | None | Restricts the scheduling of `Pods` to the `Nodes` that have the specified labels | [PodSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#podspec-v1-core) `.nodeSelector` |
| affinity | [Affinity](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#affinity-v1-core) String (toYaml) | None | `Pod` affinities and anti-affinities, determining where they prefer or not to be scheduled | [PodSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#podspec-v1-core) `.affinity` |
| tolerations | [Toleration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#toleration-v1-core) Array String (toYaml) | None | Which `Taints` can the `Pods` ignore on `Nodes` to be scheduled on otherwise unschedulable `Nodes` | [PodSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#podspec-v1-core) `.tolerations` |
| service | [Service](#markdown-header-service) | None | Configuration for the `Service` associated with the `Deployment`. Even when not present, the Chart will still create a `Service` with default values, which you can learn more about in its own section | [Service](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#service-v1-core) |
| ports | [PortList](#markdown-header-portlist) | None | Configure the ports of the `Pod` when not using a `ContainerList`, and configures the target ports for the associated `Service` | [ServiceSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#servicespec-v1-core) `.ports` |
| ingress | [Ingress](#markdown-header-ingress) | None | Configure `Ingress` resources for the `Deployment` based on the nested properties and, if present, `Service` properties | [Ingress](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#ingress-v1-networking-k8s-io) |
| spring | String | None | Provides additional default configuration for Spring apps when set | N/A |

## ContainerLists

As mentioned in the [Deployments](#markdown-header-deployments) section, all of the properties found in this section can be appended to it since they can be used directly without them being nested under the `.containers` property. This is, however, not recommended, since it will most likely get deprecated! Since this is a list, consider all of the following properties as being part of a list under the parent property.

| Field | Type | Default | Description | Spec Reference |
| --------|---------|-------|------|-------|
| name | String | $.Release.Name | Name for the container, which will be appended with "-container" | [Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#container-v1-core) `.name` |
| image | [Image](#markdown-header-image) | $.Values.imageRepo and $.Values.imageTag | Configuration for the `Container` image | [Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#container-v1-core) `.image` and `.imagePullPolicy` |
| imagePullPolicy | String | "IfNotPresent" | Alternative configuration when not using the full `.image` syntax (will most likely get deprecated) | [Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#container-v1-core) `.imagePullPolicy` |
| command | List | None | List of arguments for the command to start the `Container` with, overwriting is entrypoint | [Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#container-v1-core) `.command` |
| args | List | None | List of arguments to pass to the `Container`'s existing entrypoint | [Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#container-v1-core) `.args` |
| configMaps | [ConfigMapRef](#markdown-header-configmapref) | None | Defines which `ConfigMaps` to use and whether or not they are optional | [Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#container-v1-core) `.envFrom` |
| ports | [PortList](#markdown-header-portlist) | None | Sets the ports and their types, also used for `Service` configuration when not nested | [Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#container-v1-core) `.ports` |
| volumes | [Volumes](#markdown-header-volumes) | None | Defines the volumes that need to be used and sets their mounting points | [Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#container-v1-core) `.volumeMounts`  and [PodSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#podspec-v1-core) `.volumes` |
| resources | [ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#resourcerequirements-v1-core) String (toYaml) | None | Sets cpu and memory limits and requirements for the `Container` | [Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#container-v1-core) `.resources` |

## Image

Configuration for `Container` images.

| Field | Type | Default | Description | Spec Reference |
| --------|---------|-------|------|-------|
| repository | String | $.Values.imageRepo | Sets the repo from which to pull the image | [Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#container-v1-core) `.image` |
| tag | String | $.Values.imageTag | Sets the tag for the image | [Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#container-v1-core) `.image` |
| pullPolicy | String | "IfNotPresent" | Decides when to pull the image | [Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#container-v1-core) `.imagePullPolicy` |

## ConfigMapRef

Sets the `ConfigMaps` that need to be used by the different `Containers`, but does not define them, that is in section [ConfigMaps](#markdown-header-configmaps).

| Field | Type | Default | Description | Spec Reference |
| --------|---------|-------|------|-------|
| name | String | None | The name of the `ConfigMap` to be used | [ConfigMapRef](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#envfromsource-v1-core) `.configMapRef` |
| optional | Boolean | None | Set to true when the `ConfigMap` does not need to exist to deploy | [ConfigMapEnvSource](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#configmapenvsource-v1-core) `.optional` |

## PortList

Sets the list of ports to be used and configuration related to them. This is used both in [Deployments](#markdown-header-deployments) and [ContainerLists](#markdown-header-containerlists), and also in [Service](#markdown-header-service), but only when used not nested in a [ContainerList](#markdown-header-containerlist).

| Field | Type | Default | Description | Spec Reference |
| --------|---------|-------|------|-------|
| containerPort | Integer | 80 | The port number for the `Container` | [ContainerPort](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#containerport-v1-core) `.containerPort` |
| servicePort | Integer | 80 | The port number for the `Service` | [ServicePort](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#serviceport-v1-core) `.port` |
| port | Integer | 80 | The target port in the `Service` | [ServicePort](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#serviceport-v1-core) `.targetPort` |
| protocol | String | None | Port protocol to be used in the `Service` and `Container` | [ServicePort](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#serviceport-v1-core) `.protocol` |
| name | String | None | Name to use for the port, so as to be reffered to by it and not the actual port number, giving better readability

WARNING: port and containerPort seem to clash, as they should be only one property, might be an incorrect version upgrade that was not caught in the currently deployed apps

## Volumes

Sets the configuration for volumes that the `Pods` will use to attach to the containers, and where to mount them.

| Field | Type | Default | Description | Spec Reference |
| --------|---------|-------|------|-------|
| name | String | None | The name of the volume, which will be referenced both in the `Container` and the `Pod` spec | [VolumeMount](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#volumemount-v1-core) `.name` |
| mountPath | String | None | The path in the filesystem of the `Container` under which to mount the volume | [VolumeMount](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#volumemount-v1-core) `.mountPath` |
| readOnly | Boolean | None | Set to true to set permissions to read-only for everything in the volume | [VolumeMount](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#volumemount-v1-core) `.readOnly` |
| type | [Volume](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#volume-v1-core) String Literal | None | Typically a `PersistentVolumeClaim`, but this setup allows for any extra configuration is needed since it will just be passed along as-is to the Kubernetes API | [PodSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#podspec-v1-core) `.volumes` |

## ServiceAccount

Sets the name and the permissions of a `ServiceAccount` to be used by the `Pod` of a `Deployment`. *NOTE:* In future updates, this should be updated to also work for `CronJobs`. It does so by also creating an associated `Role` and `RoleBinding` to use the Kubernetes RBAC authorization in its simplest form. It also gives better control than simply binding the `ServiceAccount` to an existing `Role` or `ClusterRole` while also keeping cleanup just as simple as all of the extra resources will also be deleted when the release is removed.

| Field | Type | Default | Description | Spec Reference |
| --------|---------|-------|------|-------|
| name | String | $.Release.Name | The name of the `ServiceAccount`. Also serves as the root of the name for the `Role` and `RoleBinding` | [PodSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#podspec-v1-core) `.serviceAccountName` |
| rules | [PolicyRule](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#policyrule-v1-rbac-authorization-k8s-io) String (toYaml) | None | Sets the rules as one would for a `Role` or `ClusterRole` | [Role](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#role-v1-rbac-authorization-k8s-io) `.rules` |

## Service

Configures settings for the `Service` associated with the `Deployment` it is tied to.

| Field | Type | Default | Description | Spec Reference |
| --------|---------|-------|------|-------|
| labels | Dictionary | None | Labels for the `Service` to be added on top of the default labels | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta) `.labels` |
| port | Integer | 80 | Sets the service port if `.ports` is not set in the [Deployment](#markdown-header-deployments) | [ServicePort](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#serviceport-v1-core) `.port` |
| type | String | "ClusterIP" | The type of service, can be "ClusterIP", "NodePort" or "LoadBalancer", depending on the desired behavior | [ServiceSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#servicespec-v1-core) `.type` |

## Ingress

Used to configre an `Ingress` rule for the `Service` of the `Deployment`. It creates a new `Ingress` resource with the following configurations:

| Field | Type | Default | Description | Spec Reference |
| --------|---------|-------|------|-------|
| annotations | Dictionary String (toYaml) | $.Values.defaults.ingressAnnotations | Set additional annotations on the `Ingress` rule, which is also where nginx-ingress and certificate configurations should go | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta) `.annotations` |
| className | String | None | The name of the `IngressClass`, if applicable | [IngressSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#ingressspec-v1-networking-k8s-io) `.ingressClassName` |
| tls | [IngressTLS](#markdown-header-ingresstls) | None | Sets the hosts and secrets for the `Certificates` of the URLs that you will be using | [IngressSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#ingressspec-v1-networking-k8s-io) `.tls` |
| hosts | [IngressHosts](#markdown-header-ingresshosts) List | None | Sets the hosts and which `Service` and port they bind to | [IngressSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#ingressspec-v1-networking-k8s-io) `.hosts` |

## IngressTLS

Configures the TLS rules in `Ingress` resources, with the hosts for the `Certificate` and in which `Secret` to store it.

| Field | Type | Default | Description | Spec Reference |
| --------|---------|-------|------|-------|
| hosts | String List | None | The hosts to be included in the `Certificate` | [IngressTLS](#https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#ingresstls-v1-networking-k8s-io) `.hosts` |
| secretName | String | None | The `Secret` to store the `Certificate` in | [IngressTLS](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#ingresstls-v1-networking-k8s-io) `.secretName`|

## IngressHosts

Configure the external URLs and which `Services` they bind to.

| Field | Type | Default | Description | Spec Reference |
| --------|---------|-------|------|-------|
| host | String | None | The DNS entry to be configured | [IngressRule](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#ingressrule-v1-networking-k8s-io) `.host` |
| paths | [IngressPath](#markdown-header-ingresspath) List | None | The URL paths and to which `Service` and port to bind to | [IngressRule](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#ingressrule-v1-networking-k8s-io) `.http`|

## IngressPath

Configure the URL path and which `Service` and port to bind to.

| Field | Type | Default | Description | Spec Reference |
| --------|---------|-------|------|-------|
| path | String | None | The URL path which to bind to a `Service` and port | [HTTPIngressPath](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#httpingresspath-v1-networking-k8s-io) `.path` |
| pathType | String | None | Whether the path should be exact or just the root for the configuration | [HTTPIngressPath](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#httpingresspath-v1-networking-k8s-io) `.pathType` | 
| port | Integer | 80 (or .deployments.[].service.port if configured) | The port of the `Service` to which to bind to | [ServiceBackendPort](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#servicebackendport-v1-networking-k8s-io) `.number` |

## CronJobs

The `Values` field is `cronjobs`. Similar to the [Deployments](#markdown-header-deployments) section, this section describes the options for `CronJobs` and the `Pods` they spawn. *NOTE:* `PodSpec` will become its own helper to avoid duplication between `Deployments` and `CronJobs`, so the properties related to `Pods` are ommitted from the following table and should be looked up in the [Deployments](#markdown-header-deployments) section for now.

| Field | Type | Default | Description | Spec Reference |
| --------|---------|-------|------|-------|
| name | String | $.Release.Name | The name of the `CronJob` | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta) `.name` |
| labels | Dictionary | None | Extra labels to add on top of the default ones | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta) `.labels` |
| schedule | String | $.Values.defaults.schedule | The cron schedule to which to deploy `Jobs` to | [CronJobSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#cronjobspec-v1-batch) `.schedule` |
| startingDeadlineSeconds | Integer | 86400 | Time in which if the `Job` does not start, it is considered as Failed | [CronJobSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#cronjobspec-v1-batch) `.startingDeadlineSeconds` |
| concurrencyPolicy | String | "Replace" | What to do when a new `Job` wants to start while an older one is running | [CronJobSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#cronjobspec-v1-batch) `.concurrencyPolicy` |
| suspend | Boolean String | "false" | Flag allowing `CronJobs` to suspend scheduling | [CronJobSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#cronjobspec-v1-batch) `.suspend` |
| successfulJobsHistoryLimit | Integer String | "3" | The maximum number of successful `Jobs` to retain | [CronJobSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#cronjobspec-v1-batch) `.successfulJobsHistoryLimit` |
| failedJobsHistoryLimit | Integer String | "1" | The maximum number of successful `Jobs` to retain | [CronJobSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#cronjobspec-v1-batch) `.failedJobsHistoryLimit` |

## ConfigMaps

The `Values` property is `configMaps` which is a List of `ConfigMaps` to be created according to the following properties:

| Field | Type | Default | Description | Spec Reference |
| --------|---------|-------|------|-------|
| name | String | $.Release.Name-config | The name for `ConfigMap` | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta) `.name` |
| data | Dictionary | None | The data lines to include in the `ConfigMap` | [ConfigMap](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#configmap-v1-core) `.data` |

## PVCs

The `Values` property is `pvcs` which is a List of `PVCs` to be created with the following properties:

| Field | Type | Default | Description | Spec Reference |
| --------|---------|-------|------|-------|
| name | String | $.Release.Name-pvc | The name of the `PVC` to be created | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta) `.name` |
| storageClass | String | $.Values.defaults.storageClass | The `StorageClass` to be used for the `PVC` | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#persistentvolumeclaimspec-v1-core) `.storageClass` |
| accessMode | String | $.Values.defaults.accessMode | The access mode of the `Volume` | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#persistentvolumeclaimspec-v1-core) `.accessModes` item |
| size | String | $.Values.defaults.storageSize | The amount of storage to request, in the form of "2Gi" for 2GB | [ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#resourcerequirements-v1-core) `.requests` |
