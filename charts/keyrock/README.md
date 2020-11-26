# keyrock

![Version: 0.0.2](https://img.shields.io/badge/Version-0.0.2-informational?style=flat-square) ![AppVersion: 7.9.0](https://img.shields.io/badge/AppVersion-7.9.0-informational?style=flat-square)

A Helm chart for running the fiware idm keyrock on kubernetes.

**Homepage:** <https://fiware-idm.readthedocs.io/en/latest/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| wistefan | stefan.wiedemann@fiware.org |  |

## Source Code

* <https://github.com/ging/fiware-idm>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additonalEnvVars | list | `[]` | a list of additional env vars to be set, check the keyrock docu for all available options ref: https://fiware-idm.readthedocs.io/en/latest/installation_and_administration_guide/environment_variables/index.html |
| admin.email | string | `"admin@admin.org"` | email address of the admin user |
| admin.password | string | `"admin"` | password of the initial admin, leave empty to get a generated one |
| admin.user | string | `"admin"` | username of the initial keyrock admin |
| autoscaling.enabled | bool | `false` | should autoscaling be enabled for keyrock |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | metrics to react on |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| db.host | string | `"mysql"` | host of the database to be used |
| db.password | string | `"pass"` | password for connecting the database |
| db.user | string | `"root"` | user for connecting the database |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"fiware/idm"` | keyrock image name ref: https://hub.docker.com/r/fiware/idm |
| deployment.image.tag | string | `"7.9.0"` | tag of the image to be used |
| deployment.livenessProbe.initialDelaySeconds | int | `30` |  |
| deployment.livenessProbe.periodSeconds | int | `10` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| deployment.nodeSelector | object | `{}` |  |
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
| host | string | `"http://localhost"` | host where keyrock is available at |
| ingress.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.enabled | bool | `false` | should there be an ingress to connect keyrock with the public internet |
| ingress.hosts | list | `[]` |  |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| port | int | `8080` | port that the keyrock container uses |
| route.annotations | object | `{}` | annotations to be added to the route |
| route.enabled | bool | `false` |  |
| route.tls | object | `{}` | host to be used host: localhost -- tls configuration for the route |
| service.annotations | object | `{}` | addtional annotations, if required |
| service.port | int | `8080` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a keyrock specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.4.0](https://github.com/norwoodj/helm-docs/releases/v1.4.0)
