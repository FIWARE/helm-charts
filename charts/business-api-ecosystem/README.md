# business-api-ecosystem

![Version: 1.0.3](https://img.shields.io/badge/Version-1.0.3-informational?style=flat-square) ![AppVersion: 2026.05.14](https://img.shields.io/badge/AppVersion-2026.05.14-informational?style=flat-square)

A Helm chart for running the FIWARE business API ecosystem (FIWARE Marketplace) on Kubernetes

**Homepage:** <https://business-api-ecosystem.readthedocs.io/en/latest/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| dwendland | <dennis.wendland@fiware.org> |  |
| wistefan | <stefan.wiedemann@seamware.com> |  |
| fdelavega | <francisco.delavega@seamware.com> |  |

## Source Code

* <https://github.com/FIWARE-TMForum/Business-API-Ecosystem>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://fiware.github.io/helm-charts | common | 0.1.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| bizEcosystemChargingBackend.authorizeServicePath | string | `"/authorizeService/apiKeys"` | Authorize service path of the logic proxy |
| bizEcosystemChargingBackend.backup.bucketName | string | `"gs://my/bucket"` |  |
| bizEcosystemChargingBackend.backup.enabled | bool | `false` |  |
| bizEcosystemChargingBackend.backup.filePrefix | string | `"charging"` |  |
| bizEcosystemChargingBackend.backup.image.pullPolicy | string | `"IfNotPresent"` |  |
| bizEcosystemChargingBackend.backup.image.repository | string | `"fiware/copy-to-gcs"` |  |
| bizEcosystemChargingBackend.backup.image.tag | string | `"0.0.3"` |  |
| bizEcosystemChargingBackend.backup.schedule | string | `"* 1 *  *  *"` |  |
| bizEcosystemChargingBackend.backup.secretName | string | `"gcs-secret"` |  |
| bizEcosystemChargingBackend.basePath | string | `"/business-ecosystem-charging-backend"` | Base app path of charging backend (for versions < 8.1.0: /business-ecosystem-charging-backend, for versions >= 8.1.0: /opt/business-ecosystem-charging-backend) |
| bizEcosystemChargingBackend.billingUrl | string | `""` | Optional URL for billing service integration |
| bizEcosystemChargingBackend.db.authMechanism | string | `""` | optional MongoDB auth mechanism (e.g. SCRAM-SHA-1, SCRAM-SHA-256) |
| bizEcosystemChargingBackend.db.database | string | `"charging_db"` |  |
| bizEcosystemChargingBackend.db.host | string | `"mongo"` |  |
| bizEcosystemChargingBackend.db.password | string | `"pass"` |  |
| bizEcosystemChargingBackend.db.port | int | `27017` |  |
| bizEcosystemChargingBackend.db.secretKey | string | `"dbPassword"` | key of the password inside the secret |
| bizEcosystemChargingBackend.db.user | string | `"root"` |  |
| bizEcosystemChargingBackend.deployment.additionalAnnotations | object | `{}` |  |
| bizEcosystemChargingBackend.deployment.additionalLabels | object | `{}` |  |
| bizEcosystemChargingBackend.deployment.affinity | object | `{}` |  |
| bizEcosystemChargingBackend.deployment.image.pullPolicy | string | `"IfNotPresent"` |  |
| bizEcosystemChargingBackend.deployment.image.repository | string | `"fiware/biz-ecosystem-charging-backend"` |  |
| bizEcosystemChargingBackend.deployment.image.tag | string | `"11.7.0"` |  |
| bizEcosystemChargingBackend.deployment.livenessProbe.failureThreshold | int | `10` |  |
| bizEcosystemChargingBackend.deployment.livenessProbe.initialDelaySeconds | int | `20` |  |
| bizEcosystemChargingBackend.deployment.livenessProbe.periodSeconds | int | `5` |  |
| bizEcosystemChargingBackend.deployment.livenessProbe.successThreshold | int | `1` |  |
| bizEcosystemChargingBackend.deployment.livenessProbe.timeoutSeconds | int | `5` |  |
| bizEcosystemChargingBackend.deployment.nodeSelector | object | `{}` |  |
| bizEcosystemChargingBackend.deployment.readinessProbe.failureThreshold | int | `10` |  |
| bizEcosystemChargingBackend.deployment.readinessProbe.initialDelaySeconds | int | `15` |  |
| bizEcosystemChargingBackend.deployment.readinessProbe.periodSeconds | int | `5` |  |
| bizEcosystemChargingBackend.deployment.readinessProbe.successThreshold | int | `1` |  |
| bizEcosystemChargingBackend.deployment.readinessProbe.timeoutSeconds | int | `5` |  |
| bizEcosystemChargingBackend.deployment.replicaCount | int | `1` |  |
| bizEcosystemChargingBackend.deployment.revisionHistoryLimit | int | `3` |  |
| bizEcosystemChargingBackend.deployment.tolerations | list | `[]` |  |
| bizEcosystemChargingBackend.deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` |  |
| bizEcosystemChargingBackend.deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` |  |
| bizEcosystemChargingBackend.deployment.updateStrategy.type | string | `"RollingUpdate"` |  |
| bizEcosystemChargingBackend.deployment.updateStrategyPVC.type | string | `"Recreate"` |  |
| bizEcosystemChargingBackend.dpas.clientApiUrl | string | `""` | DPAS payment start endpoint |
| bizEcosystemChargingBackend.dpas.key | string | `""` | DPAS JWT verification key |
| bizEcosystemChargingBackend.email.mail | string | `"charging@email.com"` |  |
| bizEcosystemChargingBackend.enabled | bool | `true` |  |
| bizEcosystemChargingBackend.extraEnvVars | list | `[]` | List of additional ENV vars to be set, e.g., to be used in asset plugins |
| bizEcosystemChargingBackend.extraEnvVarsSecret | string | `""` | Name of existing Secret containing extra ENV vars to be set (in case of sensitive data) |
| bizEcosystemChargingBackend.fullnameOverride | string | `""` |  |
| bizEcosystemChargingBackend.initContainers | bool | `true` | use initcontainers to wait for the apis to be deployed |
| bizEcosystemChargingBackend.loglevel | string | `"info"` | Loglevel |
| bizEcosystemChargingBackend.maxUploadSize | int | `428800` | Maximum asset upload size (in MB) |
| bizEcosystemChargingBackend.media.annotations | object | `{}` | Annotations |
| bizEcosystemChargingBackend.media.enabled | bool | `true` | Enable the PVC for media storage |
| bizEcosystemChargingBackend.media.size | string | `"8Gi"` | Size of the PVC |
| bizEcosystemChargingBackend.name | string | `"biz-ecosystem-charging-backend"` |  |
| bizEcosystemChargingBackend.notificationRecipientEmail | string | `""` | Optional e-mail address receiving billing notifications |
| bizEcosystemChargingBackend.operatorId | string | `""` | Optional identifier of the party operating the marketplace |
| bizEcosystemChargingBackend.payment.method | string | `"None"` | method: paypal or None (testing mode payment disconected) |
| bizEcosystemChargingBackend.plugins.annotations | object | `{}` |  |
| bizEcosystemChargingBackend.plugins.enabled | bool | `false` |  |
| bizEcosystemChargingBackend.plugins.idmPassword | string | `"admin-password"` |  |
| bizEcosystemChargingBackend.plugins.idmUser | string | `"admin"` |  |
| bizEcosystemChargingBackend.plugins.size | string | `"4Gi"` |  |
| bizEcosystemChargingBackend.port | int | `8006` | port that the charging backend container uses |
| bizEcosystemChargingBackend.propagateToken | bool | `true` | Sets whether to expect the user access token in each request from the logic proxy |
| bizEcosystemChargingBackend.relatedPartySchemaLocation | string | `""` | Optional schema URL used to extend entities that miss a relatedParty object |
| bizEcosystemChargingBackend.securityContext | object | `{}` |  |
| bizEcosystemChargingBackend.service.annotations | object | `{}` |  |
| bizEcosystemChargingBackend.service.port | int | `8006` |  |
| bizEcosystemChargingBackend.service.type | string | `"ClusterIP"` |  |
| bizEcosystemChargingBackend.serviceAccount.annotations | object | `{}` |  |
| bizEcosystemChargingBackend.serviceAccount.create | bool | `false` |  |
| bizEcosystemChargingBackend.serviceAccount.name | string | `"ssc"` |  |
| bizEcosystemChargingBackend.token.cert | string | `""` | String with certificate (chain) in PEM format |
| bizEcosystemChargingBackend.token.enabled | bool | `false` | Enable storage of local key and certificate |
| bizEcosystemChargingBackend.token.identifier | string | `""` | Identifier (e.g. EORI) of local marketplace instance |
| bizEcosystemChargingBackend.token.key | string | `""` | String with private key in PEM format |
| bizEcosystemChargingBackend.verifyRequests | bool | `true` | Whether or not the BAE validates SSL certificates on requests to external components |
| bizEcosystemLogicProxy.allowEditParty | bool | `true` | Allow users to edit party attributes |
| bizEcosystemLogicProxy.allowLocalEORI | bool | `false` | Allow to use organisations from local IDP as participants when creating or acquiring offerings |
| bizEcosystemLogicProxy.basePath | string | `"/business-ecosystem-logic-proxy"` | Base app path of logic proxy (for versions < 8.1.0: /business-ecosystem-logic-proxy, for versions >= 8.1.0: /opt/business-ecosystem-logic-proxy) |
| bizEcosystemLogicProxy.billingEngineUrl | string | `""` |  |
| bizEcosystemLogicProxy.chatUrl | string | `""` | Optional custom URLs used by logic-proxy backend flows and UI integrations |
| bizEcosystemLogicProxy.collectStaticCommand | string | `"True"` | Execute the collect static command on startup |
| bizEcosystemLogicProxy.command | list | `[]` | in case the startup command should be alterd |
| bizEcosystemLogicProxy.contactUsNotificationUrl | string | `""` |  |
| bizEcosystemLogicProxy.dataSpaceEnabled | bool | `false` |  |
| bizEcosystemLogicProxy.db.database | string | `"belp_db"` | Database name for connecting the database |
| bizEcosystemLogicProxy.db.host | string | `"mongo"` | host of the database to be used |
| bizEcosystemLogicProxy.db.password | string | `"pass"` | password for connecting the database |
| bizEcosystemLogicProxy.db.port | int | `27017` | port of the database to be used |
| bizEcosystemLogicProxy.db.secretKey | string | `"dbPassword"` | key of the password inside the secret |
| bizEcosystemLogicProxy.db.user | string | `"root"` | username for connecting the database |
| bizEcosystemLogicProxy.elastic.engine | string | `"elasticsearch"` | indexing engine of logic proxy |
| bizEcosystemLogicProxy.elastic.url | string | `"elasticsearch:9200"` | URL of elasticsearch service |
| bizEcosystemLogicProxy.elastic.version | int | `7` | API version of elasticsearch |
| bizEcosystemLogicProxy.enabled | bool | `true` |  |
| bizEcosystemLogicProxy.endpointQuoteHost | string | `""` | Optional endpoint host overrides |
| bizEcosystemLogicProxy.endpointQuotePath | string | `""` |  |
| bizEcosystemLogicProxy.endpointQuotePort | string | `""` |  |
| bizEcosystemLogicProxy.endpointSearchHost | string | `""` |  |
| bizEcosystemLogicProxy.externalIdp.enabled | bool | `false` | Enable usage of external IDPs |
| bizEcosystemLogicProxy.externalIdp.showLocalLogin | bool | `false` | Show login button for local IDP on login modal dialog with list of external IDPs |
| bizEcosystemLogicProxy.extraVolumeMounts | list | `[]` |  |
| bizEcosystemLogicProxy.fullnameOverride | string | `""` |  |
| bizEcosystemLogicProxy.ingress.annotations | object | `{}` | annotations to be added to the ingress |
| bizEcosystemLogicProxy.ingress.enabled | bool | `false` | should there be an ingress to connect the logic proxy with the public internet |
| bizEcosystemLogicProxy.ingress.hosts | list | `[]` | all hosts to be provided |
| bizEcosystemLogicProxy.ingress.tls | list | `[]` | configure the ingress' tls |
| bizEcosystemLogicProxy.initContainers | bool | `true` | use initcontainers to wait for the apis to be deployed |
| bizEcosystemLogicProxy.launchValidationEnabled | bool | `false` |  |
| bizEcosystemLogicProxy.name | string | `"biz-ecosystem-logic-proxy"` |  |
| bizEcosystemLogicProxy.nodeEnvironment | string | `"development"` | Deployment in development or in production |
| bizEcosystemLogicProxy.offeringSchema | string | `""` |  |
| bizEcosystemLogicProxy.operatorId | string | `""` | Optional metadata/schema settings |
| bizEcosystemLogicProxy.partyLocation | string | `""` |  |
| bizEcosystemLogicProxy.paymentGateway | string | `""` |  |
| bizEcosystemLogicProxy.port | int | `8004` | port that the logic proxy container uses |
| bizEcosystemLogicProxy.priceCompSchema | string | `""` |  |
| bizEcosystemLogicProxy.propagateToken | bool | `true` | Sets whether the logic proxy should propagate the user access token to the backend components |
| bizEcosystemLogicProxy.purchaseEnabled | bool | `false` |  |
| bizEcosystemLogicProxy.quoteEnabled | bool | `false` | Optional feature flags |
| bizEcosystemLogicProxy.revenueModel | int | `30` | Default market owner precentage for Revenue Sharing models |
| bizEcosystemLogicProxy.route.enabled | bool | `false` | should the deployment create openshift routes |
| bizEcosystemLogicProxy.route.routes | list | `[{"annotations":{},"certificate":{},"tls":{}}]` | Routes that should be created |
| bizEcosystemLogicProxy.route.routes[0] | object | `{"annotations":{},"certificate":{},"tls":{}}` | annotations to be added to the route |
| bizEcosystemLogicProxy.route.routes[0].certificate | object | `{}` | see: https://github.com/FIWARE-Ops/fiware-gitops/blob/master/doc/ROUTES.md |
| bizEcosystemLogicProxy.route.routes[0].tls | object | `{}` | tls configuration for the route |
| bizEcosystemLogicProxy.searchUrl | string | `""` |  |
| bizEcosystemLogicProxy.securityContext | object | `{}` |  |
| bizEcosystemLogicProxy.service.annotations | object | `{}` |  |
| bizEcosystemLogicProxy.service.port | int | `8004` |  |
| bizEcosystemLogicProxy.service.type | string | `"ClusterIP"` |  |
| bizEcosystemLogicProxy.serviceAccount.annotations | object | `{}` |  |
| bizEcosystemLogicProxy.serviceAccount.create | bool | `false` |  |
| bizEcosystemLogicProxy.serviceAccount.name | string | `"ssc"` |  |
| bizEcosystemLogicProxy.siopIsRedirection | string | `""` | Optional SIOP mode toggle, passed as BAE_LP_SIOP_IS_REDIRECTION |
| bizEcosystemLogicProxy.siopOperators | string | `""` | Optional comma-separated operator list, passed as BAE_LP_SIOP_OPERATORS |
| bizEcosystemLogicProxy.statefulset.additionalAnnotations | object | `{}` |  |
| bizEcosystemLogicProxy.statefulset.additionalLabels | object | `{}` |  |
| bizEcosystemLogicProxy.statefulset.affinity | object | `{}` |  |
| bizEcosystemLogicProxy.statefulset.image.pullPolicy | string | `"IfNotPresent"` |  |
| bizEcosystemLogicProxy.statefulset.image.repository | string | `"fiware/biz-ecosystem-logic-proxy"` |  |
| bizEcosystemLogicProxy.statefulset.image.tag | string | `"11.20.3"` |  |
| bizEcosystemLogicProxy.statefulset.livenessProbe.failureThreshold | int | `10` |  |
| bizEcosystemLogicProxy.statefulset.livenessProbe.initialDelaySeconds | int | `20` |  |
| bizEcosystemLogicProxy.statefulset.livenessProbe.periodSeconds | int | `5` |  |
| bizEcosystemLogicProxy.statefulset.livenessProbe.successThreshold | int | `1` |  |
| bizEcosystemLogicProxy.statefulset.livenessProbe.timeoutSeconds | int | `5` |  |
| bizEcosystemLogicProxy.statefulset.nodeSelector | object | `{}` |  |
| bizEcosystemLogicProxy.statefulset.readinessProbe.failureThreshold | int | `10` |  |
| bizEcosystemLogicProxy.statefulset.readinessProbe.initialDelaySeconds | int | `15` |  |
| bizEcosystemLogicProxy.statefulset.readinessProbe.periodSeconds | int | `5` |  |
| bizEcosystemLogicProxy.statefulset.readinessProbe.successThreshold | int | `1` |  |
| bizEcosystemLogicProxy.statefulset.readinessProbe.timeoutSeconds | int | `5` |  |
| bizEcosystemLogicProxy.statefulset.replicaCount | int | `1` |  |
| bizEcosystemLogicProxy.statefulset.revisionHistoryLimit | int | `3` |  |
| bizEcosystemLogicProxy.statefulset.tolerations | list | `[]` |  |
| bizEcosystemLogicProxy.statefulset.updateStrategy.type | string | `"RollingUpdate"` |  |
| bizEcosystemLogicProxy.tenderingEnabled | bool | `false` |  |
| bizEcosystemLogicProxy.theme.enabled | bool | `false` | Enable theme |
| bizEcosystemLogicProxy.theme.image | string | `"my-theme-image:latest"` |  |
| bizEcosystemLogicProxy.theme.imagePullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| bizEcosystemLogicProxy.theme.name | string | `"default"` | Name of the theme |
| bizEcosystemLogicProxy.theme.sourcePath | string | `"/my-theme"` |  |
| bizEcosystemLogicProxy.token.cert | string | `""` | String with certificate (chain) in PEM format |
| bizEcosystemLogicProxy.token.enabled | bool | `false` | Enable storage of local key and certificate |
| bizEcosystemLogicProxy.token.identifier | string | `""` | Identifier (e.g. EORI) of local marketplace instance |
| bizEcosystemLogicProxy.token.key | string | `""` | String with private key in PEM format |
| externalUrl | string | `"https://marketplace.fiware.org"` |  |
| fullnameOverride | string | `""` |  |
| initContainer.apis.image | string | `"busybox"` |  |
| initContainer.apis.imagePullPolicy | string | `"IfNotPresent"` |  |
| initContainer.apis.maxRetries | int | `60` |  |
| initContainer.apis.name | string | `"wait-for-apis"` |  |
| initContainer.apis.sleepInterval | int | `10` |  |
| initContainer.mongodb.image | string | `"bitnamilegacy/mongodb"` |  |
| initContainer.mongodb.imagePullPolicy | string | `"IfNotPresent"` |  |
| initContainer.mongodb.imageTag | string | `"3.6.21"` |  |
| initContainer.mongodb.maxRetries | int | `60` |  |
| initContainer.mongodb.name | string | `"wait-for-mongodb"` |  |
| initContainer.mongodb.sleepInterval | int | `5` |  |
| initContainer.mysql.image | string | `"mysql"` |  |
| initContainer.mysql.imagePullPolicy | string | `"IfNotPresent"` |  |
| initContainer.mysql.imageTag | string | `"5.7"` |  |
| initContainer.mysql.maxRetries | int | `60` |  |
| initContainer.mysql.name | string | `"wait-for-mysql"` |  |
| initContainer.mysql.sleepInterval | int | `5` |  |
| nameOverride | string | `""` |  |
| oauth.adminrole | string | `"admin"` | Admin role |
| oauth.aggregatorrole | string | `"Aggregator"` | Aggregator role |
| oauth.certifierrole | string | `"certifier"` | Role defined in the IDM client app for organization certifiers of the BAE |
| oauth.clientSecret | string | `""` | OAuth2 Client Secret of the BAE application. E.G., market-clientSecret |
| oauth.customerrole | string | `"customer"` | Customer role |
| oauth.grantedrole | string | `"admin"` | Granted role |
| oauth.isLegacy | bool | `false` | Whether the used FIWARE IDM is version 6 or lower |
| oauth.oidc | bool | `false` | Set to true if OpenID Connect protocol should be used |
| oauth.orgadminrole | string | `"orgAdmin"` | Role defined in the IDM client app for organization admins of the BAE |
| oauth.provider | string | `"fiware"` | IDP provider for passport strategy (fiware, keycloak, github, ...) |
| oauth.sellerrole | string | `"seller"` | Seller role |
| siop.allowedRoles[0] | string | `"seller"` |  |
| siop.allowedRoles[1] | string | `"customer"` |  |
| siop.callbackPath | string | `"/auth/vc/callback"` |  |
| siop.ccs.defaultOidcScope | string | `"defaultScope"` | Default scope to be used from scopes below, if none is provided |
| siop.ccs.enabled | bool | `false` | is automatic credentials config registration enabled |
| siop.ccs.endpoint | string | `"http://credentials-config-service:8080"` | Endpoint of the CCS |
| siop.clientId | string | `"marketplace-client"` |  |
| siop.enabled | bool | `false` |  |
| siop.privateKey | string | `""` | Kubernetes Secret reference for BAE_LP_SIOP_PRIVATE_KEY (preferred over plain siop.privateKey) privateKeySecret:   name: bae-secret   key: privateKey |
| siop.privateKeyPem | string | `""` |  |
| siop.signAlgorithm | string | `"ES256"` |  |
| siop.verifier.host | string | `"https://verifier.apps.fiware.fiware.dev"` |  |
| siop.verifier.jwksPath | string | `"/.well-known/jwks"` |  |
| siop.verifier.qrCodePath | string | `"/api/v1/loginQR"` |  |
| siop.verifier.tokenPath | string | `"/token"` |  |
| tmForum.billing | object | `{}` |  |
| tmForum.catalog | object | `{}` |  |
| tmForum.customer | object | `{}` |  |
| tmForum.customerBill | object | `{}` |  |
| tmForum.inventory | object | `{}` |  |
| tmForum.ordering | object | `{}` |  |
| tmForum.party | object | `{}` |  |
| tmForum.resourceInventory | object | `{}` |  |
| tmForum.resources | object | `{}` |  |
| tmForum.serviceInventory | object | `{}` |  |
| tmForum.services | object | `{}` |  |
| tmForum.usage | object | `{}` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
