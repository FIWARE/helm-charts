# canis-major

![Version: 0.0.4](https://img.shields.io/badge/Version-0.0.4-informational?style=flat-square) ![AppVersion: 1.5.15](https://img.shields.io/badge/AppVersion-1.5.15-informational?style=flat-square)

A Helm chart for running canis major on kubernetes.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| wistefan | <stefan.wiedemann@fiware.org> |  |

## Source Code

* <https://github.com/FIWARE/CanisMajor>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additonalEnvVars | list | `[]` | a list of additional env vars to be set, check the canis-major docu for all available options |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | metrics to react on |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.defaultAccount | object | `{"enabled":true}` | configuration for the default account to be used in case no wallet information is provided |
| deployment.defaultAccount.enabled | bool | `true` | should a default account be used |
| deployment.ethereum | object | `{"contractAddress":"0x476059cd57800db8eb88f67c2aa38a6fcf8251e0","dltAddress":"http://15.236.0.91:22000","enabled":true,"gas":3000000,"gasPrice":0}` | configuration to be used when connecting with an ethereum compatible blockchain |
| deployment.ethereum.contractAddress | string | `"0x476059cd57800db8eb88f67c2aa38a6fcf8251e0"` | address of the contract to be used |
| deployment.ethereum.dltAddress | string | `"http://15.236.0.91:22000"` | address of a blockchain node |
| deployment.ethereum.enabled | bool | `true` | should canis-major connect to an ethereum blockchain |
| deployment.ethereum.gas | int | `3000000` | gas to be used for the transactions |
| deployment.ethereum.gasPrice | int | `0` | price of the gas |
| deployment.healthPort | int | `9090` | port to request health information at |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"quay.io/fiware/canis-major"` | canis-major image name ref: https://quay.io/repository/fiware/canis-major |
| deployment.image.tag | string | `"1.5.15"` | tag of the image to be used |
| deployment.livenessProbe.initialDelaySeconds | int | `30` |  |
| deployment.livenessProbe.periodSeconds | int | `10` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| deployment.ngsi | object | `{"path":"ngsi-ld/v1","tenant":"default","url":"http://ngsi-ld-broker:1026"}` | configuration for connecting the ngsi-ld api |
| deployment.ngsi.path | string | `"ngsi-ld/v1"` | path to be used as base |
| deployment.ngsi.tenant | string | `"default"` | tenant to be used with the api |
| deployment.ngsi.url | string | `"http://ngsi-ld-broker:1026"` | url that ngsi-ld is available at |
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
| ingress.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.enabled | bool | `false` | should there be an ingress to connect canis-major with the public internet |
| ingress.hosts | list | `[]` | all hosts to be provided |
| ingress.tls | list | `[]` | configure the ingress' tls |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| port | int | `8080` | port that the canis-major container uses |
| prometheus.enabled | bool | `true` | should prometheus scrape be enabled |
| prometheus.path | string | `"/prometheus"` | path for prometheus scrape |
| prometheus.port | int | `9090` | port prometheus scrape is available at |
| route.annotations | object | `{}` | annotations to be added to the route |
| route.certificate | object | `{}` |  |
| route.enabled | bool | `false` |  |
| route.tls | object | `{}` | tls configuration for the route |
| service.annotations | object | `{}` | additional annotations, if required |
| service.port | int | `8080` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a canis-major specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
