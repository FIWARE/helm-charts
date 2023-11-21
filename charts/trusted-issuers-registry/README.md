# trusted-issuers-registry

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![AppVersion: 0.3.0](https://img.shields.io/badge/AppVersion-0.3.0-informational?style=flat-square)

A Helm chart for running the trusted-issuers-registry on kubernetes.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| pulledtim | <tim.smyth@fiware.org> |  |

## Source Code

* <https://github.com/fiware/trusted-issuers-registry>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additonalEnvVars | list | `[]` | a list of additional env vars to be set, check the tir docu for all available options |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | metrics to react on |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| ccs | object | `{"credentials":[{"trustedIssuersLists":["https://til.fiware.dev"],"trustedParticipantsLists":["https://tir.fiware.dev"],"type":"VerifiableCredential"}],"id":"did-registry","scopes":{"didRead":[{"trustedIssuersLists":["https://til.fiware.dev"],"trustedParticipantsLists":["https://tir.fiware.dev"],"type":"ParticipantRegistryCredential"}]}}` | Configuration for the Credential Config Service initiation |
| ccs.credentials | list | `[{"trustedIssuersLists":["https://til.fiware.dev"],"trustedParticipantsLists":["https://tir.fiware.dev"],"type":"VerifiableCredential"}]` | Credential configuration to be registered |
| ccs.id | string | `"did-registry"` | Id of the service |
| ccs.scopes | object | `{"didRead":[{"trustedIssuersLists":["https://til.fiware.dev"],"trustedParticipantsLists":["https://tir.fiware.dev"],"type":"ParticipantRegistryCredential"}]}` | Credential configurations for particular scopes |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.healthPort | int | `9090` | port to request health information at |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"quay.io/fiware/trusted-issuers-registry"` | tir image name ref: https://quay.io/repository/fiware/trusted-issuers-registry |
| deployment.image.tag | string | `"0.3.0"` | tag of the image to be used |
| deployment.livenessProbe.initialDelaySeconds | int | `30` |  |
| deployment.livenessProbe.periodSeconds | int | `10` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| deployment.nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| deployment.readinessProbe.initialDelaySeconds | int | `31` |  |
| deployment.readinessProbe.periodSeconds | int | `10` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.timeoutSeconds | int | `30` |  |
| deployment.replicaCount | int | `1` | initial number of target replications, can be different if autoscaling is enabled |
| deployment.resources | object | `{}` |  |
| deployment.revisionHistoryLimit | int | `3` | number of old replicas to be retained |
| deployment.tolerations | list | `[]` | tolerations template ref: ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| deployment.updateStrategy.rollingUpdate | object | `{"maxSurge":1,"maxUnavailable":0}` | new pods will be added gradually |
| deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` | number of pods that can be created above the desired amount while updating |
| deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` | number of pods that can be unavailable while updating |
| deployment.updateStrategy.type | string | `"RollingUpdate"` | type of the update |
| fullnameOverride | string | `""` | option to override the fullname config in the _helpers.tpl |
| ingress.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.enabled | bool | `false` | should there be an ingress to connect tir with the public internet |
| ingress.hosts | list | `[]` | all hosts to be provided |
| ingress.tls | list | `[]` | configure the ingress' tls |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| port | int | `8080` | port that the tir container uses |
| prometheus.enabled | bool | `true` | should prometheus scrape be enabled |
| prometheus.path | string | `"/prometheus"` | path for prometheus scrape |
| prometheus.port | int | `9090` | port prometheus scrape is available at |
| route.annotations | object | `{}` | annotations to be added to the route |
| route.certificate | object | `{}` |  |
| route.enabled | bool | `false` |  |
| route.tls | object | `{}` | tls configuration for the route |
| service.annotations | object | `{}` | additional annotations, if required |
| service.port | int | `8080` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a tir specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |
| tir | object | `{"additionalConfigs":null,"ngsiBroker":{"contextUrl":"https://registry.lab.gaia-x.eu/development/api/trusted-shape-registry/v1/shapes/jsonld/trustframework#","path":"ngsi-ld/v1","timeout":"30s","url":"http://broker:1026"},"satellite":{"certificate":"-----BEGIN CERTIFICATE-----\n<Satellite certificate>\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\n<Intermediate certificates>\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\n<Root CA certificate>\n-----END CERTIFICATE-----\n","id":"EU.EORI.FIWARESATELLITE","key":"-----BEGIN RSA PRIVATE KEY-----\n<Satellite private key>\n-----END RSA PRIVATE KEY-----\n","parties":[{"capability_url":"https://idp.packetdel.com/capabilities","certifications":[{"end_date":"2051-09-27T00:00:00Z","loa":3,"role":"IdentityProvider","start_date":"2021-09-27T00:00:00Z"}],"crt":"-----BEGIN CERTIFICATE-----\n<Packet Delivery Company Certificate>\n-----END CERTIFICATE-----\n","end_date":"2051-09-27T00:00:00Z","id":"EU.EORI.NLPACKETDEL","name":"Packet Delivery Company","start_date":"2021-09-27T00:00:00Z","status":"Active"}],"trustedList":[{"crt":"-----BEGIN CERTIFICATE-----\n<FIWARETEST-CA Certificate>\n-----END CERTIFICATE-----\n","name":"FIWARE_CA"}]}}` | configuration used by the application |
| tir.additionalConfigs | string | `nil` | additional properties that shall be added to the application config |
| tir.ngsiBroker | object | `{"contextUrl":"https://registry.lab.gaia-x.eu/development/api/trusted-shape-registry/v1/shapes/jsonld/trustframework#","path":"ngsi-ld/v1","timeout":"30s","url":"http://broker:1026"}` | configuration necessary for accessing the backing NGSI LD broker |
| tir.ngsiBroker.contextUrl | string | `"https://registry.lab.gaia-x.eu/development/api/trusted-shape-registry/v1/shapes/jsonld/trustframework#"` | Context file to be used in NGSI LD |
| tir.ngsiBroker.path | string | `"ngsi-ld/v1"` | path to the API |
| tir.ngsiBroker.timeout | string | `"30s"` | timeout to apply when communicating with broker |
| tir.ngsiBroker.url | string | `"http://broker:1026"` | URL of the NGSI LD broker |
| tir.satellite | object | `{"certificate":"-----BEGIN CERTIFICATE-----\n<Satellite certificate>\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\n<Intermediate certificates>\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\n<Root CA certificate>\n-----END CERTIFICATE-----\n","id":"EU.EORI.FIWARESATELLITE","key":"-----BEGIN RSA PRIVATE KEY-----\n<Satellite private key>\n-----END RSA PRIVATE KEY-----\n","parties":[{"capability_url":"https://idp.packetdel.com/capabilities","certifications":[{"end_date":"2051-09-27T00:00:00Z","loa":3,"role":"IdentityProvider","start_date":"2021-09-27T00:00:00Z"}],"crt":"-----BEGIN CERTIFICATE-----\n<Packet Delivery Company Certificate>\n-----END CERTIFICATE-----\n","end_date":"2051-09-27T00:00:00Z","id":"EU.EORI.NLPACKETDEL","name":"Packet Delivery Company","start_date":"2021-09-27T00:00:00Z","status":"Active"}],"trustedList":[{"crt":"-----BEGIN CERTIFICATE-----\n<FIWARETEST-CA Certificate>\n-----END CERTIFICATE-----\n","name":"FIWARE_CA"}]}` | configuation needed for the iShare Satellite functionality |
| tir.satellite.certificate | string | `"-----BEGIN CERTIFICATE-----\n<Satellite certificate>\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\n<Intermediate certificates>\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\n<Root CA certificate>\n-----END CERTIFICATE-----\n"` | Certificate chain of satellite |
| tir.satellite.id | string | `"EU.EORI.FIWARESATELLITE"` | Client-ID/EORI of satellite |
| tir.satellite.key | string | `"-----BEGIN RSA PRIVATE KEY-----\n<Satellite private key>\n-----END RSA PRIVATE KEY-----\n"` | Private key of satellite |
| tir.satellite.parties | list | `[{"capability_url":"https://idp.packetdel.com/capabilities","certifications":[{"end_date":"2051-09-27T00:00:00Z","loa":3,"role":"IdentityProvider","start_date":"2021-09-27T00:00:00Z"}],"crt":"-----BEGIN CERTIFICATE-----\n<Packet Delivery Company Certificate>\n-----END CERTIFICATE-----\n","end_date":"2051-09-27T00:00:00Z","id":"EU.EORI.NLPACKETDEL","name":"Packet Delivery Company","start_date":"2021-09-27T00:00:00Z","status":"Active"}]` | Configuration of parties (trusted participants)       |
| tir.satellite.trustedList | list | `[{"crt":"-----BEGIN CERTIFICATE-----\n<FIWARETEST-CA Certificate>\n-----END CERTIFICATE-----\n","name":"FIWARE_CA"}]` | Configuration of CA trusted list |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
