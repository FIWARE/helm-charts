# fdsc-edc

![Version: 0.1.3](https://img.shields.io/badge/Version-0.1.3-informational?style=flat-square) ![AppVersion: 0.1.4](https://img.shields.io/badge/AppVersion-0.1.4-informational?style=flat-square)

A Helm chart for running the fdsc-edc on kubernetes.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| wistefan | <stefan.wiedemann@seamware.org> |  |

## Source Code

* <https://github.com/SEAMWARE/fdsc-edc>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| common.additonalEnvVars | list | `[]` | a list of additional env vars to be set |
| common.autoscaling.enabled | bool | `false` |  |
| common.config.dcp.enabled | bool | `false` |  |
| common.config.dcp.scopes.catalog | string | `nil` |  |
| common.config.dcp.scopes.negotiation | string | `nil` |  |
| common.config.dcp.scopes.transfer | string | `nil` |  |
| common.config.dcp.scopes.version | string | `nil` |  |
| common.config.ebsiTir.enabled | bool | `false` |  |
| common.config.ebsiTir.tilAddress | string | `nil` |  |
| common.config.edc.jsonld | object | `{"http":{"enabled":"trusted"},"https":{"enabled":true}}` | handling of edc internal json-ld resolution  |
| common.config.edc.log.level | string | `"DEBUG"` |  |
| common.config.edc.participant.id | string | `nil` |  |
| common.config.fdscTransfer | object | `{"apisix":{"address":null,"httpsProxy":null,"token":null},"dcp":{"enabled":false,"oid":{"host":null,"jwksPath":"/.well-known/jwks","openIdPath":"/.well-known/openid-configuration"}},"enabled":true,"oid4vc":{"credentialsConfigAddress":null,"enabled":false,"odrlPapHost":"http://odrl-pap:8080","opaHost":"http://localhost:8181","verifierHost":null,"verifierInternalHost":null},"transferHost":null}` | configuration of the transfer process extension |
| common.config.fdscTransfer.apisix | object | `{"address":null,"httpsProxy":null,"token":null}` | configuration of the apisix to be confiugured for serving the process |
| common.config.fdscTransfer.apisix.address | string | `nil` | address of the management api of apisix |
| common.config.fdscTransfer.apisix.httpsProxy | string | `nil` | in case the route should use a proxy, configure it here |
| common.config.fdscTransfer.apisix.token | string | `nil` | token to be used as an API-Key at the mangement api |
| common.config.fdscTransfer.dcp | object | `{"enabled":false,"oid":{"host":null,"jwksPath":"/.well-known/jwks","openIdPath":"/.well-known/openid-configuration"}}` | configuration to be used in case provisioning of DCP secured resources is supported |
| common.config.fdscTransfer.dcp.enabled | bool | `false` | should it be enabled |
| common.config.fdscTransfer.dcp.oid | object | `{"host":null,"jwksPath":"/.well-known/jwks","openIdPath":"/.well-known/openid-configuration"}` | address of the dsp-jwks endpoint |
| common.config.fdscTransfer.dcp.oid.host | string | `nil` | Host of the controlplane accessible from the jwt-verifier(e.g. apisix) |
| common.config.fdscTransfer.dcp.oid.jwksPath | string | `"/.well-known/jwks"` | path to the jwks-endpoint |
| common.config.fdscTransfer.dcp.oid.openIdPath | string | `"/.well-known/openid-configuration"` | path to the openid-configuration |
| common.config.fdscTransfer.enabled | bool | `true` | should it be enabled |
| common.config.fdscTransfer.oid4vc | object | `{"credentialsConfigAddress":null,"enabled":false,"odrlPapHost":"http://odrl-pap:8080","opaHost":"http://localhost:8181","verifierHost":null,"verifierInternalHost":null}` | configuration to be used in case provisioning of OID4VC secured resources is supported |
| common.config.fdscTransfer.oid4vc.credentialsConfigAddress | string | `nil` | address of the credentials config service to be used |
| common.config.fdscTransfer.oid4vc.enabled | bool | `false` | should OID4VC provisioning be enabled |
| common.config.fdscTransfer.oid4vc.odrlPapHost | string | `"http://odrl-pap:8080"` | host of the ODRL-PAP to register the policies |
| common.config.fdscTransfer.oid4vc.opaHost | string | `"http://localhost:8181"` | internal address of the open policy agent - to be used as PDP on the incoming routes  |
| common.config.fdscTransfer.oid4vc.verifierHost | string | `nil` | external host of the verifier to be used for OID4VP on transfers |
| common.config.fdscTransfer.oid4vc.verifierInternalHost | string | `nil` | internal host of the verifier to be used for OID4VP on transfers, the external one can also be reused here |
| common.config.fdscTransfer.transferHost | string | `nil` | host to be used for offering the transfer processes |
| common.config.oauth | object | `{"clientId":null,"secretAlias":null,"tokenUrl":null}` | configuration of the oauht integration with the identity-services |
| common.config.oauth.clientId | string | `nil` | client id to be used |
| common.config.oauth.secretAlias | string | `nil` | alias of the secret used to access the token service |
| common.config.oauth.tokenUrl | string | `nil` | address of the token service |
| common.config.oid4vp | object | `{"clientId":"dsp","credentialsFolder":null,"enabled":false,"holder":{"id":null,"key":{"path":null,"type":"EC"},"kid":null,"signatureAlgorithm":"ECDH-ES"},"organizationClaim":"verifiableCredential.issuer","proxy":{"enabled":false,"host":null,"port":null},"scope":"openid","trustAll":false,"trustAnchorsFolder":null}` | configuration for the OID4VP extension |
| common.config.oid4vp.clientId | string | `"dsp"` | client id to be used for OID4VP |
| common.config.oid4vp.credentialsFolder | string | `nil` | folder of the credentials to be used for authentication  |
| common.config.oid4vp.enabled | bool | `false` | should the extension be enabled |
| common.config.oid4vp.holder | object | `{"id":null,"key":{"path":null,"type":"EC"},"kid":null,"signatureAlgorithm":"ECDH-ES"}` | identification of the credentials holder |
| common.config.oid4vp.holder.id | string | `nil` | id of the holder |
| common.config.oid4vp.holder.key | object | `{"path":null,"type":"EC"}` | key to be used for signing the presentations |
| common.config.oid4vp.holder.key.path | string | `nil` | path to the key |
| common.config.oid4vp.holder.key.type | string | `"EC"` | type of the key |
| common.config.oid4vp.holder.kid | string | `nil` | kid to be used for signing, often the same as id |
| common.config.oid4vp.holder.signatureAlgorithm | string | `"ECDH-ES"` | algorithm to be used for signing the verifiable presentations |
| common.config.oid4vp.organizationClaim | string | `"verifiableCredential.issuer"` | claim used inside the jwts for identifying the organization |
| common.config.oid4vp.proxy | object | `{"enabled":false,"host":null,"port":null}` | configuration of the proxy to be used for OID4VP authentication         |
| common.config.oid4vp.proxy.enabled | bool | `false` | should a proxy be used at all |
| common.config.oid4vp.proxy.host | string | `nil` | host of the proxy |
| common.config.oid4vp.scope | string | `"openid"` | scope to be used |
| common.config.oid4vp.trustAll | bool | `false` | trust all certificates presented at https. DO NOT USE IN PRODUCTION |
| common.config.oid4vp.trustAnchorsFolder | string | `nil` | additional trust-anchors to be used for client identification(e.g. the verifier) |
| common.config.testExtension | object | `{"controller":{"enabled":false,"path":"/tck","port":8687},"enabled":false,"identity":{"enabled":false}}` | configuration of the test-extension. Only relevant for running conformance tests |
| common.config.testExtension.controller | object | `{"enabled":false,"path":"/tck","port":8687}` | configuration of the test controller |
| common.config.testExtension.controller.enabled | bool | `false` | should the controller providing additional test endpoints be enabled |
| common.config.testExtension.controller.path | string | `"/tck"` | path that the test endpoints are available at |
| common.config.testExtension.controller.port | int | `8687` | port that the test endpoints are available at |
| common.config.testExtension.enabled | bool | `false` | should it be enabled |
| common.config.testExtension.identity | object | `{"enabled":false}` | configuration of the test(e.g. no-op) identity service |
| common.config.testExtension.identity.enabled | bool | `false` | should it be enabled |
| common.config.tmfExtension | object | `{"agreementApi":null,"catalog":{"enabled":true},"enabled":true,"partyCatalogApi":null,"productCatalogApi":null,"productInventoryApi":null,"productOrderApi":null,"quoteApi":null,"usageManagementApi":null}` | configuration of the TMForum extension |
| common.config.tmfExtension.agreementApi | string | `nil` | address of the agreement api to be used |
| common.config.tmfExtension.catalog | object | `{"enabled":true}` | should the tmforum extension for the catalog endpoint be enable |
| common.config.tmfExtension.enabled | bool | `true` | should the extension be enabled |
| common.config.tmfExtension.partyCatalogApi | string | `nil` | address of the party catalog api to be used |
| common.config.tmfExtension.productCatalogApi | string | `nil` | address of the product catalog api to be used |
| common.config.tmfExtension.productInventoryApi | string | `nil` | address of the product inventory api to be used |
| common.config.tmfExtension.productOrderApi | string | `nil` | address of the product ordering api to be used |
| common.config.tmfExtension.quoteApi | string | `nil` | address of the quote api to be used |
| common.config.tmfExtension.usageManagementApi | string | `nil` | address of the usage management api to be used |
| common.config.vault.hashicorp.enabled | bool | `false` |  |
| common.config.vault.hashicorp.healthCheck.enabled | bool | `true` |  |
| common.config.vault.hashicorp.healthCheck.standbyOk | bool | `true` |  |
| common.config.vault.hashicorp.paths.health | string | `"/v1/sys/health"` |  |
| common.config.vault.hashicorp.paths.secret | string | `"/v1/secret"` |  |
| common.config.vault.hashicorp.timeout | string | `nil` |  |
| common.config.vault.hashicorp.token | string | `nil` |  |
| common.config.vault.hashicorp.url | string | `nil` |  |
| common.config.web.http.catalog.path | string | `"/api/catalog"` |  |
| common.config.web.http.catalog.port | int | `8083` |  |
| common.config.web.http.control.path | string | `"/api/control"` |  |
| common.config.web.http.control.port | int | `8082` |  |
| common.config.web.http.management.path | string | `"/api/v1/management"` |  |
| common.config.web.http.management.port | int | `8085` |  |
| common.config.web.http.port | int | `8081` |  |
| common.config.web.http.protocol.path | string | `"/api/dsp"` |  |
| common.config.web.http.protocol.port | int | `8080` |  |
| common.config.web.http.version.path | string | `"/api/version"` |  |
| common.config.web.http.version.port | int | `8084` |  |
| common.deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| common.deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| common.deployment.additionalVolumeMounts | list | `[]` | additional volume |
| common.deployment.additionalVolumes | list | `[]` | additional volumes to be added for the containers |
| common.deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| common.deployment.args | list | `[]` | arguments to be set for the container |
| common.deployment.command | list | `[]` | command to be used for starting the container |
| common.deployment.image.pullPolicy | string | `"Always"` | specification of the image pull policy |
| common.deployment.image.repository | string | `"quay.io/seamware/fdsc-edc-controlplane-oid4vc"` | image name |
| common.deployment.imagePullSecrets | list | `[]` | secrets for pulling images from a private repository ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| common.deployment.livenessProbe.failureThreshold | int | `3` |  |
| common.deployment.livenessProbe.initialDelaySeconds | int | `30` |  |
| common.deployment.livenessProbe.periodSeconds | int | `10` |  |
| common.deployment.livenessProbe.successThreshold | int | `1` |  |
| common.deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| common.deployment.nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| common.deployment.path | string | `"/api"` | base path of the controlplane |
| common.deployment.port | int | `8080` | port that the controlplane container uses as a base |
| common.deployment.readinessProbe.failureThreshold | int | `3` |  |
| common.deployment.readinessProbe.initialDelaySeconds | int | `31` |  |
| common.deployment.readinessProbe.periodSeconds | int | `10` |  |
| common.deployment.readinessProbe.successThreshold | int | `1` |  |
| common.deployment.readinessProbe.timeoutSeconds | int | `30` |  |
| common.deployment.replicaCount | int | `1` | initial number of target replications, can be different if autoscaling is enabled |
| common.deployment.revisionHistoryLimit | int | `3` | number of old replicas to be retained |
| common.deployment.tolerations | list | `[]` | tolerations template ref: ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| common.deployment.updateStrategy.rollingUpdate | object | `{"maxSurge":1,"maxUnavailable":0}` | new pods will be added gradually |
| common.deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` | number of pods that can be created above the desired amount while updating |
| common.deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` | number of pods that can be unavailable while updating |
| common.deployment.updateStrategy.type | string | `"RollingUpdate"` | type of the update |
| common.ingress.annotations | object | `{}` | annotations to be added to the ingress |
| common.ingress.enabled | bool | `false` | should there be an ingress to connect the dsp with the public internet |
| common.ingress.hosts | list | `[]` | all hosts to be provided |
| common.ingress.tls | list | `[]` | configure the ingress' tls |
| common.service.annotations | object | `{}` | additional annotations, if required |
| common.service.catalog | object | `{"port":8083}` | port of the catalog api |
| common.service.control | object | `{"port":8082}` | port of the control api |
| common.service.management | object | `{"port":8085}` | port of the version management |
| common.service.port | int | `8081` | port to be used by the service |
| common.service.protocol | object | `{"port":8080}` | port of the protocol api |
| common.service.serviceNameOverride | string | `""` | define the name of the service and avoid generating one |
| common.service.type | string | `"ClusterIP"` | service type |
| common.service.version | object | `{"port":8084}` | port of the version api |
| deployment | object | `{}` |  |
| fullnameOverride | string | `""` | option to override the fullname config in the _helpers.tpl |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| service.annotations | object | `{}` | additional annotations, if required |
| service.port | int | `8080` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a apollo specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
