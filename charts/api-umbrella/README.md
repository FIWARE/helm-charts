# api-umbrella

![Version: 0.0.10](https://img.shields.io/badge/Version-0.0.10-informational?style=flat-square) ![AppVersion: v0.18.0](https://img.shields.io/badge/AppVersion-v0.18.0-informational?style=flat-square)

A Helm chart for running api-umbrella on kubernetes.

**Homepage:** <https://api-umbrella.readthedocs.io/en/latest/index.html>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| wistefan | <stefan.wiedemann@fiware.org> |  |

## Source Code

* <https://github.com/NREL/api-umbrella>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.image | object | `{"pullPolicy":"IfNotPresent","repository":"fiware/api-umbrella","tag":"0.18.0"}` | configuration of the image to be used |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.tag | string | `"0.18.0"` | tag of the image to be used |
| deployment.livenessProbe | object | `{"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":30}` | liveness and readiness probes of the orion broker, they will be evaluated against the version endpoint ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes |
| deployment.nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| deployment.readinessProbe.initialDelaySeconds | int | `30` |  |
| deployment.readinessProbe.periodSeconds | int | `10` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.timeoutSeconds | int | `30` |  |
| deployment.replicaCount | int | `1` | initial number of target replications, can be different if autoscaling is enabled |
| deployment.revisionHistoryLimit | int | `3` | number of old replicas to be retained |
| deployment.tolerations | list | `[]` | tolerations template ref: ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| deployment.updateStrategy | object | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` | configuration of the orion update strategy |
| deployment.updateStrategy.rollingUpdate | object | `{"maxSurge":1,"maxUnavailable":0}` | new pods will be added gradually |
| deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` | number of pods that can be created above the desired amount while updating |
| deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` | number of pods that can be unavailable while updating |
| deployment.updateStrategy.type | string | `"RollingUpdate"` | type of the update |
| fullnameOverride | string | `""` | option to override the fullname config in the _helpers.tpl |
| ingress.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.enabled | bool | `false` | should there be an ingress to connect orion with the public internet |
| ingress.hosts | string | `nil` | all hosts to be provided |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| route.annotations | object | `{}` | annotations to be added to the route |
| route.enabled | bool | `false` |  |
| route.tls | object | `{}` | tls configuration for the route |
| service.annotations | object | `{}` | addtional annotations, if required |
| service.port | int | `80` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount.create | bool | `false` | specifies if the account should be created, be aware that the chart needs to run as root and sets the corresponding security context |
| umbrella.config | object | `{}` | configuration of the umbrella. See https://github.com/Profirator/api-umbrella/tree/master/config and https://api-umbrella.readthedocs.io/en/latest/ for more or use the out-commented part as a sane default |
| umbrella.mongodb.host | string | `"mongodb"` | host of the mongodb |
| umbrella.mongodb.name | string | `"api_umbrella"` | name of the database, needs to exist on startup |
| umbrella.mongodb.password | string | `"pass"` | password to authenticate with, if not set, we will create it |
| umbrella.mongodb.port | int | `27017` | port of the mongodb |
| umbrella.mongodb.username | string | `"umbrella"` | username to authenticate with. If the user does not exist, admin config is required and a user will be created |
| umbrella.services | list | `["router","web"]` | list services that should be run by api-umbrella. See https://github.com/Profirator/api-umbrella/tree/master/config and https://api-umbrella.readthedocs.io/en/latest/ for more |
| umbrella.webHost | string | `"umbrella.fiware.dev"` | configure the host of the frontend here |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
