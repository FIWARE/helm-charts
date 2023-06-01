# keyrock

![Version: 0.6.2](https://img.shields.io/badge/Version-0.6.2-informational?style=flat-square) ![AppVersion: 8.3.3](https://img.shields.io/badge/AppVersion-8.3.3-informational?style=flat-square)

A Helm chart for running the fiware idm keyrock on kubernetes.

**Homepage:** <https://fiware-idm.readthedocs.io/en/latest/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| wistefan | <stefan.wiedemann@fiware.org> |  |
| dwendland | <dennis.wendland@fiware.org> |  |

## Source Code

* <https://github.com/ging/fiware-idm>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additonalEnvVars | list | `[]` | a list of additional env vars to be set, check the keyrock docu for all available options ref: https://fiware-idm.readthedocs.io/en/latest/installation_and_administration_guide/environment_variables/index.html |
| admin.email | string | `"admin@admin.org"` | email address of the admin user |
| admin.password | string | `"admin"` | password of the initial admin, leave empty to get a generated one |
| admin.user | string | `"admin"` | username of the initial keyrock admin |
| authorisationRegistry.delegationEndpoint | string | `"https://my-ar.com/delegation"` | Delegation endpoint of AR |
| authorisationRegistry.enabled | bool | `false` | Enable usage of authorisation registry |
| authorisationRegistry.identifier | string | `""` | Identifier (EORI) of AR |
| authorisationRegistry.tokenEndpoint | string | `"https://my-ar.com/connect/token"` | Token endpoint of AR |
| authorisationRegistry.url | string | `"https://my-ar.com"` | URL of AR |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | metrics to react on |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| certs | object | `{"oidcJwtAlgorithm":"HS256","pvc":{"annotations":{},"enabled":false,"size":"1Gi"}}` | use an already existing secret, if provided the other secrets are ignored. Expected keys are dbPassword and adminPassword existingSecret: # Certificates configuration |
| certs.oidcJwtAlgorithm | string | `"HS256"` | Algorithm to firm ID tokens for OIDC |
| certs.pvc.annotations | object | `{}` | Annotations of the PVC for certs/ directory |
| certs.pvc.enabled | bool | `false` | Create PVC mounted at certs/ directory for persistance of HTTPS and application certificates/keys |
| certs.pvc.size | string | `"1Gi"` | Size of the PVC for certs/ directory |
| db.host | string | `"mysql"` | host of the database to be used |
| db.password | string | `"pass"` | password for connecting the database |
| db.user | string | `"root"` | user for connecting the database |
| extraEnvVarsSecret | string | `""` | Name of existing Secret containing extra env vars (in case of sensitive data) |
| fullnameOverride | string | `""` | option to override the fullname config in the _helpers.tpl |
| host | string | `"http://localhost"` | host where keyrock is available at |
| ingress.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.enabled | bool | `false` | should there be an ingress to connect keyrock with the public internet |
| ingress.hosts | list | `[]` | all hosts to be provided |
| ingress.tls | list | `[]` | configure the ingress' tls |
| nameOverride | string | `""` | option to override the name config in the _helpers.tpl |
| port | int | `8080` | port that the keyrock container uses |
| route.enabled | bool | `false` |  |
| route.routes | list | `[{"annotations":{},"certificate":{},"tls":{}}]` | Routes that should be created |
| route.routes[0] | object | `{"annotations":{},"certificate":{},"tls":{}}` | annotations to be added to the route |
| route.routes[0].certificate | object | `{}` | see: https://github.com/FIWARE-Ops/fiware-gitops/blob/master/doc/ROUTES.md |
| route.routes[0].tls | object | `{}` | tls configuration for the route |
| satellite.enabled | bool | `false` | Enable usage of satellite |
| satellite.identifier | string | `""` | Identifier (EORI) of satellite |
| satellite.partiesEndpoint | string | `"https://my-satellite.com/parties"` | Parties endpoint of satellite |
| satellite.tokenEndpoint | string | `"https://my-satellite.com/connect/token"` | Token endpoint of satellite |
| satellite.url | string | `"https://my-satellite.com"` | URL of satellite |
| service.annotations | object | `{}` | addtional annotations, if required |
| service.port | int | `8080` | port to be used by the service |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount | object | `{"create":false}` | if a keyrock specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.create | bool | `false` | specifies if the account should be created |
| statefulset.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| statefulset.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| statefulset.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| statefulset.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| statefulset.image.repository | string | `"fiware/idm"` | keyrock image name ref: https://hub.docker.com/r/fiware/idm |
| statefulset.image.tag | string | `"8.3.0"` | tag of the image to be used |
| statefulset.livenessProbe.initialDelaySeconds | int | `30` |  |
| statefulset.livenessProbe.periodSeconds | int | `10` |  |
| statefulset.livenessProbe.successThreshold | int | `1` |  |
| statefulset.livenessProbe.timeoutSeconds | int | `30` |  |
| statefulset.nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| statefulset.readinessProbe.initialDelaySeconds | int | `31` |  |
| statefulset.readinessProbe.periodSeconds | int | `10` |  |
| statefulset.readinessProbe.successThreshold | int | `1` |  |
| statefulset.readinessProbe.timeoutSeconds | int | `30` |  |
| statefulset.replicaCount | int | `1` | initial number of target replications, can be different if autoscaling is enabled |
| statefulset.revisionHistoryLimit | int | `3` | number of old replicas to be retained |
| statefulset.startupProbe.failureThreshold | int | `5` |  |
| statefulset.startupProbe.initialDelaySeconds | int | `5` |  |
| statefulset.startupProbe.periodSeconds | int | `5` |  |
| statefulset.startupProbe.timeoutSeconds | int | `30` |  |
| statefulset.tolerations | list | `[]` | tolerations template ref: ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| statefulset.updateStrategy.type | string | `"RollingUpdate"` | type of the update |
| theme.enabled | bool | `false` | Enable theme |
| theme.image | string | `"my-theme-image:latest"` | Image which holds the theme files |
| theme.imagePullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| theme.mountFavicon | string | `"/opt/fiware-idm/public/favicon.ico"` | Mount path for the source favicon |
| theme.mountFonts | string | `"/opt/fiware-idm/public/fonts/my-fonts"` | Mount path for the source fonts files |
| theme.mountImg | string | `"/opt/fiware-idm/public/img/my-theme"` | Mount path for the source image files |
| theme.mountJavascript | string | `"/opt/fiware-idm/public/javascripts/my-theme"` | Mount path for the source javascript files |
| theme.mountTheme | string | `"/opt/fiware-idm/themes/my-theme"` | Mount path for the source theme files |
| theme.name | string | `"default"` | Name of the theme |
| theme.sourceImg | string | `"/img/my-theme"` | Path to the source image files inside the container |
| theme.sourceTheme | string | `"/themes/my-theme"` | Path to the source theme files inside the container |
| token.cert | string | `""` | String with certificate (chain) in PEM format |
| token.enabled | bool | `false` | Enable storage of local key and certificate |
| token.identifier | string | `""` | Identifier (EORI) of local organisation |
| token.key | string | `""` | String with private key in PEM format |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
