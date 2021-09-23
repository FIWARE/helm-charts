# scorpio-broker-aaio

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for Kubernetes in which all the microservices are deployed under a single container and thus less effective for production environment but serves well in testing and dev environment.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` |  choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. If you do want to specify resources, uncomment the following lines, adjust them as necessary, and remove the curly braces after 'resources:'. limits:   cpu: 100m   memory: 128Mi requests:   cpu: 100m   memory: 128Mi |
| autoscaling.enabled | bool | `false` | should autoscaling be enabled       |
| autoscaling.maxReplicas | int | `100` | maximum number of running pods |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | target average CPU utilization over all the pods |
| db.dbhost | string | `"ngb"` | host of the database to be used |
| db.password | string | `"ngb"` | password for connecting the database |
| db.user | string | `"ngb"` | user for connecting the database |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| image.repository | string | `"scorpiobroker/scorpio"` | scorpiobroker image name |
| image.tag | string | `"scorpio-aaio_latest"` | tag of the image to be used |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.enabled | bool | `false` | should there be an ingress to connect scorpio with the public internet       |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[]}]` | all hosts to be provided   |
| ingress.hosts[0] | object | `{"host":"chart-example.local","paths":[]}` | provide a hosts and the paths that should be available     |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` | selector template ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` | initial number of target replications, can be different if autoscaling is enabled |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `9090` | port to be used by the service |
| service.type | string | `"NodePort"` | service type       |
| serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | if a scorpio specific service account should be used, it can be configured here ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| serviceAccount.name | string | `""` |  If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | tolerations template ref: ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |

