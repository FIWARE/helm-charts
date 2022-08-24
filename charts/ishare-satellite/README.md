# ishare-satellite

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![AppVersion: 1.1.0](https://img.shields.io/badge/AppVersion-1.1.0-informational?style=flat-square)

A Helm chart for running an implementation of the iSHARE Satellite

**Homepage:** <https://github.com/FIWARE/ishare-satellite>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| dwendland | <dennis.wendland@fiware.org> |  |

## Source Code

* <https://github.com/FIWARE/ishare-satellite>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | metrics to react on |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| config.crt | string | `"-----BEGIN CERTIFICATE-----\n<Satellite certificate>\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\n<Intermediate certificates>\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\n<Root CA certificate>\n-----END CERTIFICATE-----\n"` | Certificate chain of satellite |
| config.id | string | `"<SATELLITE_EORI>"` | Client-ID/EORI of satellite |
| config.key | string | `"-----BEGIN RSA PRIVATE KEY-----\n<Satellite private key>\n-----END RSA PRIVATE KEY-----\n"` | Private key of satellite |
| config.parties | list | `[{"capability_url":"https://idp.packetdel.com/capabilities","certifications":[{"end_date":"2051-09-27T00:00:00Z","loa":3,"role":"IdentityProvider","start_date":"2021-09-27T00:00:00Z"}],"crt":"-----BEGIN CERTIFICATE-----\n<Packet Delivery Company Certificate>\n-----END CERTIFICATE-----\n","end_date":"2051-09-27T00:00:00Z","id":"EU.EORI.NLPACKETDEL","name":"Packet Delivery Company","start_date":"2021-09-27T00:00:00Z","status":"Active"},{"capability_url":"https://idp.packetdel.com/capabilities","certifications":[{"end_date":"2051-09-27T00:00:00Z","loa":3,"role":"IdentityProvider","start_date":"2021-09-27T00:00:00Z"}],"crt":"-----BEGIN CERTIFICATE-----\n<NoCheaper Certificate>\n-----END CERTIFICATE-----\n","end_date":"2051-09-27T00:00:00Z","id":"EU.EORI.NLNOCHEAPER","name":"NoCheaper","start_date":"2021-09-27T00:00:00Z","status":"Active"},{"crt":"-----BEGIN CERTIFICATE-----\n<HappyPets Certificate>\n-----END CERTIFICATE-----\n","end_date":"2051-09-27T00:00:00Z","id":"EU.EORI.NLHAPPYPETS","name":"HappyPets","start_date":"2021-09-27T00:00:00Z","status":"NotActive"}]` | Configuration of parties (trusted participants) |
| config.trusted_list | list | `[{"crt":"-----BEGIN CERTIFICATE-----\n<iSHARETestCA Certificate>\n-----END CERTIFICATE-----\n","name":"iSHARETestCA","status":"granted","validity":"valid"},{"crt":"-----BEGIN CERTIFICATE-----\n<FIWARETEST-CA Certificate>\n-----END CERTIFICATE-----\n","name":"FIWARETEST-CA","status":"granted","validity":"valid"}]` | Configuration of CA trusted list |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"fiware/ishare-satellite"` | image name ref: https://hub.docker.com/r/i4trust/activation-service |
| deployment.image.tag | string | `"1.1.0"` | tag of the image to be used |
| deployment.livenessProbe.initialDelaySeconds | int | `20` |  |
| deployment.livenessProbe.periodSeconds | int | `10` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| deployment.nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| deployment.readinessProbe.initialDelaySeconds | int | `21` |  |
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
| ingress.enabled | bool | `false` | should there be an ingress to connect the satellite with the public internet |
| ingress.hosts | list | `[]` | all hosts to be provided |
| ingress.tls | list | `[]` | configure the ingress' tls |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| route.annotations | object | `{}` | annotations to be added to the route |
| route.certificate | object | `{}` | see: https://github.com/FIWARE-Ops/fiware-gitops/blob/master/doc/ROUTES.md |
| route.enabled | bool | `false` |  |
| route.tls | object | `{}` | tls configuration for the route |
| satellite.accessTokenDuration | int | `3600` | Access token expiration duration (in s) |
| satellite.authorizationHeader | string | `"Authorization"` | Header name where to expect access_token |
| satellite.fingerprintEncoding | string | `"UTF-8"` | Encoding of the certificate fingerprint for the trusted list |
| satellite.logLevel | string | `"info"` | Log Level |
| satellite.maxHeaderSize | int | `32768` | Maximum header size in bytes |
| satellite.maxPartiesPerPage | int | `10` | Maximum number of parties per page for queries |
| satellite.port | int | `8080` | Listen port |
| satellite.responseTokenDuration | int | `30` | JWT expiration duration (in s) of response tokens, besides the access token |
| satellite.subjectEncoding | string | `"UTF-8"` | Encoding of certificate subject names |
| satellite.workers | int | `4` | Number of (gunicorn) workers that should be created |
| satellite.x5cEncoding | string | `"UTF-8"` | Encoding of x5c certificates in JWTs |
| service.annotations | object | `{}` | addtional annotations, if required |
| service.port | int | `8080` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a satellite specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.9.1](https://github.com/norwoodj/helm-docs/releases/v1.9.1)
