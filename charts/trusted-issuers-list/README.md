# trusted-issuers-list

![Version: 0.10.5](https://img.shields.io/badge/Version-0.10.5-informational?style=flat-square) ![AppVersion: 0.4.0](https://img.shields.io/badge/AppVersion-0.4.0-informational?style=flat-square)

A Helm chart for running the trusted-issuers-list on kubernetes.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| wistefan | <stefan.wiedemann@fiware.org> |  |

## Source Code

* <https://github.com/fiware/trusted-issuers-list>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnvVars | object | `{}` |  |
| additonalEnvVars | list | `[]` | a list of additional env vars to be set, check the til docu for all available options |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | metrics to react on |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| config | object | `{}` |  |
| database.dialect | string | `"mysql"` |  |
| database.existingSecret | object | `{"enabled":false,"key":"password","name":"the-secret"}` | existing secret to retrieve the db password |
| database.existingSecret.enabled | bool | `false` | should an existing secret be used |
| database.existingSecret.key | string | `"password"` | key to retrieve the password from |
| database.existingSecret.name | string | `"the-secret"` | name of the secret |
| database.host | string | `"mysql"` | host of the database to be connected - will be ignored if persistence is disabled |
| database.name | string | `"til-db"` | name of the database-schema to be accessed - will be ignored if persistence is disabled |
| database.password | string | `"password"` | passowrd to connect the db - ignored if existing secret is configured |
| database.persistence | bool | `false` | should the database support persistence? If disabled, a H2-InMemory-Database will be used. |
| database.port | int | `3306` | port of the database to be connected - will be ignored if persistence is disabled |
| database.username | string | `"user"` | username to conncet the db - ignored if existing secret is configured |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.healthPort | int | `9090` | port to request health information at |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"quay.io/fiware/trusted-issuers-list"` | til image name ref: https://quay.io/repository/fiware/trusted-issuers-list |
| deployment.image.tag | string | `"0.4.0"` | tag of the image to be used |
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
| deployment.resources | object | `{}` |  |
| deployment.revisionHistoryLimit | int | `3` | number of old replicas to be retained |
| deployment.tolerations | list | `[]` | tolerations template ref: ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| deployment.updateStrategy.rollingUpdate | object | `{"maxSurge":1,"maxUnavailable":0}` | new pods will be added gradually |
| deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` | number of pods that can be created above the desired amount while updating |
| deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` | number of pods that can be unavailable while updating |
| deployment.updateStrategy.type | string | `"RollingUpdate"` | type of the update |
| fullnameOverride | string | `""` | option to override the fullname config in the _helpers.tpl |
| ingress.til | object | `{"annotations":{},"enabled":false,"hosts":[],"tls":[]}` | route config for the trusted issuers list endpoint |
| ingress.til.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.til.enabled | bool | `false` | should there be an ingress to connect til with the public internet |
| ingress.til.hosts | list | `[]` | all hosts to be provided |
| ingress.til.tls | list | `[]` | configure the ingress' tls |
| ingress.tir | object | `{"annotations":{},"enabled":false,"hosts":[],"tls":[]}` | route config for the trusted issuers registry endpoint |
| ingress.tir.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.tir.enabled | bool | `false` | should there be an ingress to connect til with the public internet |
| ingress.tir.hosts | list | `[]` | all hosts to be provided |
| ingress.tir.tls | list | `[]` | configure the ingress' tls |
| initData.backoffLimit | int | `1` | Number of retries before considering a Job as failed |
| initData.hook | string | `"post-install,post-upgrade"` | Annotation value for the Hook |
| initData.initEnabled | bool | `false` | should the creation of initial entries be enabled |
| initData.issuers | list | `[]` | Array of trusted issuers to be created |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| port | int | `8080` | port that the til container uses |
| prometheus.enabled | bool | `true` | should prometheus scrape be enabled |
| prometheus.path | string | `"/prometheus"` | path for prometheus scrape |
| prometheus.port | int | `9090` | port prometheus scrape is available at |
| route.til | object | `{"annotations":{},"certificate":{},"enabled":false,"tls":{}}` | route config for the trusted issuers list endpoint |
| route.til.annotations | object | `{}` | annotations to be added to the route |
| route.til.tls | object | `{}` | tls configuration for the route |
| route.tir | object | `{"annotations":{},"certificate":{},"enabled":false,"tls":{}}` | route config for the trusted issuers registry endpoint |
| route.tir.annotations | object | `{}` | annotations to be added to the route |
| route.tir.tls | object | `{}` | tls configuration for the route |
| service.annotations | object | `{}` | additional annotations, if required |
| service.port | int | `8080` | port to be used by the service |
| service.serviceNameOverride | string | `""` | define the name of the service and avoid generating one |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a til specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
