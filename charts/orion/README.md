# Orion

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![AppVersion: 2.5.0](https://img.shields.io/badge/AppVersion-2.5.0-informational?style=flat-square)

A Helm chart for running the fiware orion broker on kubernetes.

**Homepage:** <https://fiware-orion.readthedocs.io/en/master/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| wistefan | stefan.wiedemann@fiware.org |  |

## Source Code

* <https://github.com/telefonicaid/fiware-orion>
* <https://github.com/FIWARE/context.Orion-LD>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaling.enabled | bool | `false` | should autoscaling be enabled for the context broker |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | metrics to react on |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| broker.db.hosts | list | `["mongodb"]` | configuration of the mongo-db hosts. if multiple hosts are inserted, its assumed that mongo is running as a replica set |
| broker.db.name | string | `"orion"` | the db to use. if running in multiservice mode, its used as a prefix. |
| broker.envPrefix | string | `"ORIONLD_"` | Prefix to be used for env-vars in orion. Must be ORION_ for orion and ORIONLD_ for orion-ld |
| broker.ipv4enabled | bool | `false` | set to true if only ipv4 should be used, do not set both options to true |
| broker.ipv6enabled | bool | `false` | set to true if only ipv6 should be used, do not set both options to true |
| broker.logging.level | string | `"WARN"` | log level of the broker |
| broker.metrics.enabled | bool | `false` | enable or disable metrics gathering |
| broker.port | int | `1026` | port that the broker is listening to |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"fiware/orion-ld"` | orion image name ref: https://hub.docker.com/r/fiware/orion-ld |
| deployment.image.tag | string | `"latest"` |  |
| deployment.livenessProbe.initialDelaySeconds | int | `30` |  |
| deployment.livenessProbe.periodSeconds | int | `10` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| deployment.nodeSelector | object | `{}` | orion resource requests and limits, we leave the default empty to make that a concious choice by the user. for the autoscaling to make sense, you should configure this. resources: limits: cpu: 100m memory: 128Mi requests: cpu: 100m memory: 128Mi -- selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| deployment.readinessProbe.initialDelaySeconds | int | `30` |  |
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
| ingress.enabled | bool | `false` | should there be an ingress to connect orion with the public internet |
| ingress.hosts | list | `[]` |  |
| ingress.tls | list | `[]` | provide a hosts and the paths that should be available - host: localhost paths: - / -- configure the ingress' tls |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| service.annotations | object | `{}` | addtional annotations, if required |
| service.port | int | `1026` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a orion specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.4.0](https://github.com/norwoodj/helm-docs/releases/v1.4.0)
