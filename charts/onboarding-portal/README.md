# onboarding-portal

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

A Helm chart for the OnBoarding Portal

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Miguel Ortega | <miguel.ortega@seamware.com> |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules for pod scheduling |
| config | object | `{"app":{"documentToSignUrl":"","keycloak":{"auth":{"clientId":"admin-cli","grantType":"password","password":"${APP_KEYCLOAK_PASSWORD}","username":"${APP_KEYCLOAK_USERNAME}"},"baseUrl":""},"login":{"clientId":"${APP_CLIENT_ID}","clientSecret":"${APP_CLIENT_SECRET}","codeChallenge":true,"openIdUrl":"","scope":"openid"},"tir":{"url":""}},"database":{"database":"","host":"","logging":false,"password":"${APP_DB_PASSWORD}","port":5432,"synchronize":true,"type":"postgres","username":"${APP_DB_USERNAME}"},"email":{"enabled":false,"type":"nodemailer"},"logging":{"level":"info"},"server":{"cors":{"allowedHeaders":["Content-Type","Authorization","X-Organization"],"credentials":true,"maxAge":600,"methods":["GET","POST","PUT","DELETE","OPTIONS"],"optionsSuccessStatus":204,"origin":"*"},"port":8080,"storage":{"destFolder":"files","maxSizeMB":5}}}` | Internal application configuration |
| config.app.documentToSignUrl | string | `""` | URL that contains the pdf to be signed |
| config.app.keycloak.auth | object | `{"clientId":"admin-cli","grantType":"password","password":"${APP_KEYCLOAK_PASSWORD}","username":"${APP_KEYCLOAK_USERNAME}"}` | Authentication information needed to create new realms |
| config.app.keycloak.baseUrl | string | `""` | URL of the keycloak where new realms will be created |
| config.app.login.clientId | string | `"${APP_CLIENT_ID}"` | ClientId of the OpenID server |
| config.app.login.clientSecret | string | `"${APP_CLIENT_SECRET}"` | ClientSecret of the OpenID server |
| config.app.login.codeChallenge | bool | `true` | Type of codeChallenge |
| config.app.login.openIdUrl | string | `""` | URL of the OpenID server (e.g: keycloak) |
| config.app.login.scope | string | `"openid"` | Scopes required in the openid request |
| config.app.tir | object | `{"url":""}` | Trust Issuer Register where DID's will be registered |
| config.database | object | `{"database":"","host":"","logging":false,"password":"${APP_DB_PASSWORD}","port":5432,"synchronize":true,"type":"postgres","username":"${APP_DB_USERNAME}"}` | Database configuration. See [TypeORM documentation](https://typeorm.io/docs/data-source/data-source-options) |
| config.email | object | `{"enabled":false,"type":"nodemailer"}` | Email configuration using [Nodemailer](https://nodemailer.com/) |
| config.server.cors | object | `{"allowedHeaders":["Content-Type","Authorization","X-Organization"],"credentials":true,"maxAge":600,"methods":["GET","POST","PUT","DELETE","OPTIONS"],"optionsSuccessStatus":204,"origin":"*"}` | CORS configuration |
| config.server.port | int | `8080` | Server running port |
| config.server.storage.destFolder | string | `"files"` | Local folder to store pdf |
| config.server.storage.maxSizeMB | int | `5` | Max pdf file size |
| extraEnvVars | list | `[]` | Extra environment variables to pass to the container |
| fullnameOverride | string | `""` | String to fully override the chart name |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"seamware/onboarding"` | Repository for the application image |
| image.tag | string | `""` | Overrides the image tag (defaults to appVersion in Chart.yaml) |
| imagePullSecrets | list | `[]` | Image pull secrets for private repositories |
| ingress.annotations | object | `{"nginx.ingress.kubernetes.io/proxy-body-size":"8m","nginx.ingress.kubernetes.io/proxy-buffer-size":"16k"}` | Ingress annotations |
| ingress.className | string | `""` | Ingress class name |
| ingress.enabled | bool | `false` | Enable ingress resource |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | Ingress host configuration |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| livenessProbe | object | `{"httpGet":{"path":"/health/live","port":"http"}}` | Liveness probe configuration |
| nameOverride | string | `""` | String to partially override the chart name |
| nodeSelector | object | `{}` | Node selector for pod scheduling |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Access modes for the PVC |
| persistence.annotations | object | `{}` | Annotations for the PVC |
| persistence.create | bool | `false` | Create a new PVC |
| persistence.enabled | bool | `false` | Enable persistence using PVC |
| persistence.existingClaim | string | `""` | Existing PVC to use |
| persistence.size | string | `"1Gi"` | Size of the PVC |
| persistence.storageClass | string | `""` | Storage class for the PVC |
| podAnnotations | object | `{}` | Annotations to add to the pod |
| podLabels | object | `{}` | Labels to add to the pod |
| podSecurityContext | object | `{}` | Pod-level security context |
| readinessProbe | object | `{"httpGet":{"path":"/health/ready","port":"http"}}` | Readiness probe configuration |
| replicaCount | int | `1` | Number of replicas for the deployment |
| resources | object | `{}` | Resource limits and requests for the pod |
| secrets | object | `{"database":{"passwordKey":"","secretName":"","usernameKey":""},"keycloak":{"passwordKey":"","secretName":"","usernameKey":""},"login":{"clientIdKey":"","clientSecretKey":"","secretName":""}}` | External secrets mapping configuration |
| secrets.database | object | `{"passwordKey":"","secretName":"","usernameKey":""}` | Database secrets |
| secrets.keycloak | object | `{"passwordKey":"","secretName":"","usernameKey":""}` | Onboarding keycloak secrets |
| secrets.login | object | `{"clientIdKey":"","clientSecretKey":"","secretName":""}` | Admin login secrets |
| securityContext | object | `{}` | Container-level security context |
| service.port | int | `80` | Service port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type |
| tolerations | list | `[]` | Tolerations for pod scheduling |
| volumeMounts | list | `[]` | Additional volume mounts |
| volumes | list | `[]` | Additional volumes to mount |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
