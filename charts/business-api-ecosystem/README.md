# business-api-ecosystem

![Version: 0.6.2](https://img.shields.io/badge/Version-0.6.2-informational?style=flat-square) ![AppVersion: 8.0.0](https://img.shields.io/badge/AppVersion-8.0.0-informational?style=flat-square)

A Helm chart for running the FIWARE business API ecosystem (FIWARE Marketplace) on Kubernetes

**Homepage:** <https://business-api-ecosystem.readthedocs.io/en/latest/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| dwendland | <dennis.wendland@fiware.org> |  |

## Source Code

* <https://github.com/FIWARE-TMForum/Business-API-Ecosystem>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| bizEcosystemApis.db.host | string | `"mysql"` |  |
| bizEcosystemApis.db.password | string | `"pass"` |  |
| bizEcosystemApis.deployment.additionalAnnotations | object | `{}` |  |
| bizEcosystemApis.deployment.additionalLabels | object | `{}` |  |
| bizEcosystemApis.deployment.affinity | object | `{}` |  |
| bizEcosystemApis.deployment.image.pullPolicy | string | `"IfNotPresent"` |  |
| bizEcosystemApis.deployment.image.repository | string | `"fiware/biz-ecosystem-apis"` |  |
| bizEcosystemApis.deployment.image.tag | string | `"v8.0.0"` |  |
| bizEcosystemApis.deployment.livenessProbe.initialDelaySeconds | int | `120` |  |
| bizEcosystemApis.deployment.livenessProbe.periodSeconds | int | `30` |  |
| bizEcosystemApis.deployment.livenessProbe.successThreshold | int | `1` |  |
| bizEcosystemApis.deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| bizEcosystemApis.deployment.nodeSelector | object | `{}` |  |
| bizEcosystemApis.deployment.readinessProbe.initialDelaySeconds | int | `61` |  |
| bizEcosystemApis.deployment.readinessProbe.periodSeconds | int | `30` |  |
| bizEcosystemApis.deployment.readinessProbe.successThreshold | int | `1` |  |
| bizEcosystemApis.deployment.readinessProbe.timeoutSeconds | int | `30` |  |
| bizEcosystemApis.deployment.replicaCount | int | `1` |  |
| bizEcosystemApis.deployment.revisionHistoryLimit | int | `3` |  |
| bizEcosystemApis.deployment.tolerations | list | `[]` |  |
| bizEcosystemApis.deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` |  |
| bizEcosystemApis.deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` |  |
| bizEcosystemApis.deployment.updateStrategy.type | string | `"RollingUpdate"` |  |
| bizEcosystemApis.enabled | bool | `true` |  |
| bizEcosystemApis.fullnameOverride | string | `""` |  |
| bizEcosystemApis.name | string | `"biz-ecosystem-apis"` |  |
| bizEcosystemApis.port | int | `8080` |  |
| bizEcosystemApis.securityContext | object | `{}` |  |
| bizEcosystemApis.service.annotations | object | `{}` |  |
| bizEcosystemApis.service.port | int | `8080` |  |
| bizEcosystemApis.service.type | string | `"ClusterIP"` |  |
| bizEcosystemApis.serviceAccount.annotations | object | `{}` |  |
| bizEcosystemApis.serviceAccount.create | bool | `false` |  |
| bizEcosystemApis.serviceAccount.name | string | `"ssc"` |  |
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
| bizEcosystemChargingBackend.db.database | string | `"charging_db"` |  |
| bizEcosystemChargingBackend.db.host | string | `"mongo"` |  |
| bizEcosystemChargingBackend.db.password | string | `"pass"` |  |
| bizEcosystemChargingBackend.db.port | int | `27017` |  |
| bizEcosystemChargingBackend.db.user | string | `"root"` |  |
| bizEcosystemChargingBackend.deployment.additionalAnnotations | object | `{}` |  |
| bizEcosystemChargingBackend.deployment.additionalLabels | object | `{}` |  |
| bizEcosystemChargingBackend.deployment.affinity | object | `{}` |  |
| bizEcosystemChargingBackend.deployment.image.pullPolicy | string | `"IfNotPresent"` |  |
| bizEcosystemChargingBackend.deployment.image.repository | string | `"fiware/biz-ecosystem-charging-backend"` |  |
| bizEcosystemChargingBackend.deployment.image.tag | string | `"v8.0.0"` |  |
| bizEcosystemChargingBackend.deployment.livenessProbe.initialDelaySeconds | int | `61` |  |
| bizEcosystemChargingBackend.deployment.livenessProbe.periodSeconds | int | `30` |  |
| bizEcosystemChargingBackend.deployment.livenessProbe.successThreshold | int | `1` |  |
| bizEcosystemChargingBackend.deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| bizEcosystemChargingBackend.deployment.nodeSelector | object | `{}` |  |
| bizEcosystemChargingBackend.deployment.readinessProbe.initialDelaySeconds | int | `60` |  |
| bizEcosystemChargingBackend.deployment.readinessProbe.periodSeconds | int | `30` |  |
| bizEcosystemChargingBackend.deployment.readinessProbe.successThreshold | int | `1` |  |
| bizEcosystemChargingBackend.deployment.readinessProbe.timeoutSeconds | int | `30` |  |
| bizEcosystemChargingBackend.deployment.replicaCount | int | `1` |  |
| bizEcosystemChargingBackend.deployment.revisionHistoryLimit | int | `3` |  |
| bizEcosystemChargingBackend.deployment.tolerations | list | `[]` |  |
| bizEcosystemChargingBackend.deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` |  |
| bizEcosystemChargingBackend.deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` |  |
| bizEcosystemChargingBackend.deployment.updateStrategy.type | string | `"RollingUpdate"` |  |
| bizEcosystemChargingBackend.deployment.updateStrategyPVC.type | string | `"Recreate"` |  |
| bizEcosystemChargingBackend.email.mail | string | `"charging@email.com"` |  |
| bizEcosystemChargingBackend.enabled | bool | `true` |  |
| bizEcosystemChargingBackend.extraEnvVars | list | `[]` | List of additional ENV vars to be set, e.g., to be used in asset plugins |
| bizEcosystemChargingBackend.extraEnvVarsSecret | string | `""` | Name of existing Secret containing extra ENV vars to be set (in case of sensitive data) |
| bizEcosystemChargingBackend.fullnameOverride | string | `""` |  |
| bizEcosystemChargingBackend.loglevel | string | `"info"` | Loglevel |
| bizEcosystemChargingBackend.maxUploadSize | int | `428800` | Maximum asset upload size (in MB) |
| bizEcosystemChargingBackend.media.annotations | object | `{}` | Annotations |
| bizEcosystemChargingBackend.media.enabled | bool | `true` | Enable the PVC for media storage |
| bizEcosystemChargingBackend.media.size | string | `"8Gi"` | Size of the PVC |
| bizEcosystemChargingBackend.name | string | `"biz-ecosystem-charging-backend"` |  |
| bizEcosystemChargingBackend.payment.method | string | `"None"` | method: paypal or None (testing mode payment disconected) |
| bizEcosystemChargingBackend.plugins.annotations | object | `{}` |  |
| bizEcosystemChargingBackend.plugins.enabled | bool | `false` |  |
| bizEcosystemChargingBackend.plugins.idmPassword | string | `"admin-password"` |  |
| bizEcosystemChargingBackend.plugins.idmUser | string | `"admin"` |  |
| bizEcosystemChargingBackend.plugins.size | string | `"4Gi"` |  |
| bizEcosystemChargingBackend.port | int | `8006` | port that the charging backend container uses |
| bizEcosystemChargingBackend.propagateToken | bool | `true` | Sets whether to expect the user access token in each request from the logic proxy |
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
| bizEcosystemLogicProxy.ccs.credentials | list | `[{"trustedIssuersLists":["https://til.fiware.dev"],"trustedParticipantsLists":["https://tir.fiware.dev"],"type":"VerifiableCredential"}]` | Credential configuration to be registered |
| bizEcosystemLogicProxy.ccs.endpoint | string | `""` | Endpoint of the CCS, e.g. http://credentials-config-service:8080 |
| bizEcosystemLogicProxy.ccs.id | string | `"baelp"` | Id of the service |
| bizEcosystemLogicProxy.collectStaticCommand | string | `"True"` | Execute the collect static command on startup |
| bizEcosystemLogicProxy.command | object | `{}` | in case the startup command should be alterd |
| bizEcosystemLogicProxy.db.database | string | `"belp_db"` | Database name for connecting the database |
| bizEcosystemLogicProxy.db.host | string | `"mongo"` | host of the database to be used |
| bizEcosystemLogicProxy.db.password | string | `"pass"` | password for connecting the database |
| bizEcosystemLogicProxy.db.port | int | `27017` | port of the database to be used |
| bizEcosystemLogicProxy.db.user | string | `"root"` | username for connecting the database |
| bizEcosystemLogicProxy.elastic.engine | string | `"elasticsearch"` | indexing engine of logic proxy |
| bizEcosystemLogicProxy.elastic.url | string | `"elasticsearch:9200"` | URL of elasticsearch service |
| bizEcosystemLogicProxy.elastic.version | int | `7` | API version of elasticsearch |
| bizEcosystemLogicProxy.enabled | bool | `true` |  |
| bizEcosystemLogicProxy.externalIdp.enabled | bool | `false` | Enable usage of external IDPs |
| bizEcosystemLogicProxy.externalIdp.showLocalLogin | bool | `false` | Show login button for local IDP on login modal dialog with list of external IDPs |
| bizEcosystemLogicProxy.extraContainerVolumes | object | `{}` | additional volumes to be added for the container |
| bizEcosystemLogicProxy.extraInitContainers | object | `{}` | additional init-containers to be added for the belp |
| bizEcosystemLogicProxy.extraVolumeMounts | object | `{}` | additional volumes to be mounted by the container |
| bizEcosystemLogicProxy.fullnameOverride | string | `""` |  |
| bizEcosystemLogicProxy.ingress.annotations | object | `{}` | annotations to be added to the ingress |
| bizEcosystemLogicProxy.ingress.enabled | bool | `false` | should there be an ingress to connect the logic proxy with the public internet |
| bizEcosystemLogicProxy.ingress.hosts | list | `[]` | all hosts to be provided |
| bizEcosystemLogicProxy.ingress.tls | list | `[]` | configure the ingress' tls |
| bizEcosystemLogicProxy.name | string | `"biz-ecosystem-logic-proxy"` |  |
| bizEcosystemLogicProxy.nodeEnvironment | string | `"development"` | Deployment in development or in production |
| bizEcosystemLogicProxy.port | int | `8004` | port that the logic proxy container uses |
| bizEcosystemLogicProxy.propagateToken | bool | `true` | Sets whether the logic proxy should propagate the user access token to the backend components |
| bizEcosystemLogicProxy.revenueModel | int | `30` | Default market owner precentage for Revenue Sharing models |
| bizEcosystemLogicProxy.route.enabled | bool | `false` | should the deployment create openshift routes |
| bizEcosystemLogicProxy.route.routes | list | `[{"annotations":{},"certificate":{},"tls":{}}]` | Routes that should be created |
| bizEcosystemLogicProxy.route.routes[0] | object | `{"annotations":{},"certificate":{},"tls":{}}` | annotations to be added to the route |
| bizEcosystemLogicProxy.route.routes[0].certificate | object | `{}` | see: https://github.com/FIWARE-Ops/fiware-gitops/blob/master/doc/ROUTES.md |
| bizEcosystemLogicProxy.route.routes[0].tls | object | `{}` | tls configuration for the route |
| bizEcosystemLogicProxy.securityContext | object | `{}` |  |
| bizEcosystemLogicProxy.service.annotations | object | `{}` |  |
| bizEcosystemLogicProxy.service.port | int | `8004` |  |
| bizEcosystemLogicProxy.service.type | string | `"ClusterIP"` |  |
| bizEcosystemLogicProxy.serviceAccount.annotations | object | `{}` |  |
| bizEcosystemLogicProxy.serviceAccount.create | bool | `false` |  |
| bizEcosystemLogicProxy.serviceAccount.name | string | `"ssc"` |  |
| bizEcosystemLogicProxy.statefulset.additionalAnnotations | object | `{}` |  |
| bizEcosystemLogicProxy.statefulset.additionalLabels | object | `{}` |  |
| bizEcosystemLogicProxy.statefulset.affinity | object | `{}` |  |
| bizEcosystemLogicProxy.statefulset.image.pullPolicy | string | `"IfNotPresent"` |  |
| bizEcosystemLogicProxy.statefulset.image.repository | string | `"fiware/biz-ecosystem-logic-proxy"` |  |
| bizEcosystemLogicProxy.statefulset.image.tag | string | `"v8.0.0"` |  |
| bizEcosystemLogicProxy.statefulset.livenessProbe.initialDelaySeconds | int | `61` |  |
| bizEcosystemLogicProxy.statefulset.livenessProbe.periodSeconds | int | `30` |  |
| bizEcosystemLogicProxy.statefulset.livenessProbe.successThreshold | int | `1` |  |
| bizEcosystemLogicProxy.statefulset.livenessProbe.timeoutSeconds | int | `30` |  |
| bizEcosystemLogicProxy.statefulset.nodeSelector | object | `{}` |  |
| bizEcosystemLogicProxy.statefulset.readinessProbe.initialDelaySeconds | int | `60` |  |
| bizEcosystemLogicProxy.statefulset.readinessProbe.periodSeconds | int | `30` |  |
| bizEcosystemLogicProxy.statefulset.readinessProbe.successThreshold | int | `1` |  |
| bizEcosystemLogicProxy.statefulset.readinessProbe.timeoutSeconds | int | `30` |  |
| bizEcosystemLogicProxy.statefulset.replicaCount | int | `1` |  |
| bizEcosystemLogicProxy.statefulset.revisionHistoryLimit | int | `3` |  |
| bizEcosystemLogicProxy.statefulset.tolerations | list | `[]` |  |
| bizEcosystemLogicProxy.statefulset.updateStrategy.type | string | `"RollingUpdate"` |  |
| bizEcosystemLogicProxy.theme.enabled | bool | `false` | Enable theme |
| bizEcosystemLogicProxy.theme.image | string | `"my-theme-image:latest"` |  |
| bizEcosystemLogicProxy.theme.imagePullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| bizEcosystemLogicProxy.theme.name | string | `"default"` | Name of the theme |
| bizEcosystemLogicProxy.theme.sourcePath | string | `"/my-theme"` |  |
| bizEcosystemLogicProxy.token.cert | string | `""` | String with certificate (chain) in PEM format |
| bizEcosystemLogicProxy.token.enabled | bool | `false` | Enable storage of local key and certificate |
| bizEcosystemLogicProxy.token.identifier | string | `""` | Identifier (e.g. EORI) of local marketplace instance |
| bizEcosystemLogicProxy.token.key | string | `""` | String with private key in PEM format |
| bizEcosystemRss.db.driver | string | `"com.mysql.jdbc.Driver"` |  |
| bizEcosystemRss.db.host | string | `"mysql"` |  |
| bizEcosystemRss.db.password | string | `"pass"` |  |
| bizEcosystemRss.db.port | int | `3306` |  |
| bizEcosystemRss.db.url | string | `"jdbc:mysql://mysql:3306/RSS"` |  |
| bizEcosystemRss.db.user | string | `"root"` |  |
| bizEcosystemRss.deployment.additionalAnnotations | object | `{}` |  |
| bizEcosystemRss.deployment.additionalLabels | object | `{}` |  |
| bizEcosystemRss.deployment.affinity | object | `{}` |  |
| bizEcosystemRss.deployment.image.pullPolicy | string | `"IfNotPresent"` |  |
| bizEcosystemRss.deployment.image.repository | string | `"fiware/biz-ecosystem-rss"` |  |
| bizEcosystemRss.deployment.image.tag | string | `"v8.0.0"` |  |
| bizEcosystemRss.deployment.livenessProbe.initialDelaySeconds | int | `120` |  |
| bizEcosystemRss.deployment.livenessProbe.periodSeconds | int | `30` |  |
| bizEcosystemRss.deployment.livenessProbe.successThreshold | int | `1` |  |
| bizEcosystemRss.deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| bizEcosystemRss.deployment.nodeSelector | object | `{}` |  |
| bizEcosystemRss.deployment.readinessProbe.initialDelaySeconds | int | `61` |  |
| bizEcosystemRss.deployment.readinessProbe.periodSeconds | int | `30` |  |
| bizEcosystemRss.deployment.readinessProbe.successThreshold | int | `1` |  |
| bizEcosystemRss.deployment.readinessProbe.timeoutSeconds | int | `30` |  |
| bizEcosystemRss.deployment.replicaCount | int | `1` |  |
| bizEcosystemRss.deployment.revisionHistoryLimit | int | `3` |  |
| bizEcosystemRss.deployment.tolerations | list | `[]` |  |
| bizEcosystemRss.deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` |  |
| bizEcosystemRss.deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` |  |
| bizEcosystemRss.deployment.updateStrategy.type | string | `"RollingUpdate"` |  |
| bizEcosystemRss.enabled | bool | `true` |  |
| bizEcosystemRss.fullnameOverride | string | `""` |  |
| bizEcosystemRss.name | string | `"biz-ecosystem-rss"` |  |
| bizEcosystemRss.port | int | `8080` |  |
| bizEcosystemRss.securityContext | object | `{}` |  |
| bizEcosystemRss.service.annotations | object | `{}` |  |
| bizEcosystemRss.service.port | int | `8080` |  |
| bizEcosystemRss.service.type | string | `"ClusterIP"` |  |
| bizEcosystemRss.serviceAccount.annotations | object | `{}` |  |
| bizEcosystemRss.serviceAccount.create | bool | `false` |  |
| bizEcosystemRss.serviceAccount.name | string | `"ssc"` |  |
| externalUrl | string | `"https://marketplace.fiware.org"` |  |
| fullnameOverride | string | `""` |  |
| initContainer.apis.image | string | `"busybox"` |  |
| initContainer.apis.imagePullPolicy | string | `"IfNotPresent"` |  |
| initContainer.apis.maxRetries | int | `60` |  |
| initContainer.apis.name | string | `"wait-for-apis"` |  |
| initContainer.apis.sleepInterval | int | `10` |  |
| initContainer.mongodb.image | string | `"bitnami/mongodb"` |  |
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
| initContainer.rss.image | string | `"curlimages/curl"` |  |
| initContainer.rss.imagePullPolicy | string | `"IfNotPresent"` |  |
| initContainer.rss.maxRetries | int | `60` |  |
| initContainer.rss.name | string | `"rss-wait"` |  |
| initContainer.rss.sleepInterval | int | `10` |  |
| nameOverride | string | `""` |  |
| oauth.adminrole | string | `"admin"` | Admin role |
| oauth.aggregatorrole | string | `"Aggregator"` | Aggregator role |
| oauth.callbackPath | string | `"/auth/fiware/callback"` | Callback URL path of frontend logic proxy for receiving the access tokens (callback URL would be e.g. externalUrl/auth/fiware/callback) |
| oauth.clientId | string | `"market-clientId"` | OAuth2 Client ID of the BAE application |
| oauth.clientSecret | string | `"market-clientSecret"` | OAuth2 Client Secret of the BAE application |
| oauth.customerrole | string | `"customer"` | Customer role |
| oauth.grantedrole | string | `"admin"` | Granted role |
| oauth.isLegacy | bool | `false` | Whether the used FIWARE IDM is version 6 or lower |
| oauth.oidc | bool | `false` | Set to true if OpenID Connect protocol should be used |
| oauth.orgadminrole | string | `"orgAdmin"` | Role defined in the IDM client app for organization admins of the BAE  |
| oauth.provider | string | `"fiware"` | IDP provider for passport strategy (fiware, keycloak, github, ...) |
| oauth.sellerrole | string | `"seller"` | Seller role |
| oauth.server | string | `"http://accounts.fiware.org"` | External URL of the FIWARE IDM used for user authentication |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
