# consent-owner-resolver

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![AppVersion: 0.0.8](https://img.shields.io/badge/AppVersion-0.0.8-informational?style=flat-square)

A Helm chart for running the consent-owner-resolver on kubernetes.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| wistefan | <stefan.wiedemann@seamware.com> |  |

## Source Code

* <https://github.com/wistefan/consent-owner-resolver>

## Requirements

Kubernetes: `>= 1.19-0`

| Repository | Name | Version |
|------------|------|---------|
| https://fiware.github.io/helm-charts | common | 0.1.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnvVars | list | `[]` | a list of additional env vars to be set, in plain kubernetes shape |
| auth.existingSecret.key | string | `""` | key of the token inside that secret |
| auth.existingSecret.name | string | `""` | name of the secret. Defaults to the chart's fullname, which is the secret this chart creates from `token`. |
| auth.token | string | `""` | shared token callers have to present. Empty leaves /resolve unauthenticated - the resolver logs a warning on start when that is the case. |
| autoscaling.apiVersion | string | `"v2"` | version of the autoscaling api to be used |
| autoscaling.enabled | bool | `false` | should autoscaling be enabled for the consent-owner-resolver |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | metrics to react on |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| config | object | `{}` | the complete resolver configuration, written verbatim instead of assembling it from `defaults` / `contractService` / `rules`. Use it for a shape this chart does not model. |
| contractService.enabled | bool | `false` | should a contract service be configured |
| contractService.providerSelfDescription | string | `""` | the provider self-description contracts are looked up with. Usually supplied per request by the caller instead, because it embeds an id that is only known once the participant is registered. Templated. |
| contractService.resourceCacheTtlMs | string | `""` | how long a contract's resolved data resources may be reused, in milliseconds. Empty uses the service's own default. |
| contractService.timeoutMs | int | `3000` | how long to wait for the contract service, in milliseconds |
| contractService.url | string | `"http://consent-facade:8080"` | base url of the contract service. Templated, so `{{ .Release.Namespace }}` works. |
| defaults.consentRequired | bool | `false` | whether data no rule matches needs a consent. `false` lets unmatched data pass the gate; `true` denies everything the rules do not describe. |
| defaults.scheme | string | `"identifier"` | how the resolved owner is to be interpreted by the caller, e.g. `identifier` |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.additionalVolumeMounts | list | `[]` | additional volume mounts, if required |
| deployment.additionalVolumes | list | `[]` | additional volumes, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.configFolder | string | `"/etc/owner-resolver"` | folder the configuration is mounted into |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"quay.io/seamware/consent-owner-resolver"` | consent-owner-resolver image name ref: https://quay.io/repository/seamware/consent-owner-resolver |
| deployment.image.tag | string | `""` | overrides the image tag whose default is the chart appVersion |
| deployment.livenessProbe.failureThreshold | int | `3` |  |
| deployment.livenessProbe.initialDelaySeconds | int | `5` |  |
| deployment.livenessProbe.periodSeconds | int | `20` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.timeoutSeconds | int | `5` |  |
| deployment.nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| deployment.podSecurityContext | object | `{"runAsNonRoot":true,"runAsUser":10100,"seccompProfile":{"type":"RuntimeDefault"}}` | security context for the pod |
| deployment.readinessProbe.failureThreshold | int | `3` |  |
| deployment.readinessProbe.initialDelaySeconds | int | `2` |  |
| deployment.readinessProbe.periodSeconds | int | `10` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.timeoutSeconds | int | `5` |  |
| deployment.replicaCount | int | `1` | initial number of target replications, can be different if autoscaling is enabled |
| deployment.resources.limits.cpu | string | `"250m"` |  |
| deployment.resources.limits.memory | string | `"128Mi"` |  |
| deployment.resources.requests.cpu | string | `"50m"` |  |
| deployment.resources.requests.memory | string | `"32Mi"` |  |
| deployment.revisionHistoryLimit | int | `3` | number of old replicas to be retained |
| deployment.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` | security context for the container |
| deployment.tolerations | list | `[]` | tolerations template ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| deployment.updateStrategy.rollingUpdate | object | `{"maxSurge":1,"maxUnavailable":0}` | new pods will be added gradually |
| deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` | number of pods that can be created above the desired amount while updating |
| deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` | number of pods that can be unavailable while updating |
| deployment.updateStrategy.type | string | `"RollingUpdate"` | type of the update |
| env | object | `{}` | a map of additional env vars to be set, check the consent-owner-resolver documentation for all available options |
| envValueFrom | object | `{}` | a map of additional env vars to be read from another source (secret, configmap, field), keyed by the env var name |
| fullnameOverride | string | `""` | option to override the fullname config in the _helpers.tpl |
| logLevel | string | `""` | log level. `debug` makes the resolver log the requested path and the resolve error verbatim instead of an error class - both can carry owner identifiers, so it is meant to be temporary, and it is the switch to reach for when a request is denied and the error class does not say which check failed. |
| maxBodyBytes | string | `""` | maximum size of a request body the resolver examines, in bytes. A body above it is rejected rather than parsed. Empty uses the service's own default. |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| networkPolicy.allowedClients | list | `[]` | pod selectors of the clients allowed to call the resolver, in plain kubernetes shape. Usually just the consent enforcement point. |
| networkPolicy.enabled | bool | `false` | should a network policy be created |
| port | int | `8080` | port that the consent-owner-resolver container uses |
| prometheus.enabled | bool | `true` | should prometheus scrape be enabled |
| prometheus.path | string | `"/metrics"` | path for prometheus scrape |
| prometheus.port | int | `8080` | port prometheus scrape is available at |
| rules | list | `[]` | the rules deciding, per request, whether a consent is required and where the data owner is found. They are evaluated in order and the first match wins; a request no rule matches falls back to `defaults`. Rendered verbatim into the configuration, so every matcher the service supports can be expressed.  A rule is `name`, `match` (`service`, `pathPattern`), `consentRequired` and a `matcher`. The `matcher` is either   * `type: json` — the owner is read from the payload at the `owner` JSON pointer, or   * `type: contract` — additionally looks up the signed contract governing the object     at `uriPointer` and takes the data resource to check the consent for from it     (needs `contractService` above). `items` selects the collection within the payload (empty = the whole body) and `itemsIsArray` says whether it is an array. |
| service.annotations | object | `{}` | additional annotations, if required |
| service.port | int | `8080` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a consent-owner-resolver specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
