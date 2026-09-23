# lepus

![Version: 0.5.0](https://img.shields.io/badge/Version-0.5.0-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

A Helm chart for running lepus on kubernetes.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| jason-fox | <jason.fox@fiware.org> |  |

## Source Code

* <https://github.com/jason-fox/lepus>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additonalEnvVars | list | `[]` | a list of additional env vars to be set, check the lepus docu for all available options |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | metrics to react on |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| coreContext.url | string | `"https://uri.etsi.org/ngsi-ld/v1/ngsi-ld-core-context-v1.9.jsonld"` |  |
| debug | string | `"adapter:*"` |  |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"fiware/lepus"` | lepus image name ref: https://hub.docker.com/r/fiware/lepus |
| deployment.image.tag | string | `"latest"` | tag of the image to be used |
| deployment.livenessProbe | object | `{"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":30}` | port to request health information at healthPort: 9090 # liveness and readiness probes of the lepus broker, they will be evaluated against the version endpoint ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes |
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
| host | string | `"http://localhost"` | host where lepus is available at |
| ingress.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.enabled | bool | `false` | should there be an ingress to connect lepus with the public internet |
| ingress.hosts | list | `[]` | all hosts to be provided |
| ingress.tls | list | `[]` | configure the ingress' tls |
| lepus.alias | string | `"lepus"` |  |
| lepus.multiCore | bool | `true` |  |
| lepus.timeout | int | `1000` |  |
| lepus.url | string | `"https://adapter:3000"` |  |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| notification.url | string | `"http://adapter:3000/notify"` |  |
| orion.timeout | int | `1000` |  |
| orion.url | string | `"http://orion:1026'"` |  |
| port | int | `3000` | port that the lepus container uses |
| route.annotations | object | `{}` | annotations to be added to the route |
| route.enabled | bool | `false` |  |
| route.tls | object | `{}` | tls configuration for the route |
| service.annotations | object | `{}` | addtional annotations, if required |
| service.port | int | `3000` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a lepus specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |
| userContext.url | string | `"https://fiware.github.io/tutorials.Step-by-Step/tutorials-context.jsonld"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
