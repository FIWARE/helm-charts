# odrl-pap

![Version: 2.6.0](https://img.shields.io/badge/Version-2.6.0-informational?style=flat-square) ![AppVersion: 1.3.5](https://img.shields.io/badge/AppVersion-1.3.5-informational?style=flat-square)

A Helm chart for running the odrl-pap on kubernetes.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Wiedemann | <stefan.wiedemann@fiware.org> |  |

## Source Code

* <https://github.com/wistefan/odrl-pap>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalMapping.enabled | bool | `false` | should an additional mapping.json be loaded |
| additionalMapping.json | string | `"{\n  \"action\": {\n    \"odrl\": {\n      \"use\" : {\n        \"regoPackage\": \"custom.action as custom_action\",\n        \"regoMethod\": \"custom_action.is_use(helper.http_part)\"\n      }\n    }\n  }\n}\n"` | mapping.json to merged with the defaults the example would overwrite the default odrl:use to be handled by a custom rego method provided with the additional rego |
| additionalRego.enabled | bool | `false` | should additional packages be loaded |
| additionalRego.packages | string | `"action.rego: |\n  package odrl.action\n\n  import rego.v1\n\n  ## odrl:use\n  # checks if the given request is a usage - in constrast to the default, this example would only consider modifications a \"use\"\n  is_use(request) if {\n      methods := [\"POST\", \"PUT\", \"PATCH\"]\n      request.method in methods\n  }\n"` |  |
| additonalEnvVars | list | `[]` | a list of additional env vars to be set, check the til docu for all available options |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | metrics to react on |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| database.existingSecret | object | `{"enabled":false,"key":"password","name":"the-secret"}` | existing secret to retrieve the db password |
| database.existingSecret.enabled | bool | `false` | should an existing secret be used |
| database.existingSecret.key | string | `"password"` | key to retrieve the password from |
| database.existingSecret.name | string | `"the-secret"` | name of the secret |
| database.password | string | `"password"` | passowrd to connect the db - ignored if existing secret is configured |
| database.url | string | `"jdbc:postgresql://localhost:5432/pap"` | host of the database to be connected - will be ignored if persistence is disabled |
| database.username | string | `"user"` | username to conncet the db - ignored if existing secret is configured |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.additionalVolumeMounts | list | `[]` | additional volume mounts |
| deployment.additionalVolumes | list | `[]` | additional volumes to be added for the containers |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.args | list | `[]` | arguments to be set for the container |
| deployment.command | list | `[]` | command to be used for starting the container |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"quay.io/fiware/odrl-pap"` | til image name ref: https://quay.io/repository/wistefan/odrl-pap |
| deployment.image.tag | string | `""` | overrides the image tag whose default is the chart appVersion |
| deployment.imagePullSecrets | list | `[]` | secrets for pulling images from a private repository ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| deployment.livenessProbe.failureThreshold | int | `3` |  |
| deployment.livenessProbe.initialDelaySeconds | int | `30` |  |
| deployment.livenessProbe.periodSeconds | int | `10` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| deployment.nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| deployment.port | int | `8080` | port that the pap container uses |
| deployment.readinessProbe.failureThreshold | int | `3` |  |
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
| ingress.enabled | bool | `false` | should there be an ingress to connect til with the public internet |
| ingress.hosts | list | `[]` | all hosts to be provided |
| ingress.tls | list | `[]` | configure the ingress' tls |
| management.port | int | `9090` | port to be used for health and prometheus |
| management.prometheus.enabled | bool | `true` | should prometheus scrape be enabled |
| management.prometheus.path | string | `"/prometheus"` | path for prometheus scrape |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| route.annotations | object | `{}` | annotations to be added to the route |
| route.certificate | object | `{}` |  |
| route.enabled | bool | `false` |  |
| route.tls | object | `{}` | tls configuration for the route |
| service.annotations | object | `{}` | additional annotations, if required |
| service.port | int | `8080` | port to be used by the service |
| service.serviceNameOverride | string | `""` | define the name of the service and avoid generating one |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a til specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
