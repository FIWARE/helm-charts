# dsc-consent-manager

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

A Helm chart for running the dsc-consent-manager, consent lifecycle management as a stateless OAuth2 resource server, on kubernetes.

**Homepage:** <https://github.com/wistefan/dsc-consent-manager>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| wistefan | <stefan.wiedemann@seamware.com> |  |

## Source Code

* <https://github.com/wistefan/dsc-consent-manager>

## Requirements

Kubernetes: `>= 1.19-0`

| Repository | Name | Version |
|------------|------|---------|
| https://fiware.github.io/helm-charts | common | 0.1.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaling.apiVersion | string | `"v2"` | version of the autoscaling api to be used |
| autoscaling.enabled | bool | `false` | should autoscaling be enabled for the dsc-consent-manager |
| autoscaling.maxReplicas | int | `5` | maximum number of running pods |
| autoscaling.metrics | list | `[{"resource":{"name":"cpu","target":{"averageUtilization":75,"type":"Utilization"}},"type":"Resource"}]` | metrics to react on ref: https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/horizontal-pod-autoscaler-v2/#HorizontalPodAutoscalerSpec |
| autoscaling.minReplicas | int | `2` | minimum number of running pods, must not exceed maxReplicas |
| config.apiPrefix | string | `"/v1"` | prefix the API controllers are served under |
| config.cache.contractServiceMaxSize | int | `1000` | maximum number of cached contract-service responses |
| config.cache.contractServiceTtl | string | `"60s"` | TTL of cached contract-service responses |
| config.cache.idpJwksTtl | string | `"60s"` | TTL of the cached IdP JWKS |
| config.cache.selfDescriptionMaxSize | int | `1000` | maximum number of cached self descriptions |
| config.cache.selfDescriptionTtl | string | `"10m"` | TTL of cached self descriptions |
| config.consentManagerUrl | string | `""` | public base URL of this service |
| config.contractServiceUrl | string | `""` | base URL of the contract service |
| config.database.url | string | `"jdbc:postgresql://postgres:5432/consent_manager"` | JDBC URL of the database. Placeholder: must be overridden for production. |
| config.extraEnv | object | `{}` | any other non-sensitive variable from .env.sample, e.g. SELF_DESCRIPTION_ALLOWED_HOSTS. Credentials and the variables the deployment sets are refused. |
| config.notificationClientUrl | string | `""` | URL of the notification client |
| config.pagination.consentsDefaultSize | int | `20` | default page size of the consents list |
| config.pagination.consentsMaxSize | int | `100` | maximum page size of the consents list |
| config.pagination.notificationsDefaultSize | int | `20` | default page size of the notifications list |
| config.pagination.notificationsMaxSize | int | `100` | maximum page size of the notifications list |
| config.pagination.participantsDefaultSize | int | `20` | default page size of the participants list |
| config.pagination.participantsMaxSize | int | `100` | maximum page size of the participants list |
| config.participantNotifications.allowedHosts | list | `[]` | operator-only: listed hosts are the only webhook targets and skip the private-address check |
| config.participantNotifications.backoff | list | `["1m","5m","15m","1h","6h","24h"]` | retry schedule |
| config.participantNotifications.batchSize | int | `50` | notifications fetched per poll |
| config.participantNotifications.concurrency | int | `16` | concurrent webhook deliveries |
| config.participantNotifications.connectTimeout | string | `"2s"` | connect timeout of a webhook call |
| config.participantNotifications.enabled | bool | `true` | whether these replicas deliver; the age and retention sweeps run either way |
| config.participantNotifications.jitter | float | `0.1` | jitter applied to the retry schedule, as a fraction |
| config.participantNotifications.lease | string | `"60s"` | delivery lease; startup refuses a lease too short for a whole batch to send |
| config.participantNotifications.maxAge | string | `"36h"` | undelivered rows older than this are abandoned and redacted; must cover the retry schedule |
| config.participantNotifications.perParticipantBatchLimit | int | `5` | notifications per participant and batch; must stay below concurrency |
| config.participantNotifications.pollInterval | string | `"5s"` | interval of the delivery poll |
| config.participantNotifications.readTimeout | string | `"5s"` | read timeout of a webhook call |
| config.participantNotifications.resolveTimeout | string | `"2s"` | timeout of a webhook host lookup |
| config.participantNotifications.resolverThreads | int | `8` | concurrent webhook host lookups; a stalled host holds at most one |
| config.participantNotifications.retention | string | `"30d"` | how long delivered notifications are kept |
| config.participantNotifications.sweepInterval | string | `"1m"` | interval of the age and retention sweeps |
| config.receiptsJurisdiction | string | `"EU"` | jurisdiction stated in consent receipts |
| config.smtp.fromAddress | string | `""` | sender address of notifications |
| config.smtp.fromName | string | `""` | sender name of notifications |
| config.smtp.host | string | `""` | SMTP host. Leave empty to disable notifications. With a host set, fromAddress is required by the app. |
| config.smtp.port | int | `587` | SMTP port |
| config.smtp.startTls | bool | `true` | whether to use STARTTLS |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the pods, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the pods, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.containerPorts.http | int | `8080` | port of the API |
| deployment.containerPorts.management | int | `9090` | port of health, metrics and Prometheus |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"quay.io/seamware/dsc-consent-manager"` | dsc-consent-manager image name ref: https://quay.io/repository/seamware/dsc-consent-manager |
| deployment.image.tag | string | `""` | overrides the image tag whose default is the chart appVersion |
| deployment.nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| deployment.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | security context for the pod. fsGroup also makes the 0400 signing-key files readable by the app's group; see deployment.yaml. |
| deployment.priorityClassName | string | `""` | priority class to be assigned to the pods ref: https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/ |
| deployment.probes.liveness.failureThreshold | int | `3` |  |
| deployment.probes.liveness.initialDelaySeconds | int | `30` |  |
| deployment.probes.liveness.path | string | `"/health/liveness"` | path to probe |
| deployment.probes.liveness.periodSeconds | int | `30` |  |
| deployment.probes.liveness.timeoutSeconds | int | `5` |  |
| deployment.probes.readiness.failureThreshold | int | `3` |  |
| deployment.probes.readiness.initialDelaySeconds | int | `10` |  |
| deployment.probes.readiness.path | string | `"/health/readiness"` | path to probe |
| deployment.probes.readiness.periodSeconds | int | `10` |  |
| deployment.probes.readiness.timeoutSeconds | int | `5` |  |
| deployment.probes.startup.failureThreshold | int | `30` |  |
| deployment.probes.startup.path | string | `"/health/liveness"` | path to probe |
| deployment.probes.startup.periodSeconds | int | `5` |  |
| deployment.probes.startup.timeoutSeconds | int | `5` |  |
| deployment.replicaCount | int | `2` | initial number of target replications, ignored when autoscaling is enabled: the HPA owns the replica count then |
| deployment.resources | object | `{"limits":{"cpu":"1","memory":"1Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | cpu/memory resources. The JVM sizes its heap at 75% of the container memory limit (-XX:MaxRAMPercentage in the image), so raising limits.memory raises the heap. |
| deployment.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` | security context for the container |
| deployment.tmp.sizeLimit | string | `"256Mi"` | size limit of the /tmp emptyDir |
| deployment.tolerations | list | `[]` | tolerations template ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| deployment.topologySpreadConstraints | list | `[]` | topology spread constraints template ref: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/ |
| deployment.updateStrategy.rollingUpdate | object | `{"maxSurge":1,"maxUnavailable":0}` | new pods will be added gradually |
| deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` | number of pods that can be created above the desired amount while updating |
| deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` | number of pods that can be unavailable while updating |
| deployment.updateStrategy.type | string | `"RollingUpdate"` | type of the update |
| fullnameOverride | string | `""` | option to override the fullname config in the _helpers.tpl |
| identityProviders.additional | object | `{}` | further providers, keyed by name, with entries shaped like `primary` |
| identityProviders.primary.allowInsecureTransport | bool | `false` | permits an http issuer or discovery URL; local development only |
| identityProviders.primary.audience | string | `"consent-manager"` | expected token audience. Placeholder: must be overridden for production. |
| identityProviders.primary.claims.participantIdentifier | list | `["participant_id"]` | claim path of the participant identifier |
| identityProviders.primary.claims.roles | list | `["realm_access","roles"]` | claim path of the roles |
| identityProviders.primary.claims.userIdentifier | list | `["sub"]` | claim path of the user identifier |
| identityProviders.primary.clockSkew | string | `"30s"` | tolerated clock skew when validating tokens |
| identityProviders.primary.discoveryUrl | string | `"https://idp.example.org/realms/consent-manager/.well-known/openid-configuration"` | OIDC discovery URL of the primary IdP. Placeholder: must be overridden for production. |
| identityProviders.primary.issuer | string | `"https://idp.example.org/realms/consent-manager"` | issuer of the primary IdP. Placeholder: must be overridden for production. |
| identityProviders.primary.roleMapping.catalog | string | `"consent-catalog"` | IdP role mapped to the catalog role |
| identityProviders.primary.roleMapping.participant | string | `"consent-participant"` | IdP role mapped to the participant role |
| identityProviders.primary.roleMapping.user | string | `"consent-user"` | IdP role mapped to the user role |
| imagePullSecrets | list | `[]` | secrets to pull the image with, as names or `{name: <secret>}` maps |
| ingress.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.className | string | `""` | ingress class to be used |
| ingress.enabled | bool | `false` | should an ingress be created |
| ingress.hosts | list | `[{"host":"consent-manager.local","paths":["/"]}]` | hosts to be used, each with a list of paths |
| ingress.tls | list | `[]` | tls configuration |
| managementService.port | int | `9090` | port to be used by the management service |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| route.annotations | object | `{}` | annotations to be added to the route |
| route.enabled | bool | `false` | should a route be created |
| route.host | string | `""` | host to be used |
| route.tls | object | `{}` | tls configuration |
| secrets.dbPassword | string | `""` | database password. Must be set for production, unless existingSecret is used. |
| secrets.dbUser | string | `"consent_manager"` | database user |
| secrets.erasureVerificationSecret | string | `""` | secret of erasure verifications. Rotating it breaks outstanding erasure verifications; generate it once with `openssl rand -base64 32` and keep it. Empty => reused from the live Secret, else generated. WARNING: helm template, --dry-run, Argo CD and Flux cannot read the live Secret, so there an empty value rotates on every render; GitOps users must set it or use existingSecret. |
| secrets.existingSecret | string | `""` | name of an already existing secret to use instead. Prefer it in production. |
| secrets.logPseudonymKey | string | `""` | key pseudonymising user identifiers in logs. Rotating it breaks pseudonym linkage; generate it once with `openssl rand -base64 32` and keep it. Empty => reused from the live Secret, else generated. WARNING: helm template, --dry-run, Argo CD and Flux cannot read the live Secret, so there an empty value rotates on every render; GitOps users must set it or use existingSecret. |
| secrets.smtpPassword | string | `""` | SMTP password |
| secrets.smtpUser | string | `""` | SMTP user |
| service.port | int | `8080` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | if a dsc-consent-manager specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.annotations | object | `{}` | annotations to add to the service account |
| serviceAccount.create | bool | `false` | specifies if the account should be created |
| serviceAccount.name | string | `""` | name of the service account to use. Empty => the fullname when created, else `default` |
| serviceMonitor.enabled | bool | `false` | should a ServiceMonitor be created |
| serviceMonitor.interval | string | `"30s"` | scrape interval |
| serviceMonitor.labels | object | `{}` | extra labels, e.g. the release label your Prometheus selects ServiceMonitors by |
| serviceMonitor.scrapeTimeout | string | `""` | scrape timeout. Empty means Prometheus's default; must not exceed interval. |
| signingKeys.retiredVerificationKeys.enabled | bool | `false` | mount retired verification keys, so receipts signed with a rotated key still verify |
| signingKeys.retiredVerificationKeysFile | string | `"retired-verification-keys.jwks"` | key of the retired verification keys within that Secret |
| signingKeys.secretName | string | `""` | name of the signing-key Secret. Empty => "<release>-signing-keys". |
| signingKeys.signingKeyFile | string | `"signing-key.jwk"` | key of the signing key within that Secret |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
