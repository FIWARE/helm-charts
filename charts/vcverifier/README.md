# vcverifier

![Version: 4.15.0](https://img.shields.io/badge/Version-4.15.0-informational?style=flat-square) ![AppVersion: 6.22.0](https://img.shields.io/badge/AppVersion-6.22.0-informational?style=flat-square)

A Helm chart for running the FIWARE VCVerifier.

**Homepage:** <https://github.com/fiware/vcverifier>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| wistefan | <stefan.wiedemann@seamware.com> |  |

## Source Code

* <https://github.com/fiware/vcverifier>

## Requirements

Kubernetes: `>= 1.19-0`

| Repository | Name | Version |
|------------|------|---------|
| https://fiware.github.io/helm-charts | common | 0.1.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| configIngress.annotations | object | `{}` | annotations to be added to the ingress |
| configIngress.enabled | bool | `false` | should there be an ingress to connect the config verifier with the public internet |
| configIngress.hosts | list | `[]` | all hosts to be provided |
| configIngress.tls | list | `[]` | configure the ingress' tls |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.configRepo | object | `{"configEndpoint":"http://credentials-config:8080/"}` | config repo configuration |
| deployment.configServer | object | `{"enabled":false,"idleTimeout":120,"port":8090,"readTimeout":5,"shutdownTimeout":5,"writeTimeout":10}` | ConfigServer holds the configuration for the second HTTP server that serves the Credentials Config Service (CCS) REST API. |
| deployment.configServer.enabled | bool | `false` | Whether the config server is enabled |
| deployment.configServer.idleTimeout | int | `120` | IdleTimeout is the maximum amount of time to wait for the next request (seconds) |
| deployment.configServer.port | int | `8090` | Port to bind the config server |
| deployment.configServer.readTimeout | int | `5` | ReadTimeout is the maximum duration for reading the entire request (seconds) |
| deployment.configServer.shutdownTimeout | int | `5` | ShutdownTimeout is the time allowed for active requests to finish during shutdown (seconds) |
| deployment.configServer.writeTimeout | int | `10` | WriteTimeout is the maximum duration before timing out writes of the response (seconds) |
| deployment.database.existingSecret.name | string | `""` |  |
| deployment.database.existingSecret.passwordKey | string | `""` |  |
| deployment.database.existingSecret.usernameKey | string | `""` |  |
| deployment.database.host | string | `""` |  |
| deployment.database.name | string | `""` |  |
| deployment.database.port | int | `5432` |  |
| deployment.database.sslMode | string | `"disable"` |  |
| deployment.database.type | string | `"postgres"` |  |
| deployment.database.user | string | `""` |  |
| deployment.eidas | object | `{"allowStaleTrustLists":false,"countries":null,"enabled":false,"fetchTimeout":30,"lotUrl":null,"maxWorkers":5,"refreshInterval":86400,"revocationCacheExpiry":3600,"revocationCheck":"soft","revocationTimeout":10,"statusEvaluation":"current"}` | eidas2.0 related configuration |
| deployment.eidas.allowStaleTrustLists | bool | `false` | Accept lists past their `NextUpdate`. |
| deployment.eidas.countries | string | `nil` | ISO 3166-1 alpha-2 country filter for the national lists to be included. If empty, all countries are included. |
| deployment.eidas.enabled | bool | `false` | should eidas 2.0 compliant verification be enabled |
| deployment.eidas.fetchTimeout | int | `30` | HTTP timeout per trust list fetch, in seconds. |
| deployment.eidas.lotUrl | string | `nil` | URL of the List of Trusted Lists. Defaults to the official EU LOTL |
| deployment.eidas.maxWorkers | int | `5` | Concurrent national list fetches |
| deployment.eidas.refreshInterval | int | `86400` | Seconds between background refreshes of the lotl |
| deployment.eidas.revocationCacheExpiry | int | `3600` | Cache lifetime of a determined status, in seconds. |
| deployment.eidas.revocationCheck | string | `"soft"` | selects how certificate revocation (OCSP/CRL) is handled during chain validation. Can be "soft", "hard" or "off" |
| deployment.eidas.revocationTimeout | int | `10` | HTTP timeout per OCSP/CRL request, in seconds.  |
| deployment.eidas.statusEvaluation | string | `"current"` | StatusEvaluation selects the point in time at which a trust service's status is evaluated. Either current or issuance. |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"quay.io/fiware/vcverifier"` | image name |
| deployment.image.tag | string | `""` | tag of the image to be used |
| deployment.livenessProbe.failureThreshold | int | `3` |  |
| deployment.livenessProbe.initialDelaySeconds | int | `3` |  |
| deployment.livenessProbe.periodSeconds | int | `10` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| deployment.logging | object | `{"jsonLogging":true,"level":"WARN","logRequests":true,"pathsToSkip":["/metrics","/health"]}` | logging configuration |
| deployment.logging.jsonLogging | bool | `true` | should the log be in structured json |
| deployment.logging.level | string | `"WARN"` | the log level, can be DEBUG, INFO, WARN, ERROR |
| deployment.logging.logRequests | bool | `true` | should requests be logged |
| deployment.logging.pathsToSkip | list | `["/metrics","/health"]` | list of paths to be excluded from the request logging |
| deployment.m2m | object | `{"authEnabled":false,"clientId":null,"credentialPath":null,"keyPath":null,"keyType":"RSAPS256","signatureType":null,"verificationMethod":null}` | m2m related config |
| deployment.m2m.authEnabled | bool | `false` | should authentication be enabled for m2m interaction |
| deployment.m2m.clientId | string | `nil` | id of the verifier when retrieving tokens |
| deployment.m2m.credentialPath | string | `nil` | path to the credential to be used for authentication |
| deployment.m2m.keyPath | string | `nil` | path to the private key to be used(in pem format) |
| deployment.m2m.keyType | string | `"RSAPS256"` | type of the provided key |
| deployment.m2m.signatureType | string | `nil` | signature type to be used for the proof |
| deployment.m2m.verificationMethod | string | `nil` | verification method to be provided for the proof |
| deployment.nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| deployment.port | int | `3000` | port to run the container at |
| deployment.readinessProbe.failureThreshold | int | `3` |  |
| deployment.readinessProbe.initialDelaySeconds | int | `4` |  |
| deployment.readinessProbe.periodSeconds | int | `10` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.timeoutSeconds | int | `30` |  |
| deployment.replicaCount | int | `1` | initial number of target replications, can be different if autoscaling is enabled |
| deployment.revisionHistoryLimit | int | `3` | number of old replicas to be retained |
| deployment.server | object | `{"host":"my-verifier.org","port":3000,"staticDir":"views/static","templateDir":"views/"}` | configuration for server |
| deployment.server.host | string | `"my-verifier.org"` | host of the verifier |
| deployment.server.port | int | `3000` | port to bind the server to |
| deployment.server.staticDir | string | `"views/static"` | directory to be used for static content, f.e. images referenced from the templates |
| deployment.server.templateDir | string | `"views/"` | directory to be used for retrieving the templates. |
| deployment.serverCertificates | object | `{"caCert":{"bundleImage":{"bundlePath":"/etc/ssl/cert.pem","repository":"alpine","tag":"3.23.3"},"enabled":false,"key":null,"secretName":null},"clientKey":{"privateKey":null,"publicKey":null,"secretName":null},"signingKey":{"key":null,"secretName":null}}` | Configuration for certificates used by the verifier |
| deployment.serverCertificates.caCert | object | `{"bundleImage":{"bundlePath":"/etc/ssl/cert.pem","repository":"alpine","tag":"3.23.3"},"enabled":false,"key":null,"secretName":null}` | Certificate Authority bundle to add/trust for the application. |
| deployment.serverCertificates.caCert.bundleImage | object | `{"bundlePath":"/etc/ssl/cert.pem","repository":"alpine","tag":"3.23.3"}` | Container image used to extract base CA bundle. |
| deployment.serverCertificates.caCert.bundleImage.repository | string | `"alpine"` | Image repository |
| deployment.serverCertificates.caCert.bundleImage.tag | string | `"3.23.3"` | Image tag to use for the bundle reader image. |
| deployment.serverCertificates.caCert.key | string | `nil` | Key name inside the Secret containing the CA PEM |
| deployment.serverCertificates.caCert.secretName | string | `nil` | Kubernetes Secret that contains the CA bundle. |
| deployment.serverCertificates.clientKey | object | `{"privateKey":null,"publicKey":null,"secretName":null}` | Private key used by the verifier |
| deployment.serverCertificates.clientKey.privateKey | string | `nil` | key name inside the Secret containing the private key PEM |
| deployment.serverCertificates.clientKey.publicKey | string | `nil` | key name inside the Secret containing the public key PEM |
| deployment.serverCertificates.clientKey.secretName | string | `nil` | Name of the Kubernetes Secret that contains the client key. |
| deployment.serverCertificates.signingKey | object | `{"key":null,"secretName":null}` | Private key used by the verifier to sign credentials. |
| deployment.serverCertificates.signingKey.key | string | `nil` | Key name inside the Secret containing the PEM |
| deployment.serverCertificates.signingKey.secretName | string | `nil` | Name of the Kubernetes Secret that contains the signing key. |
| deployment.tolerations | list | `[]` | tolerations template ref: ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| deployment.updateStrategy.rollingUpdate | object | `{"maxSurge":1,"maxUnavailable":0}` | new pods will be added gradually |
| deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` | number of pods that can be created above the desired amount while updating |
| deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` | number of pods that can be unavailable while updating |
| deployment.updateStrategy.type | string | `"RollingUpdate"` | type of the update |
| deployment.verifier | object | `{"authorizationEndpoint":null,"clientIdentification":{"certificatePath":null,"id":null,"keyAlgorithm":null,"keyPath":null,"kid":null},"did":"did:key:myverifier","generateKey":true,"jwtExpiration":30,"keyAlgorithm":"RS256","keyPath":null,"policyConfig":{},"refreshToken":{"cleanupInterval":"60","enabled":false,"expiration":2880},"sessionExpiry":30,"supportedModes":["urlEncoded"],"tilCacheExpiry":30,"tirAddress":"http://my-tir.org","tirCacheExpiry":30,"validationMode":"none"}` | configuration required for the verifier functionality |
| deployment.verifier.authorizationEndpoint | string | `nil` | path of the authorizationEndpoint to be provided in the .well-known/openid-configuration |
| deployment.verifier.clientIdentification | object | `{"certificatePath":null,"id":null,"keyAlgorithm":null,"keyPath":null,"kid":null}` | Identification to be used for the verifier. |
| deployment.verifier.clientIdentification.certificatePath | string | `nil` | optional path to the certifcate to embed in the jwt header |
| deployment.verifier.clientIdentification.id | string | `nil` | identification used by the verifier when requesting authorization. Can be a did, but also methods like x509_san_dns |
| deployment.verifier.clientIdentification.keyAlgorithm | string | `nil` | algorithm used for the request signing key |
| deployment.verifier.clientIdentification.keyPath | string | `nil` | path to the did signing key(in pem format) for request object mode |
| deployment.verifier.clientIdentification.kid | string | `nil` | Kid used when key certificate does not include it. If both are missing, id is used |
| deployment.verifier.did | string | `"did:key:myverifier"` | did to be used for the verifier |
| deployment.verifier.generateKey | bool | `true` | when set to true, the private key is generated on startup. Its not persisted and just kept in memory. |
| deployment.verifier.jwtExpiration | int | `30` | expiration time in minutes for JWT tokens |
| deployment.verifier.keyAlgorithm | string | `"RS256"` | algorithm to be used for the jwt signatures - currently supported: RS256 and ES256 |
| deployment.verifier.keyPath | string | `nil` | path to the private key for jwt signatures |
| deployment.verifier.policyConfig | object | `{}` | policies that shall be checked |
| deployment.verifier.refreshToken.cleanupInterval | string | `"60"` | purged from the database. 0 or negative disables cleanup. |
| deployment.verifier.refreshToken.enabled | bool | `false` | and the refresh_token grant type is rejected. |
| deployment.verifier.refreshToken.expiration | int | `2880` | Defaults to 2880 (48 hours). Only meaningful when Enabled is true. |
| deployment.verifier.sessionExpiry | int | `30` | expiry of a login-session in seconds |
| deployment.verifier.supportedModes | list | `["urlEncoded"]` | supported request modes - currently 'urlEncoded', 'byValue' and 'byReference' are available. In case of byValue, the keyPath has to be set. |
| deployment.verifier.tilCacheExpiry | int | `30` | expiry of the til-cache entries |
| deployment.verifier.tirAddress | string | `"http://my-tir.org"` | address of the trusted issuers registry to be used for verification |
| deployment.verifier.tirCacheExpiry | int | `30` | expiry of the tir-cache entries |
| deployment.verifier.validationMode | string | `"none"` | validation mode for validation the vcs (dont get confused, its just about validation, verfication happens anyways) applicable modes: * `none`: No validation, just swallow everything * `combined`: ld and schema validation * `jsonLd`: uses JSON-LD parser for validation * `baseContext`: validates that only the fields and values (when applicable)are present in the document. No extra fields are allowed (outside of credentialSubject). Default is set to `none` to ensure backwards compatibility |
| fullnameOverride | string | `""` |  |
| ingress.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.enabled | bool | `false` | should there be an ingress to connect the verifier with the public internet |
| ingress.hosts | list | `[]` | all hosts to be provided |
| ingress.tls | list | `[]` | configure the ingress' tls |
| nameOverride | string | `""` |  |
| registration | object | `{"enabled":false,"host":"","job":{"activeDeadlineSeconds":300,"additionalLabels":{},"annotations":{"helm.sh/hook":"post-install,post-upgrade","helm.sh/hook-delete-policy":"before-hook-creation,hook-succeeded"},"backoffLimit":10,"extraEnv":[],"extraInitContainers":[],"image":{"pullPolicy":"IfNotPresent","registry":"quay.io/curl/curl","tag":"8.1.2"},"imagePullSecrets":[],"initContainers":{"waitForHost":{"enabled":"enable","image":{"pullPolicy":"IfNotPresent","repository":"quay.io/curl/curl","tag":"8.1.2"},"interval":5,"path":"/health"}},"resources":{},"serviceAccountName":"","ttlSecondsAfterFinished":120},"prepScript":"","services":[]}` | Configuration for the post-install registration job. Requires one of: deployment.configServer.enabled=true, deployment.configRepo.configEndpoint, or registration.host to be set. |
| registration.enabled | bool | `false` | Enable the registration job |
| registration.host | string | `""` | Override the host used for registration HTTP requests. If empty, falls back to deployment.configServer (when enabled) or deployment.configRepo.configEndpoint. |
| registration.job.activeDeadlineSeconds | int | `300` | Maximum duration in seconds for the job to run before it is terminated |
| registration.job.additionalLabels | object | `{}` | Additional labels to add to the registration Job resource |
| registration.job.annotations | object | `{"helm.sh/hook":"post-install,post-upgrade","helm.sh/hook-delete-policy":"before-hook-creation,hook-succeeded"}` | Annotations for the registration Job resource. Defaults run it on install AND upgrade, deleting any previous Job first. `post-install` alone made the registration effectively install-only: every `helm upgrade` skipped the Job, so a service added to `registration.services` afterwards never reached the config repo and the verifier answered requests for it with no presentation_definition. `before-hook-creation` is the other half - `hook-succeeded` only deletes the Job when it SUCCEEDS, so one failed run would leave it behind and the next upgrade would fail with `jobs.batch "<release>-job" already exists`. |
| registration.job.backoffLimit | int | `10` | Number of retries before marking the job as failed |
| registration.job.extraEnv | list | `[]` | Extra environment variables to add to the registration job container |
| registration.job.extraInitContainers | list | `[]` | extra init containers appended verbatim to the pod spec (after waitForHost) |
| registration.job.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the registration job |
| registration.job.image.registry | string | `"quay.io/curl/curl"` | Image registry and repository for the registration job (curl-based) |
| registration.job.image.tag | string | `"8.1.2"` | Image tag for the registration job |
| registration.job.imagePullSecrets | list | `[]` | Image pull secrets for the registration job pod |
| registration.job.initContainers | object | `{"waitForHost":{"enabled":"enable","image":{"pullPolicy":"IfNotPresent","repository":"quay.io/curl/curl","tag":"8.1.2"},"interval":5,"path":"/health"}}` | init container that polls the registration HOST (derived the same way as the job script) until it returns HTTP 2xx |
| registration.job.initContainers.waitForHost.enabled | string | `"enable"` | enable the wait-for-host init container |
| registration.job.initContainers.waitForHost.image | object | `{"pullPolicy":"IfNotPresent","repository":"quay.io/curl/curl","tag":"8.1.2"}` | image used for the curl-based wait container |
| registration.job.initContainers.waitForHost.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| registration.job.initContainers.waitForHost.image.repository | string | `"quay.io/curl/curl"` | image repository |
| registration.job.initContainers.waitForHost.image.tag | string | `"8.1.2"` | image tag |
| registration.job.initContainers.waitForHost.interval | int | `5` | seconds to wait between attempts |
| registration.job.initContainers.waitForHost.path | string | `"/health"` | path to append to the derived HOST when polling (e.g. /health) |
| registration.job.resources | object | `{}` | Resource requests and limits for the registration job container |
| registration.job.serviceAccountName | string | `""` | Service account name to use for the registration job pod |
| registration.job.ttlSecondsAfterFinished | int | `120` | Seconds after the job finishes before it is automatically deleted. Set to 0 to delete immediately. |
| registration.prepScript | string | `""` | Shell script snippet executed before the registration curl calls |
| registration.services | list | `[]` | List of credential config services to register. Each entry is posted to the CCS /service endpoint. |
| route.annotations | object | `{}` | annotations to be added to the route |
| route.certificate | object | `{}` | see: https://github.com/FIWARE-Ops/fiware-gitops/blob/master/doc/ROUTES.md |
| route.enabled | bool | `false` |  |
| route.tls | object | `{"termination":"edge"}` | tls configuration for the route |
| service.annotations | object | `{}` | additional annotations, if required |
| service.port | int | `3000` | port to be set for the internal service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |
| static.enabled | bool | `false` |  |
| templates | string | `nil` | if the style of the login-page should be altered, templates can be provided here. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
