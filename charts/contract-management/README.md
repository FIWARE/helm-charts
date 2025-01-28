# contract-management

![Version: 1.0.2](https://img.shields.io/badge/Version-1.0.2-informational?style=flat-square) ![AppVersion: 2.0.0](https://img.shields.io/badge/AppVersion-2.0.0-informational?style=flat-square)

A Helm chart for running the contract-management on kubernetes.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| pulledtim | <tim.smyth@fiware.org> |  |

## Source Code

* <https://github.com/fiware/contract-management>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnvVars | list | `[]` | a list of additional env vars to be set, check the til docu for all available options |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | metrics to react on |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.healthPort | int | `9090` | port to request health information at |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"quay.io/fiware/contract-management"` | til image name ref: https://quay.io/repository/fiware/contract-management |
| deployment.image.tag | string | `"2.0.1"` | tag of the image to be used |
| deployment.livenessProbe.initialDelaySeconds | int | `30` |  |
| deployment.livenessProbe.periodSeconds | int | `10` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| deployment.nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| deployment.readinessProbe.initialDelaySeconds | int | `31` |  |
| deployment.readinessProbe.periodSeconds | int | `10` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.timeoutSeconds | int | `30` |  |
| deployment.replicaCount | int | `1` | initial number of target replications, can be different if autoscaling is enabled |
| deployment.revisionHistoryLimit | int | `3` | number of old replicas to be retained |
| deployment.tolerations | list | `[]` | tolerations template ref: ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| deployment.updateStrategy.rollingUpdate | object | `{"maxSurge":1,"maxUnavailable":0}` | new pods will be added gradually |
| deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` | number of pods that can be created above the desired amount while updating |
| deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` | number of pods that can be unavailable while updating |
| deployment.updateStrategy.type | string | `"RollingUpdate"` | type of the update |
| fullnameOverride | string | `""` | option to override the fullname config in the _helpers.tpl |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| port | int | `8080` | port that the til container uses |
| prometheus.enabled | bool | `true` | should prometheus scrape be enabled |
| prometheus.path | string | `"/prometheus"` | path for prometheus scrape |
| prometheus.port | int | `9090` | port prometheus scrape is available at |
| service.annotations | object | `{}` | additional annotations, if required |
| service.port | int | `8080` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a til specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |
| services.party.path | string | `"/tmf-api/party/v4"` |  |
| services.party.read-timeout | int | `30` |  |
| services.party.url | string | `"http://tm-forum-api-party-catalog:8080"` |  |
| services.product-catalog.path | string | `"/tmf-api/productCatalogManagement/v4"` |  |
| services.product-catalog.read-timeout | int | `30` |  |
| services.product-catalog.url | string | `"http://tm-forum-api-product-catalog:8080"` |  |
| services.product-order.path | string | `"/tmf-api/productOrderingManagement/v4"` |  |
| services.product-order.read-timeout | int | `30` |  |
| services.product-order.url | string | `"http://tm-forum-api-product-ordering-management:8080"` |  |
| services.rainbow.path | string | `"/"` |  |
| services.rainbow.read-timeout | int | `30` |  |
| services.rainbow.url | string | `"http://rainbow:8080"` |  |
| services.service-catalog.path | string | `"/tmf-api/serviceCatalogManagement/v4"` |  |
| services.service-catalog.read-timeout | int | `30` |  |
| services.service-catalog.url | string | `"http://tm-forum-api-service-catalog:8080"` |  |
| services.tmforum-agreement-api.path | string | `"/tmf-api/agreementManagement/v4"` |  |
| services.tmforum-agreement-api.read-timeout | int | `30` |  |
| services.tmforum-agreement-api.url | string | `"http://tm-forum-api-agreement:8080"` |  |
| services.trusted-issuers-list.path | string | `""` |  |
| services.trusted-issuers-list.read-timeout | int | `30` |  |
| services.trusted-issuers-list.url | string | `"http://trusted-issuers-list:8080"` |  |
| til.claims[0].roles[0] | string | `"Consumer"` |  |
| til.claims[0].roles[1] | string | `"Admin"` |  |
| til.claims[0].target | string | `"did:some:service"` |  |
| til.credentialType | string | `"MyCredential"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
