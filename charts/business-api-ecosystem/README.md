# business-api-ecosystem

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![AppVersion: 7.6.1](https://img.shields.io/badge/AppVersion-7.6.1-informational?style=flat-square)

A Helm chart for running the FIWARE business API ecosystem (FIWARE Marketplace) on Kubernetes

**Homepage:** <https://business-api-ecosystem.readthedocs.io/en/latest/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| dwendland | dennis.wendland@fiware.org |  |

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
| bizEcosystemApis.deployment.image.tag | string | `"v7.6.0"` |  |
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
| bizEcosystemApis.securityContext.enabled | bool | `false` |  |
| bizEcosystemApis.securityContext.runAsGroup | int | `0` |  |
| bizEcosystemApis.securityContext.runAsUser | int | `0` |  |
| bizEcosystemApis.service.annotations | object | `{}` |  |
| bizEcosystemApis.service.port | int | `8080` |  |
| bizEcosystemApis.service.type | string | `"ClusterIP"` |  |
| bizEcosystemApis.serviceAccount.annotations | object | `{}` |  |
| bizEcosystemApis.serviceAccount.create | bool | `false` |  |
| bizEcosystemApis.serviceAccount.name | string | `"ssc"` |  |
| bizEcosystemChargingBackend.authorizeServicePath | string | `"/authorizeService/apiKeys"` |  |
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
| bizEcosystemChargingBackend.deployment.image.tag | string | `"v7.6.1"` |  |
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
| bizEcosystemChargingBackend.email.mail | string | `"charging@email.com"` |  |
| bizEcosystemChargingBackend.enabled | bool | `true` |  |
| bizEcosystemChargingBackend.fullnameOverride | string | `""` |  |
| bizEcosystemChargingBackend.name | string | `"biz-ecosystem-charging-backend"` |  |
| bizEcosystemChargingBackend.payment.method | string | `"None"` |  |
| bizEcosystemChargingBackend.port | int | `8006` |  |
| bizEcosystemChargingBackend.securityContext.enabled | bool | `false` |  |
| bizEcosystemChargingBackend.securityContext.runAsGroup | int | `0` |  |
| bizEcosystemChargingBackend.securityContext.runAsUser | int | `0` |  |
| bizEcosystemChargingBackend.service.annotations | object | `{}` |  |
| bizEcosystemChargingBackend.service.port | int | `8006` |  |
| bizEcosystemChargingBackend.service.type | string | `"ClusterIP"` |  |
| bizEcosystemChargingBackend.serviceAccount.annotations | object | `{}` |  |
| bizEcosystemChargingBackend.serviceAccount.create | bool | `false` |  |
| bizEcosystemChargingBackend.serviceAccount.name | string | `"ssc"` |  |
| bizEcosystemChargingBackend.verifyRequests | bool | `true` |  |
| bizEcosystemLogicProxy.collectStaticCommand | bool | `true` |  |
| bizEcosystemLogicProxy.db.database | string | `"belp_db"` | Database name for connecting the database |
| bizEcosystemLogicProxy.db.host | string | `"mongo"` | host of the database to be used |
| bizEcosystemLogicProxy.db.password | string | `"pass"` | password for connecting the database |
| bizEcosystemLogicProxy.db.port | int | `27017` | port of the database to be used |
| bizEcosystemLogicProxy.db.user | string | `"root"` | username for connecting the database |
| bizEcosystemLogicProxy.deployment.additionalAnnotations | object | `{}` |  |
| bizEcosystemLogicProxy.deployment.additionalLabels | object | `{}` |  |
| bizEcosystemLogicProxy.deployment.affinity | object | `{}` |  |
| bizEcosystemLogicProxy.deployment.image.pullPolicy | string | `"IfNotPresent"` |  |
| bizEcosystemLogicProxy.deployment.image.repository | string | `"fiware/biz-ecosystem-logic-proxy"` |  |
| bizEcosystemLogicProxy.deployment.image.tag | string | `"v7.6.1"` |  |
| bizEcosystemLogicProxy.deployment.livenessProbe.initialDelaySeconds | int | `11` |  |
| bizEcosystemLogicProxy.deployment.livenessProbe.periodSeconds | int | `30` |  |
| bizEcosystemLogicProxy.deployment.livenessProbe.successThreshold | int | `1` |  |
| bizEcosystemLogicProxy.deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| bizEcosystemLogicProxy.deployment.nodeSelector | object | `{}` |  |
| bizEcosystemLogicProxy.deployment.readinessProbe.initialDelaySeconds | int | `10` |  |
| bizEcosystemLogicProxy.deployment.readinessProbe.periodSeconds | int | `30` |  |
| bizEcosystemLogicProxy.deployment.readinessProbe.successThreshold | int | `1` |  |
| bizEcosystemLogicProxy.deployment.readinessProbe.timeoutSeconds | int | `30` |  |
| bizEcosystemLogicProxy.deployment.replicaCount | int | `1` |  |
| bizEcosystemLogicProxy.deployment.revisionHistoryLimit | int | `3` |  |
| bizEcosystemLogicProxy.deployment.tolerations | list | `[]` |  |
| bizEcosystemLogicProxy.deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` |  |
| bizEcosystemLogicProxy.deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` |  |
| bizEcosystemLogicProxy.deployment.updateStrategy.type | string | `"RollingUpdate"` |  |
| bizEcosystemLogicProxy.enabled | bool | `true` |  |
| bizEcosystemLogicProxy.fullnameOverride | string | `""` |  |
| bizEcosystemLogicProxy.ingress.annotations | object | `{}` | annotations to be added to the ingress |
| bizEcosystemLogicProxy.ingress.enabled | bool | `false` | should there be an ingress to connect the logic proxy with the public internet |
| bizEcosystemLogicProxy.ingress.hosts | list | `[]` |  |
| bizEcosystemLogicProxy.ingress.tls | list | `[]` |  |
| bizEcosystemLogicProxy.name | string | `"biz-ecosystem-logic-proxy"` |  |
| bizEcosystemLogicProxy.nodeEnvironment | string | `"development"` |  |
| bizEcosystemLogicProxy.port | int | `8004` |  |
| bizEcosystemLogicProxy.revenueModel | int | `30` |  |
| bizEcosystemLogicProxy.route.annotations | object | `{}` | annotations to be added to the route |
| bizEcosystemLogicProxy.route.enabled | bool | `false` |  |
| bizEcosystemLogicProxy.route.tls | object | `{}` | host to be used host: localhost -- tls configuration for the route |
| bizEcosystemLogicProxy.securityContext.enabled | bool | `false` |  |
| bizEcosystemLogicProxy.securityContext.runAsGroup | int | `0` |  |
| bizEcosystemLogicProxy.securityContext.runAsUser | int | `0` |  |
| bizEcosystemLogicProxy.service.annotations | object | `{}` |  |
| bizEcosystemLogicProxy.service.port | int | `8004` |  |
| bizEcosystemLogicProxy.service.type | string | `"ClusterIP"` |  |
| bizEcosystemLogicProxy.serviceAccount.annotations | object | `{}` |  |
| bizEcosystemLogicProxy.serviceAccount.create | bool | `false` |  |
| bizEcosystemLogicProxy.serviceAccount.name | string | `"ssc"` |  |
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
| bizEcosystemRss.deployment.image.tag | string | `"v7.6.0"` |  |
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
| bizEcosystemRss.securityContext.enabled | bool | `false` |  |
| bizEcosystemRss.securityContext.runAsGroup | int | `0` |  |
| bizEcosystemRss.securityContext.runAsUser | int | `0` |  |
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
| initContainer.apis.name | string | `"wait-for-apis"` |  |
| initContainer.mongodb.image | string | `"bitnami/mongodb"` |  |
| initContainer.mongodb.imagePullPolicy | string | `"IfNotPresent"` |  |
| initContainer.mongodb.imageTag | string | `"3.6.21"` |  |
| initContainer.mongodb.name | string | `"wait-for-mongodb"` |  |
| initContainer.mysql.image | string | `"mysql"` |  |
| initContainer.mysql.imagePullPolicy | string | `"IfNotPresent"` |  |
| initContainer.mysql.imageTag | string | `"5.7"` |  |
| initContainer.mysql.name | string | `"wait-for-mysql"` |  |
| nameOverride | string | `""` |  |
| oauth.adminrole | string | `"admin"` | Admin role |
| oauth.aggregatorrole | string | `"Aggregator"` | Aggregator role |
| oauth.callbackPath | string | `"/auth/fiware/callback"` | Callback URL path of frontend logic proxy for receiving the access tokens (callback URL would be e.g. externalUrl/auth/fiware/callback) |
| oauth.clientId | string | `"market-clientId"` | OAuth2 Client ID of the BAE application |
| oauth.clientSecret | string | `"market-clientSecret"` | OAuth2 Client Secret of the BAE application |
| oauth.customerrole | string | `"customer"` | Customer role |
| oauth.grantedrole | string | `"admin"` | Granted role |
| oauth.isLegacy | bool | `false` | Whether the used FIWARE IDM is version 6 or lower |
| oauth.orgadminrole | string | `"orgAdmin"` | Role defined in the IDM client app for organization admins of the BAE  |
| oauth.sellerrole | string | `"seller"` | Seller role |
| oauth.server | string | `"http://accounts.fiware.org"` | External URL of the FIWARE IDM used for user authentication |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.4.0](https://github.com/norwoodj/helm-docs/releases/v1.4.0)
