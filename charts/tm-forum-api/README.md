# tm-forum-api

![Version: 0.10.8](https://img.shields.io/badge/Version-0.10.8-informational?style=flat-square) ![AppVersion: 0.13.2](https://img.shields.io/badge/AppVersion-0.13.2-informational?style=flat-square)
A Helm chart for running the FIWARE TMForum-APIs

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| wistefan | <stefan.wiedemann@fiware.org> |  |

## Individual Configuration

The chart deploys all configured APIs, using the same default-configuration for each of them to make the deployment easier. However, it also allows to overwrite
every configuration for the individual API as following:

While the default-config might set:
```yaml
  defaultConfig:
    replicaCount: 1
    image:
      # -- repository to get the container from
      repository: quay.io/wi_stefan
      # -- tag to be used, most of the time the apis will use the same version
      tag: 0.4.1
      # -- pull policy to be used
      pullPolicy: IfNotPresent
    # -- log level of the api
    logLevel: WARN
    # -- cache config for connecting the broker
    cache:
      # -- maximum size of the cache
      maximumSize: 1000
      # -- how fast should the cache entry expire after it was written?
      expireAfterWrite: 2s
```

Those values can be overwritten on an individual API level as following:

```yaml
apis:
  # uses the default
  - name: party-catalog
    image: tmforum-party-catalog
    basePath: /tmf-api/party/v4

  # customized
  - name: product-catalog
    image: tmforum-product-catalog
    basePath: /tmf-api/productCatalogManagement/v4
    replicaCount: 3
    image:
      repository: quay.io/my_own_repo
      tag: 1.2.3
      pullPolicy: Always
    logLevel: DEBUG
    cache:
      maximumSize: 3000
```
For all untouched values, the customized deployement will still use the defaults, while the explicitly set once are overwritten.

## Source Code

* <https://github.com/FIWARE/tmforum-api>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| apiProxy.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| apiProxy.additionalLabels | object | `{}` |  |
| apiProxy.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| apiProxy.enabled | bool | `false` | should the proxy be deployed? |
| apiProxy.image | object | `{"pullPolicy":"IfNotPresent","repository":"envoyproxy/envoy","tag":"v1.27-latest"}` | configuration to be used for the image of the proxy |
| apiProxy.image.pullPolicy | string | `"IfNotPresent"` | pull policy to be used |
| apiProxy.image.repository | string | `"envoyproxy/envoy"` | repository to get the proxy from |
| apiProxy.image.tag | string | `"v1.27-latest"` | tag to be used |
| apiProxy.nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| apiProxy.replicaCount | int | `1` | initial number of target replications, can be different if autoscaling is enabled |
| apiProxy.revisionHistoryLimit | int | `3` | number of old replicas to be retained |
| apiProxy.service | object | `{"annotations":{},"nameOverride":null,"port":8080,"type":"ClusterIP"}` | configuration for the proxy service |
| apiProxy.service.annotations | object | `{}` | addtional annotations, if required |
| apiProxy.service.nameOverride | string | `nil` | name to be used for the proxy service. |
| apiProxy.service.port | int | `8080` | port to be used by the service |
| apiProxy.service.type | string | `"ClusterIP"` | service type |
| apiProxy.sidecars | list | `[]` | additional sidecars for the deployment, if required |
| apiProxy.tolerations | list | `[]` | tolerations template ref: ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| apiProxy.updateStrategy.rollingUpdate | object | `{"maxSurge":1,"maxUnavailable":0}` | new pods will be added gradually |
| apiProxy.updateStrategy.rollingUpdate.maxSurge | int | `1` | number of pods that can be created above the desired amount while updating |
| apiProxy.updateStrategy.rollingUpdate.maxUnavailable | int | `0` | number of pods that can be unavailable while updating |
| apiProxy.updateStrategy.type | string | `"RollingUpdate"` | type of the update |
| apis | list | `[{"basePath":"/tmf-api/party/v4","image":"tmforum-party-catalog","name":"party-catalog"},{"basePath":"/tmf-api/customerBillManagement/v4","image":"tmforum-customer-bill-management","name":"customer-bill-management"},{"basePath":"/tmf-api/customerManagement/v4","image":"tmforum-customer-management","name":"customer-management"},{"basePath":"/tmf-api/productCatalogManagement/v4","image":"tmforum-product-catalog","name":"product-catalog"},{"basePath":"/tmf-api/productInventory/v4","image":"tmforum-product-inventory","name":"product-inventory"},{"basePath":"/tmf-api/productOrderingManagement/v4","image":"tmforum-product-ordering-management","name":"product-ordering-management"},{"basePath":"/tmf-api/resourceCatalog/v4","image":"tmforum-resource-catalog","name":"resource-catalog"},{"basePath":"/tmf-api/resourceFunctionActivation/v4","image":"tmforum-resource-function-activation","name":"resource-function-activation"},{"basePath":"/tmf-api/resourceInventoryManagement/v4","image":"tmforum-resource-inventory","name":"resource-inventory"},{"basePath":"/tmf-api/serviceCatalogManagement/v4","image":"tmforum-service-catalog","name":"service-catalog"},{"basePath":"/tmf-api/serviceInventory/v4","image":"tmforum-service-inventory","name":"service-inventory"},{"basePath":"/tmf-api/accountManagement/v4","image":"tmforum-account","name":"account-management"},{"basePath":"/tmf-api/agreementManagement/v4","image":"tmforum-agreement","name":"agreement-management"},{"basePath":"/tmf-api/partyRoleManagement/v4","image":"tmforum-party-role","name":"party-role"},{"basePath":"/tmf-api/usageManagement/v4","image":"tmforum-usage-management","name":"usage-management"}]` | be aware: when you change the image repositrory or the tag for an api, you have to provide both values for the changes to take effect |
| autoscaling.enabled | bool | `false` | should autoscaling be enabled for the context broker |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | metrics to react on |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| defaultConfig.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| defaultConfig.additionalEnvVars | list | `[{"name":"API_EXTENSION_ENABLED","value":"true"}]` | a list of additional env vars to be set, check the tm-forum api docu for all available options |
| defaultConfig.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| defaultConfig.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| defaultConfig.cache | object | `{"entities":{"expireAfterAccess":"2s","expireAfterWrite":"2s","maximumSize":1000},"subscriptions":{"expireAfterAccess":"14d","expireAfterWrite":"14d","maximumSize":1000}}` | cache config for connecting the broker |
| defaultConfig.cache.entities | object | `{"expireAfterAccess":"2s","expireAfterWrite":"2s","maximumSize":1000}` | entities cache |
| defaultConfig.cache.entities.expireAfterAccess | string | `"2s"` | how fast should the cache entry expire after it was last accessed? |
| defaultConfig.cache.entities.expireAfterWrite | string | `"2s"` | how fast should the cache entry expire after it was written? |
| defaultConfig.cache.entities.maximumSize | int | `1000` | maximum size of the cache |
| defaultConfig.cache.subscriptions | object | `{"expireAfterAccess":"14d","expireAfterWrite":"14d","maximumSize":1000}` | subscriptions cache |
| defaultConfig.cache.subscriptions.expireAfterAccess | string | `"14d"` | how fast should the cache entry expire after it was last accessed? |
| defaultConfig.cache.subscriptions.expireAfterWrite | string | `"14d"` | how fast should the cache entry expire after it was written? |
| defaultConfig.cache.subscriptions.maximumSize | int | `1000` | maximum size of the cache |
| defaultConfig.contextUrl | string | `"https://smartdatamodels.org/context.jsonld"` | default context to be used when contacting the context broker |
| defaultConfig.endpointsPort | int | `9090` | metrics and health port |
| defaultConfig.image | object | `{"pullPolicy":"IfNotPresent","repository":"quay.io/fiware","tag":"0.30.5"}` | configuration to be used for the image of the container |
| defaultConfig.image.pullPolicy | string | `"IfNotPresent"` | pull policy to be used |
| defaultConfig.image.repository | string | `"quay.io/fiware"` | repository to get the container from |
| defaultConfig.image.tag | string | `"0.30.5"` | tag to be used, most of the time the apis will use the same version |
| defaultConfig.livenessProbe.healthPath | string | `"/health/liveness"` | path to be used for the health check |
| defaultConfig.livenessProbe.initialDelaySeconds | int | `30` |  |
| defaultConfig.livenessProbe.periodSeconds | int | `10` |  |
| defaultConfig.livenessProbe.successThreshold | int | `1` |  |
| defaultConfig.livenessProbe.timeoutSeconds | int | `30` |  |
| defaultConfig.logLevel | string | `"INFO"` | log level of the api |
| defaultConfig.ngsiLd | object | `{"path":"ngsi-ld/v1","readTimeout":"30s","url":"http://context-broker:1026"}` | ngsi-ld broker connection information |
| defaultConfig.ngsiLd.path | string | `"ngsi-ld/v1"` | base path for the ngsi-ld api |
| defaultConfig.ngsiLd.readTimeout | string | `"30s"` | timeout for requests ot the broker |
| defaultConfig.ngsiLd.url | string | `"http://context-broker:1026"` | address of the broker |
| defaultConfig.nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| defaultConfig.port | int | `8080` | port to be used for the app |
| defaultConfig.prometheus | object | `{"enabled":true,"path":"/prometheus"}` | configuration for proemtheus metrics |
| defaultConfig.prometheus.enabled | bool | `true` | should it be enabled |
| defaultConfig.prometheus.path | string | `"/prometheus"` | path to get the metrics from |
| defaultConfig.readinessProbe.initialDelaySeconds | int | `30` |  |
| defaultConfig.readinessProbe.periodSeconds | int | `10` |  |
| defaultConfig.readinessProbe.readinessPath | string | `"/health/readiness"` | path to be used for the health check |
| defaultConfig.readinessProbe.successThreshold | int | `1` |  |
| defaultConfig.readinessProbe.timeoutSeconds | int | `30` |  |
| defaultConfig.replicaCount | int | `1` | initial number of target replications, can be different if autoscaling is enabled |
| defaultConfig.revisionHistoryLimit | int | `3` | number of old replicas to be retained |
| defaultConfig.serverHost | string | `"http://tmf-api:8080"` | host that the tm-forum api can be reached at |
| defaultConfig.sidecars | list | `[]` | additional sidecars for the deployment, if required |
| defaultConfig.tolerations | list | `[]` | tolerations template ref: ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| defaultConfig.updateStrategy.rollingUpdate | object | `{"maxSurge":1,"maxUnavailable":0}` | new pods will be added gradually |
| defaultConfig.updateStrategy.rollingUpdate.maxSurge | int | `1` | number of pods that can be created above the desired amount while updating |
| defaultConfig.updateStrategy.rollingUpdate.maxUnavailable | int | `0` | number of pods that can be unavailable while updating |
| defaultConfig.updateStrategy.type | string | `"RollingUpdate"` | type of the update |
| fullnameOverride | string | `""` | option to override the fullname config in the _helpers.tpl |
| health.broker.allowedResponseCodes | list | `[200]` | broker health endpoint response codes to be acceptable as 'healthy' |
| health.broker.enabled | bool | `false` | enable including the broker state in the service's health state |
| health.broker.path | string | `"/q/health"` | path to be used for broker health endpoint |
| health.broker.urlOverride | string | `""` | to be set if the broker url differs from defaultConfig.ngsiLd.url |
| ingress.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.className | string | `nil` | class of the ingress controller to handle the ingress |
| ingress.enabled | bool | `false` | should there be an ingress to connect tmforum with the public internet |
| ingress.hosts | list | `[{"host":"localhost"}]` | all hosts to be provided |
| ingress.hosts[0] | object | `{"host":"localhost"}` | provide a hosts and the paths that should be available |
| ingress.tls | list | `[]` | configure the ingress' tls |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| redis.architecture | string | `"standalone"` |  |
| redis.auth.enabled | bool | `false` |  |
| redis.auth.sentinel | bool | `false` |  |
| redis.cacheConfig.uri | string | `"redis://tmforum-redis-master:6379"` | uri of redis master |
| redis.enabled | bool | `false` | enable redis caching? |
| redis.fullnameOverride | string | `"tmforum-redis"` |  |
| redis.master.containerSecurityContext.enabled | bool | `false` |  |
| redis.master.podSecurityContext.enabled | bool | `false` |  |
| route.annotations | object | `{}` | annotations to be added to the route |
| route.enabled | bool | `false` |  |
| route.host | string | `"localhost"` | host to be used |
| route.tls | object | `{}` | tls configuration for the route |
| service.annotations | object | `{}` | addtional annotations, if required |
| service.port | int | `8080` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a tmforum specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)