# consent-manager

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![AppVersion: 0.0.6](https://img.shields.io/badge/AppVersion-0.0.6-informational?style=flat-square)

A Helm chart for running the consent-manager on kubernetes.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| wistefan | <stefan.wiedemann@seamware.com> |  |

## Source Code

* <https://github.com/VisionsOfficial/consent-manager>

## Requirements

Kubernetes: `>= 1.19-0`

| Repository | Name | Version |
|------------|------|---------|
| https://fiware.github.io/helm-charts | common | 0.1.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| apiPrefix | string | `"/v1"` | api prefix the consent-manager serves its api under |
| appEndpoint | string | `""` | the application's own base url (APP_ENDPOINT / URL). It ends up in the links the application emits, so a published deployment has to set the address it is reachable at. Defaults to the in-cluster service. Templated, so `{{ .Release.Namespace }}` works. |
| autoscaling.apiVersion | string | `"v2"` | version of the autoscaling api to be used |
| autoscaling.enabled | bool | `false` | should autoscaling be enabled for the consent-manager |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | metrics to react on |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| contractService.url | string | `"http://consent-facade:8080"` | base url of the contract service. Templated, so a cross-namespace FQDN can carry `{{ .Release.Namespace }}`. |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.additionalVolumeMounts | list | `[]` | additional volume mounts, if required |
| deployment.additionalVolumes | list | `[]` | additional volumes, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"quay.io/wi_stefan/consent-manager"` | consent-manager image name. A compiled, non-root, read-only-filesystem-safe build of VisionsOfficial/consent-manager. ref: https://quay.io/repository/wi_stefan/consent-manager |
| deployment.image.tag | string | `""` | overrides the image tag whose default is the chart appVersion |
| deployment.livenessProbe.enabled | bool | `false` | enable the liveness probe |
| deployment.livenessProbe.failureThreshold | int | `3` |  |
| deployment.livenessProbe.initialDelaySeconds | int | `30` |  |
| deployment.livenessProbe.path | string | `"/"` | path to probe |
| deployment.livenessProbe.periodSeconds | int | `20` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.timeoutSeconds | int | `5` |  |
| deployment.nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| deployment.podSecurityContext | object | `{"fsGroup":10100,"runAsGroup":10100,"runAsUser":10100,"seccompProfile":{"type":"RuntimeDefault"}}` | security context for the pod. The image runs as uid/gid 10100. |
| deployment.readinessProbe.enabled | bool | `false` | enable the readiness probe |
| deployment.readinessProbe.failureThreshold | int | `3` |  |
| deployment.readinessProbe.initialDelaySeconds | int | `10` |  |
| deployment.readinessProbe.path | string | `"/"` | path to probe |
| deployment.readinessProbe.periodSeconds | int | `10` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.timeoutSeconds | int | `5` |  |
| deployment.replicaCount | int | `1` | initial number of target replications, can be different if autoscaling is enabled |
| deployment.resources.limits.cpu | string | `"500m"` |  |
| deployment.resources.limits.memory | string | `"512Mi"` |  |
| deployment.resources.requests.cpu | string | `"100m"` |  |
| deployment.resources.requests.memory | string | `"128Mi"` |  |
| deployment.revisionHistoryLimit | int | `3` | number of old replicas to be retained |
| deployment.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":10100}` | security context for the container |
| deployment.tolerations | list | `[]` | tolerations template ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| deployment.updateStrategy.rollingUpdate | object | `{"maxSurge":1,"maxUnavailable":0}` | new pods will be added gradually |
| deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` | number of pods that can be created above the desired amount while updating |
| deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` | number of pods that can be unavailable while updating |
| deployment.updateStrategy.type | string | `"RollingUpdate"` | type of the update |
| deployment.writablePaths | object | `{"logs":"/usr/src/app/dist/src/logs","logs-all":"/usr/src/app/dist/src/libs/logs","tmp":"/tmp"}` | paths the application writes to, as `<volume name>: <path>`. The root filesystem is read-only, so each gets an emptyDir: the consent-manager writes rotating winston logs to two compiled paths, and they are part of the image layout rather than configurable - adjust them here if the image changes. |
| env | object | `{}` | a map of additional env vars to be set, check the consent-manager documentation for all available options |
| envConfigMapNames | list | `[]` | additional config maps to load as env in their entirety (list of config map names) |
| envSecretNames | list | `[]` | additional secrets to load as env in their entirety (list of secret names) |
| envValueFrom | object | `{}` | a map of additional env vars to be read from another source (secret, configmap, field), keyed by the env var name |
| externalIdp.algorithms | string | `"RS256,ES256,EdDSA"` | accepted signing algorithms (asymmetric only) |
| externalIdp.audience | string | `""` | the expected `aud`. One value covers data subjects and participants alike: they present different credentials to the same relying party, which on a verifier is one service with a credential policy per scope, and every token it issues carries that service id as `aud`. |
| externalIdp.caSecret.key | string | `"ca.crt"` | key within the secret holding the PEM certificate |
| externalIdp.caSecret.name | string | `""` | secret holding the CA certificate. Empty => rely on the system trust store. |
| externalIdp.discoveryPath | string | `""` | path appended to each issuer to fetch its OIDC discovery document. Empty => the spec default `/.well-known/openid-configuration`. Needed for a verifier that serves discovery under a per-service path while still stamping its bare host as the token `iss` (the FIWARE VCVerifier does), e.g. `/services/consent-manager/.well-known/openid-configuration`. |
| externalIdp.discoveryTtl | int | `3600` | discovery + JWKS cache TTL in seconds |
| externalIdp.enabled | bool | `false` | verify externally issued tokens |
| externalIdp.issuers | list | `[]` | trusted issuer urls. Each must equal the token's `iss` verbatim; discovery runs at `<issuer><discoveryPath>`. |
| externalIdp.proxy | string | `""` | forward proxy for reaching the issuer from inside the cluster (exported as HTTP_PROXY/HTTPS_PROXY, with the cluster suffixes in NO_PROXY). Needed when the issuer's ingress host does not resolve in-cluster. |
| externalIdp.subjectClaim | string | `"sub"` | token claim carrying the subject DID |
| fullnameOverride | string | `""` | option to override the fullname config in the _helpers.tpl |
| ingress.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.className | string | `""` | ingress class to be used |
| ingress.enabled | bool | `false` | should an ingress be created |
| ingress.hosts | list | `[]` | hosts to be used, each with a list of paths |
| ingress.tls | list | `[]` | tls configuration |
| mongo.auth.existingSecret.key | string | `""` | key of the password inside that secret |
| mongo.auth.existingSecret.name | string | `""` | name of the secret. Empty => the secret this chart creates from `password`. |
| mongo.auth.password | string | `""` | password to connect with. Prefer `existingSecret`: a password here ends up in the release's values. |
| mongo.database | string | `"consent"` | database to use |
| mongo.host | string | `"mongodb-svc"` | host of the mongodb service |
| mongo.port | int | `27017` | port of the mongodb service |
| mongo.replicaSet | string | `"mongodb"` | name of the replica set |
| mongo.uri | string | `""` | full connection string, including the replica set. When set it overrides every part below - use it for a connection this chart cannot express (TLS options, SRV records, multiple hosts). |
| mongo.username | string | `"consent"` | user to connect as |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| oauthTokenExpiresIn | string | `"1h"` | lifetime of an issued OAuth token |
| port | int | `3000` | port that the consent-manager container uses |
| route.annotations | object | `{}` | annotations to be added to the route |
| route.enabled | bool | `false` | should a route be created |
| route.host | string | `""` | host to be used |
| route.tls | object | `{}` | tls configuration |
| saltRounds | int | `10` | bcrypt salt rounds used for stored credentials |
| secret.consentKey | string | `""` | the shared consent key (X_VISIONSTRUST_CONSENT_KEY). The gateway in front of the consent-manager injects this exact value and the consent-manager validates it, so both sides have to be configured with the same string - which is why it is not generated. Left empty a random key is generated: that fails closed (no caller can present a matching key) instead of deploying a blank shared secret, so a working deployment has to set it. |
| secret.create | bool | `true` | create the secret. The session/JWT/OAuth secrets are generated on first install and kept across upgrades (`helm.sh/resource-policy: keep`), so sessions and issued tokens survive a redeploy. Set individual values below to pin them instead. |
| secret.existingSecret | string | `""` | name of an already existing secret to use instead. It has to carry the four keys named under `keys` below. |
| secret.jwtSecret | string | `""` | JWT secret. Empty => generated on first install. |
| secret.keys.consentKey | string | `"consentKey"` | key holding the consent key (X_VISIONSTRUST_CONSENT_KEY) |
| secret.keys.jwtSecret | string | `"jwtSecret"` | key holding the JWT secret |
| secret.keys.oauthSecret | string | `"oauthSecret"` | key holding the OAuth secret |
| secret.keys.sessionSecret | string | `"sessionSecret"` | key holding the session secret |
| secret.oauthSecret | string | `""` | OAuth secret. Empty => generated on first install. |
| secret.sessionSecret | string | `""` | session secret. Empty => generated on first install. |
| service.annotations | object | `{}` | additional annotations, if required |
| service.port | int | `3000` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type. Keep it internal: the consent-manager authenticates callers with a shared consent key and participant tokens, and is meant to sit behind a gateway. |
| serviceAccount | object | `{"create":false}` | if a consent-manager specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |
| sessionCookieName | string | `"consentmanagersessid"` | name of the session cookie |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
