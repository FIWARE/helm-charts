# consent-facade

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![AppVersion: 0.0.14](https://img.shields.io/badge/AppVersion-0.0.14-informational?style=flat-square)

A Helm chart for running the consent-facade on kubernetes.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| wistefan | <stefan.wiedemann@seamware.com> |  |

## Source Code

* <https://github.com/wistefan/consent-facade>

## Requirements

Kubernetes: `>= 1.19-0`

| Repository | Name | Version |
|------------|------|---------|
| https://fiware.github.io/helm-charts | common | 0.1.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalEnvVars | list | `[]` | a list of additional env vars to be set, in plain kubernetes shape |
| autoscaling.apiVersion | string | `"v2"` | version of the autoscaling api to be used |
| autoscaling.enabled | bool | `false` | should autoscaling be enabled for the consent-facade |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | metrics to react on |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.additionalVolumeMounts | list | `[]` | additional volume mounts, if required |
| deployment.additionalVolumes | list | `[]` | additional volumes, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"quay.io/seamware/consent-facade"` | consent-facade image name ref: https://quay.io/repository/seamware/consent-facade |
| deployment.image.tag | string | `""` | overrides the image tag whose default is the chart appVersion |
| deployment.initContainers | list | `[]` | additional init containers, if required |
| deployment.livenessProbe.failureThreshold | int | `3` |  |
| deployment.livenessProbe.initialDelaySeconds | int | `20` |  |
| deployment.livenessProbe.periodSeconds | int | `20` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| deployment.managementPort | int | `9090` | port the management endpoints (incl. /health) are served on. It is a separate port from the api, matching `endpoints.all.port` in the image's configuration. |
| deployment.nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| deployment.podSecurityContext | object | `{"runAsNonRoot":true}` | security context for the pod |
| deployment.readinessProbe.failureThreshold | int | `3` |  |
| deployment.readinessProbe.initialDelaySeconds | int | `10` |  |
| deployment.readinessProbe.periodSeconds | int | `10` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.timeoutSeconds | int | `30` |  |
| deployment.replicaCount | int | `1` | initial number of target replications, can be different if autoscaling is enabled |
| deployment.resources | object | `{}` |  |
| deployment.revisionHistoryLimit | int | `3` | number of old replicas to be retained |
| deployment.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` | security context for the containers |
| deployment.tolerations | list | `[]` | tolerations template ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| deployment.updateStrategy.rollingUpdate | object | `{"maxSurge":1,"maxUnavailable":0}` | new pods will be added gradually |
| deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` | number of pods that can be created above the desired amount while updating |
| deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` | number of pods that can be unavailable while updating |
| deployment.updateStrategy.type | string | `"RollingUpdate"` | type of the update |
| env | object | `{}` | a map of additional env vars to be set, check the consent-facade documentation for all available options |
| envValueFrom | object | `{}` | a map of additional env vars to be read from another source (secret, configmap, field), keyed by the env var name |
| fullnameOverride | string | `""` | option to override the fullname config in the _helpers.tpl |
| ingress.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.className | string | `""` | ingress class to be used |
| ingress.enabled | bool | `false` | should an ingress be created |
| ingress.hosts | list | `[]` | hosts to be used, each with a list of paths |
| ingress.tls | list | `[]` | tls configuration |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| oid4vp.clientId | string | `""` | client id used at the token endpoint |
| oid4vp.credentials | list | `[]` | the credentials to present, each projected from its own secret into `credentialsFolder`. Entries: `secretName`, `secretKey`, `fileName`. |
| oid4vp.credentialsFolder | string | `"/credentials"` | folder the credentials are mounted into |
| oid4vp.enabled | bool | `false` | should the facade authenticate its outbound TM Forum reads over OID4VP |
| oid4vp.holder.id | string | `""` | the holder id, e.g. a did:web the credential was issued to |
| oid4vp.holder.keyPath | string | `"/signing-key/tls.key"` | path of the signing key inside the container. When `signingKey.convert` is enabled this is where the converted key is written. |
| oid4vp.holder.keyType | string | `"EC"` | type of the signing key |
| oid4vp.holder.signatureAlgorithm | string | `"ES256"` | algorithm to sign the presentation with |
| oid4vp.proxy.enabled | bool | `false` | should the OID4VP client use a forward proxy |
| oid4vp.proxy.host | string | `""` | host of the proxy |
| oid4vp.proxy.port | int | `8888` | port of the proxy |
| oid4vp.proxy.tmForumClients | bool | `false` | should the TM Forum clients use the proxy too. Only correct when the TM Forum API is external: a cluster-internal Service name cannot be resolved by the proxy. |
| oid4vp.scopes | list | `["default"]` | scopes to request |
| oid4vp.signingKey.convert | bool | `true` | cert-manager stores an EC key in SEC1 (`EC PRIVATE KEY`), while the holder signing service needs PKCS#8 (`PRIVATE KEY`). With this enabled an init container converts it; disable it when the secret already holds PKCS#8. |
| oid4vp.signingKey.convertImage | string | `"alpine/openssl:3.3.2"` | image used for the conversion, needs an `openssl` binary |
| oid4vp.signingKey.secretKey | string | `"tls.key"` | key inside that secret |
| oid4vp.signingKey.secretName | string | `""` | name of the secret holding the key |
| oid4vp.tokenTargets | list | `[]` | the services the facade obtains a token for. One entry per audience: `audience`, `url`, and optionally `clientId`, `scope` (list) and `discoveryPath` (a verifier that serves OIDC discovery per service rather than at the host root). |
| oid4vp.trustAnchors | list | `[]` | PEM trust anchors used to identify the credential issuer, as paths inside the container |
| port | int | `8080` | port that the consent-facade container uses |
| prometheus.enabled | bool | `true` | should prometheus scrape be enabled |
| prometheus.path | string | `"/prometheus"` | path for prometheus scrape |
| prometheus.port | int | `9090` | port prometheus scrape is available at |
| providerRegistry.database.existingSecret.key | string | `""` | key of the password inside that secret |
| providerRegistry.database.existingSecret.name | string | `""` | name of the secret. Defaults to the chart's fullname, which is the secret this chart creates from `password`. |
| providerRegistry.database.host | string | `"postgresql"` | host of the database |
| providerRegistry.database.name | string | `"facade"` | name of the database |
| providerRegistry.database.password | string | `""` | password to connect with. Prefer `existingSecret` over this: a password here ends up in the release's values. |
| providerRegistry.database.port | int | `5432` | port of the database |
| providerRegistry.database.username | string | `"facade"` | user to connect with |
| providerRegistry.persistent | bool | `false` | should the provider registry be persisted in PostgreSQL |
| route.annotations | object | `{}` | annotations to be added to the route |
| route.enabled | bool | `false` | should a route be created |
| route.host | string | `""` | host to be used |
| route.tls | object | `{}` | tls configuration |
| selfUrl | string | `""` | the public base url the facade mints its ids with. It is written into the contracts, catalog entries and participant self-descriptions it serves, and consumers (the consent-manager, auditors, other participants) match participants on those exact strings - so it has to be the address the facade is reachable at from outside the cluster. Defaults to the in-cluster service address, which is only correct for a deployment without external consumers. Templated, so `{{ .Release.Name }}` works. |
| service.annotations | object | `{}` | additional annotations, if required |
| service.port | int | `8080` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a consent-facade specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |
| tmForum.services | object | `{}` | per-api base url overrides, keyed by the facade's service name (product-order, product-catalog, product-inventory, party, agreement). An entry here wins over `url`, for a deployment that spreads the TM Forum APIs over several hosts. |
| tmForum.url | string | `"http://tm-forum-api:8080"` | base url of the TM Forum API. Every TM Forum client (product order, product catalog, product inventory, party, agreement) is pointed at it; the per-api paths are part of the image's configuration. Set `services` below to address them individually instead. |
| truststore.caSecret.key | string | `"ca.crt"` | key inside that secret |
| truststore.caSecret.name | string | `""` | name of the secret |
| truststore.enabled | bool | `false` | should an additional CA be imported into the JVM truststore |
| truststore.javaHome | string | `""` | explicit JDK home inside the image, used to locate `lib/security/cacerts` and `bin/keytool`. Empty resolves it at runtime from $JAVA_HOME, falling back to the keytool/java binary on PATH - so an image whose base image changed keeps working. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
