# dsba-pdp

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![AppVersion: 0.3.2](https://img.shields.io/badge/AppVersion-0.3.2-informational?style=flat-square)

A Helm chart for running the dsba-pdp on kubernetes.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| wistefan | <stefan.wiedemann@fiware.org> |  |

## Source Code

* <https://github.com/wistefan/dsba-pdp>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additonalEnvVars | list | `[]` | a list of additional env vars to be set, check the dsba-pdp docu for all available options |
| db.enabled | bool | `true` | should the dsba-pdp be connected to a real databse or just store in-memory |
| db.existingSecret | string | `nil` | name of the existing secret to be used for the password |
| db.host | string | `"mysql"` | host that the db is available at |
| db.migrate.enabled | bool | `true` | should database migration(or initial seeding) be applied through the init container |
| db.migrate.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| db.migrate.image.repository | string | `"quay.io/wi_stefan/dsba-db-migrations"` | dsba-db-migrations image name ref: https://quay.io/repository/wi_stefan/dsba-db-migrations |
| db.migrate.image.tag | string | `"0.0.12"` | tag of the image to be used |
| db.name | string | `"dsba"` | name of the database schema to be used |
| db.password | string | `"password"` | password for connecting the db |
| db.port | int | `3306` | port of the db |
| db.username | string | `"root"` | username to be used on the database |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.defaultAccount | object | `{"enabled":true}` | configuration for the default account to be used in case no wallet information is provided |
| deployment.defaultAccount.enabled | bool | `true` | should a default account be used |
| deployment.healthPort | int | `9090` | port to request health information at |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"quay.io/fiware/dsba-pdp"` | dsba-pdp image name ref: https://quay.io/repository/wi_stefan/dsba-pdp |
| deployment.image.tag | string | `"0.3.2"` | tag of the image to be used |
| deployment.ishare.ar.delegationPath | string | `"/delegation"` | path to be used for delegation requests |
| deployment.ishare.ar.id | string | `"EU.EORI.NL000000004"` | id of the authorization registry in iShare |
| deployment.ishare.ar.tokenPath | string | `"/connect/token"` | path to be used for token requests |
| deployment.ishare.ar.url | string | `"https://ar.isharetest.net"` | url of the registry |
| deployment.ishare.certificate | string | `""` | certificate(in pem format) to be used for the ishare client - its recommended to provide the cert and secret as an existing secret using ```ishare.existingSecret``` instead of a plain value |
| deployment.ishare.clientId | string | `"EU.EORI.TEST_PARTICIPANT"` | id of the pdp as an iShare participant |
| deployment.ishare.enabled | bool | `true` | should the pdp support the usage of iShare authorization registries |
| deployment.ishare.existingSecret | string | `nil` | name of the existing secret to be used for certificate and key |
| deployment.ishare.jwkUpdateInterval | int | `60` | frequency of updates from the jwk endpoints. In s |
| deployment.ishare.key | string | `""` | key(in pem format) to be used for the ishare client - its recommended to provide the cert and secret as an existing secret using ```ishare.existingSecret``` instead of a plain value |
| deployment.ishare.trustAnchor | object | `{"id":"EU.EORI.NL000000000","tokenPath":"/connect/token","trustedListPath":"/trusted_list","url":"https://scheme.isharetest.net"}` | configuration of the trust anchor service to be used, e.g. the satellite |
| deployment.ishare.trustAnchor.id | string | `"EU.EORI.NL000000000"` | id of the trust anchor |
| deployment.ishare.trustAnchor.tokenPath | string | `"/connect/token"` | path of the token endpoint |
| deployment.ishare.trustAnchor.trustedListPath | string | `"/trusted_list"` | path of the trusted list endpoint |
| deployment.ishare.trustAnchor.url | string | `"https://scheme.isharetest.net"` | url of the trust anchor |
| deployment.ishare.trustedFingerprints | list | `["A78FDF7BA13BBD95C6236972DD003FAE07F4E447B791B6EF6737AD22F0B61862"]` | list of certificates sha256-fingerprints that are trusted initially. Should contain the CA used by the satellite to allow validation of the trusted-list token |
| deployment.ishare.trustedList | bool | `true` | should the iShare compliant authorization registry be used as trusted-list provider? |
| deployment.ishare.trustedVerifiers | list | `[]` | jwk-endpoints from trusted verifiers. Needs to provide RFC-7517 compatible JWKS, wich will be used to validate incoming JWT. |
| deployment.ishare.updateRate | int | `5` | frequency of updates to the trusted list. In s |
| deployment.livenessProbe.failureThreshold | int | `3` |  |
| deployment.livenessProbe.initialDelaySeconds | int | `30` |  |
| deployment.livenessProbe.periodSeconds | int | `10` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| deployment.logLevel | string | `"INFO"` | loglevel to be used |
| deployment.nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| deployment.providerId | string | `"did:my:pdp"` | id of pdp as a dataprovider to verify on roles targeting the pdp |
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
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| port | int | `8080` | port that the dsba-pdp container uses |
| prometheus.enabled | bool | `true` | should prometheus scrape be enabled |
| prometheus.path | string | `"/metrics"` | path for prometheus scrape |
| prometheus.port | int | `8080` | port prometheus scrape is available at |
| service.annotations | object | `{}` | additional annotations, if required |
| service.port | int | `8080` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a dsba-pdp specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
