# fdsc-dashboard

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

A Helm chart for running the fdsc-dashboard on kubernetes.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| wistefan | <stefan.wiedemann@seamware.org> |  |

## Source Code

* <https://github.com/wistefan/fdsc-dashboard>

## Requirements

Kubernetes: `>= 1.19-0`

| Repository | Name | Version |
|------------|------|---------|
| https://fiware.github.io/helm-charts | common | 0.0.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnvVars | list | `[]` | a list of additional env vars to be set on the dashboard container, in native env-var form. Useful for custom-built images that consume additional configuration at runtime. |
| apiUrls.authToken | string | `""` | build-time URL for obtaining an auth token (VITE_AUTH_TOKEN_URL). Stock image ignores this key at runtime. |
| apiUrls.ccs | string | `""` | build-time URL of the Credentials Config Service (VITE_CCS_URL). Stock image ignores this key at runtime. |
| apiUrls.odrl | string | `""` | build-time URL of the ODRL PAP (VITE_ODRL_URL). Stock image ignores this key at runtime. |
| apiUrls.til | string | `""` | build-time URL of the Trusted Issuer List (VITE_TIL_URL). Stock image ignores this key at runtime. |
| apiUrls.tir | string | `""` | build-time URL of the Trusted Issuer Registry (VITE_TIR_URL). Stock image ignores this key at runtime. |
| auth.config | object | `{"providers":[]}` | raw OIDC providers configuration, rendered as JSON into the chart's Secret when `existingSecret` is empty. Default: auth disabled (no providers). See upstream docs for the full schema. |
| auth.existingSecret | string | `""` | name of a pre-existing Secret containing the `AUTH_CONFIG_JSON` key. When set, the chart will not render its own Secret and the Deployment will reference this Secret instead. |
| auth.secretKey | string | `"AUTH_CONFIG_JSON"` | key inside the Secret (chart-rendered or `existingSecret`) to mount into the `AUTH_CONFIG_JSON` env var |
| autoscaling.apiVersion | string | `"v2beta2"` | apiVersion of the HorizontalPodAutoscaler resource emitted by the `common.hpa.tpl` helper. Users on Kubernetes 1.26+ may wish to override this to "v2". |
| autoscaling.enabled | bool | `false` | should autoscaling be enabled for the fdsc-dashboard |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | metrics to react on |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.additionalVolumeMounts | list | `[]` | additional volume mounts for the fdsc-dashboard container, if required |
| deployment.additionalVolumes | list | `[]` | additional volumes for the fdsc-dashboard pod, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.args | list | `[]` | override the default `args` of the container image |
| deployment.command | list | `[]` | override the default `command` of the container image |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"quay.io/seamware/fdsc-dashboard"` | fdsc-dashboard image name ref: https://quay.io/repository/seamware/fdsc-dashboard |
| deployment.imagePullSecrets | list | `[]` | secrets for pulling the fdsc-dashboard image from a private registry |
| deployment.livenessProbe.failureThreshold | int | `3` |  |
| deployment.livenessProbe.initialDelaySeconds | int | `30` |  |
| deployment.livenessProbe.periodSeconds | int | `10` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| deployment.nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| deployment.readinessProbe.failureThreshold | int | `3` |  |
| deployment.readinessProbe.initialDelaySeconds | int | `31` |  |
| deployment.readinessProbe.periodSeconds | int | `10` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.timeoutSeconds | int | `30` |  |
| deployment.replicaCount | int | `1` | initial number of target replicas, can be different if autoscaling is enabled |
| deployment.revisionHistoryLimit | int | `3` | number of old replicas to be retained |
| deployment.tolerations | list | `[]` | tolerations template ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| deployment.updateStrategy.rollingUpdate | object | `{"maxSurge":1,"maxUnavailable":0}` | new pods will be added gradually |
| deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` | number of pods that can be created above the desired amount while updating |
| deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` | number of pods that can be unavailable while updating |
| deployment.updateStrategy.type | string | `"RollingUpdate"` | type of the update |
| fullnameOverride | string | `""` | option to override the fullname config in the _helpers.tpl |
| ingress.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.enabled | bool | `false` | should there be an ingress to connect the fdsc-dashboard with the public internet |
| ingress.hosts | list | `[]` | all hosts to be provided |
| ingress.tls | list | `[]` | configure the ingress' tls |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| port | int | `80` | container port that the fdsc-dashboard (nginx) listens on |
| route.annotations | object | `{}` | annotations to be added to the route |
| route.enabled | bool | `false` | should the deployment create openshift routes |
| route.tls | object | `{}` | tls configuration for the route |
| service.annotations | object | `{}` | additional annotations, if required |
| service.port | int | `8080` | port to be used by the service; targets the container port (`.Values.port`). |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a fdsc-dashboard specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
