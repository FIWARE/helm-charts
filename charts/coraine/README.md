# coraine

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

A Helm chart for running the SEAMWARE Coraine NGSI-LD context broker on kubernetes.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Miguel Ortega Moreno | <miguel.ortega@seamware.com> |  |

## Source Code

* <https://github.com/SEAMWARE/coraine>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://fiware.github.io/helm-charts | common | 0.1.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| apiPlugins.admin.enabled | bool | `true` | load the admin/ops API plugin (--apiPlugins admin). Required for /metrics, /admin/tenants, /admin/plugins, /admin/log, etc. The k8s Service always exposes these cluster-internally when enabled; see `ingress.exposeAdminPaths` to also expose them externally. |
| autoscaling.apiVersion | string | `"v2"` | apiVersion of the HorizontalPodAutoscaler resource |
| autoscaling.enabled | bool | `false` | should autoscaling be enabled for coraine |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | list of MetricSpecs to decide whether to scale |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| config.asyncSnapshot | bool | `false` | run snapshot queries in a background thread (--asyncSnapshot) |
| config.connectionPoolSize | int | `32` | libmicrohttpd connection pool size (--connectionPoolSize) |
| config.cooldownMillis | int | `30000` | default endpoint cooldown in ms after a failed notify/forward (--cooldownMillis) |
| config.cors.enabled | bool | `false` | enable CORS by setting an allowed origin (--corsOrigin). Use "__ALL" to allow any origin. |
| config.cors.maxAge | int | `86400` | seconds a CORS preflight response may be cached (--corsMaxAge) |
| config.cors.origin | string | `"__ALL"` | allowed origin, or "__ALL" for any origin |
| config.defaultUserContext | string | `""` | default @context URL to use when a request supplies none (--defaultUserContext) |
| config.distOpTimeout | int | `5000` | HTTP client timeout in ms for distributed ops / notifications / context downloads (--distOpTimeout) |
| config.highPrecision | bool | `false` | use nanosecond (9-digit) timestamps instead of microsecond (6-digit) ones (--high-precision) |
| config.insecureNotif | bool | `false` | accept self-signed TLS certs on outbound notifications/forwards (--insecureNotif) |
| config.maxRequestSize | int | `2` | maximum accepted request body size in MiB, 0 = uncapped (--maxRequestSize) |
| config.notifyValueChangeOnly | bool | `false` | suppress notifications whose payload did not actually change (--notifyValueChangeOnly) |
| config.port | int | `1026` | port coraine listens on (also used as the container port and default probe port) |
| config.prettyPrint | bool | `false` | indent JSON responses (--pretty-print) |
| config.subStatsFlushInterval | int | `60` | seconds between periodic subscription-stats flushes, 0 = disabled (--subStatsFlushInterval) |
| config.traceLevels | string | `""` | trace level string, e.g. "1-10" (--traceLevels) |
| database.mongoc.auth.enabled | bool | `false` |  |
| database.mongoc.auth.existingSecret | object | `{}` | reference an existing secret instead of `password` above. existingSecret:   name: coraine-db-credentials   key: dbPassword |
| database.mongoc.auth.password | string | `""` | mongo password (--dbPwd), ignored when existingSecret is set. Passed to coraine via an env var + `$(...)` substitution so it is not baked in plaintext into the pod's args spec -- note this is still visible in `ps`/`/proc` inside the container, coraine has no other way to receive it. |
| database.mongoc.auth.user | string | `""` | mongo username (--dbUser) |
| database.mongoc.globalDb | string | `"coraine"` | reserved mongo database for global/non-tenant state, e.g. cached JSON-LD contexts (--globalDb) |
| database.mongoc.host | string | `"mongodb"` | mongo host (--dbHost) |
| database.mongoc.name | string | `"cor"` | mongo database name (--dbName) |
| database.mongoc.port | int | `27017` | mongo port (--dbPort) |
| database.mongoc.timeout | int | `30` | mongo connection timeout in seconds (--dbTimeout) |
| database.mongoc.uri.enabled | bool | `false` | use a full mongo connection URI instead of host/port/user/pwd (--dbURI). Overrides all other mongoc.* settings above when enabled. |
| database.mongoc.uri.existingSecret | object | `{}` | reference an existing secret instead of `value` above. existingSecret:   name: coraine-db-credentials   key: dbURI |
| database.mongoc.uri.value | string | `""` | the connection URI, ignored when existingSecret is set |
| database.type | string | `"mongo"` | database plugin to load: "mongo" (alias for "mongoc") or "memory" (alias for "corRamDB"). The upstream plugin names "mongoc"/"corRamDB" also work directly; any other value is rejected -- see the note on dynamic plugin loading above. |
| distributed.contextSourceExtras | object | `{"content":{},"enabled":false}` | render a custom JSON document at /ngsi-ld/v1/info/sourceIdentity (--contextSourceExtras) |
| distributed.contextSourceExtras.content | object | `{}` | arbitrary JSON content rendered verbatim at /ngsi-ld/v1/info/sourceIdentity |
| distributed.csourceAlias | string | `""` | identity used for federation loop detection, derived from httpEndpoint when empty (--csourceAlias) |
| distributed.enabled | bool | `false` | enable forwarding requests to registered Context Sources (--distributed) |
| distributed.httpEndpoint | string | `""` | this broker's externally-reachable base URL, embedded in Link headers/callbacks (--httpEndpoint). Leave empty to fall back to coraine's own auto-detection (which picks a pod-internal address and is almost never what you want in kubernetes) -- set it explicitly, e.g. "http://<release>-coraine.<namespace>.svc.cluster.local:1026" or your public ingress URL. |
| distributed.noSplitEntities | bool | `false` | disable splitting a single entity's attributes across multiple sources (--noSplitEntities) |
| extraArgs | list | `[]` | extra command-line flags appended verbatim after the ones generated from `config`/ `database`/`troe`/etc above, for coraine options this chart does not (yet) model directly |
| extraEnvVars | list | `[]` | additional environment variables to set on the coraine container ref: https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/ |
| extraEnvVarsSecret | string | `""` | name of an existing Secret to load as additional environment variables (envFrom) |
| extraManifests | list | `[]` | additional Kubernetes manifests to render alongside this chart's own resources. Each entry is rendered with `tpl`, so it may reference `.Release`, `.Values`, etc. |
| extraVolumeMounts | list | `[]` | additional volumeMounts on the coraine container |
| extraVolumes | list | `[]` | additional volumes on the coraine pod |
| fullnameOverride | string | `""` | option to override the fullname config in the _helpers.tpl |
| ha.enabled | bool | `false` | enable multi-replica cache sync via MongoDB change streams (--ha mongo) |
| image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| image.repository | string | `"quay.io/seamware/coraine"` | coraine image name ref: https://quay.io/repository/seamware/coraine |
| image.tag | string | `""` | tag of the image to be used, defaults to the chart's appVersion ("latest") when empty. Coraine ships no semver releases upstream (only `latest` or a git-sha tag) -- pin a git-sha tag here for reproducible deployments. |
| imagePullSecrets | list | `[]` | secrets to use for pulling the (private) coraine image ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| ingress.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.className | string | `""` | ingress class to use |
| ingress.enabled | bool | `false` | should there be an ingress to connect coraine with the public internet |
| ingress.exposeAdminPaths | bool | `false` | ADVANCED / SECURITY-SENSITIVE: also route `/admin` and `/metrics` through this ingress, for every host in `hosts` above. These paths let a caller read tenant names, broker version/plugin info and mutate log verbosity at runtime (see coraine's admin plugin docs) -- keep this false unless the ingress itself is otherwise access-controlled (auth annotations, allow-list, mTLS, ...). |
| ingress.hosts | list | `[]` | all hosts to be provided |
| ingress.tls | list | `[]` | configure the ingress' tls |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.httpGet.path | string | `"/ngsi-ld/v1/types"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| livenessProbe.initialDelaySeconds | int | `10` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| metrics.enabled | bool | `false` | add prometheus.io/scrape annotations to the pod (served at /metrics by the admin plugin) |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` | additional annotations for the pod |
| podLabels | object | `{}` | additional labels for the pod |
| podSecurityContext | object | `{}` | pod-level security context |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.httpGet.path | string | `"/ngsi-ld/v1/types"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| readinessProbe.initialDelaySeconds | int | `5` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| readinessProbe.successThreshold | int | `1` |  |
| readinessProbe.timeoutSeconds | int | `5` |  |
| replicaCount | int | `1` | number of coraine replicas. Only combine with `ha.enabled` when running against a shared MongoDB replica set -- otherwise each replica has its own inconsistent state. |
| resources | object | `{}` | resource requests/limits for the coraine container. Left empty so that setting them (e.g. for autoscaling) is a conscious choice by the user. |
| route.annotations | object | `{}` | annotations to be added to the route |
| route.enabled | bool | `false` | should the deployment create an openshift route |
| route.tls | object | `{}` | tls configuration for the route |
| securityContext | object | `{}` | container-level security context |
| service.annotations | object | `{}` | additional annotations, if required |
| service.port | int | `1026` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | if a coraine specific service account should be used, it can be configured here |
| serviceAccount.annotations | object | `{}` | additional annotations for the service account |
| serviceAccount.create | bool | `false` | specifies if the account should be created |
| serviceAccount.name | string | `""` | name of the service account to use, defaults to the fullname template when create is true |
| tolerations | list | `[]` |  |
| troe.timescale.existingSecret | object | `{}` | reference an existing secret instead of `password` above. existingSecret:   name: coraine-troe-credentials   key: troePassword |
| troe.timescale.host | string | `"timescaledb"` | timescale/postgres host (--troeHost) |
| troe.timescale.instanceCap | int | `1000000` | max number of temporal instances kept in memory before eviction (--troeInstanceCap) |
| troe.timescale.name | string | `"corh"` | timescale/postgres database name (--troeName) |
| troe.timescale.password | string | `""` | timescale/postgres password (--troePwd), ignored when existingSecret is set. Same `$(...)` env-var substitution caveat as database.mongoc.auth.password applies. |
| troe.timescale.poolSize | int | `10` | connection pool size (--troePoolSize) |
| troe.timescale.port | int | `5432` | timescale/postgres port (--troePort) |
| troe.timescale.user | string | `"postgres"` | timescale/postgres user (--troeUser) |
| troe.type | string | `"none"` | temporal history plugin to load: "none", "ramdb" or "timescale" |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
