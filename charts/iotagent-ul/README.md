# iotagent-ul

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![AppVersion: 1.14.0](https://img.shields.io/badge/AppVersion-1.14.0-informational?style=flat-square)

A Helm chart for running the fiware iot agent for the ultralight 2.0 protocol on kubernetes.

**Homepage:** <https://fiware-iotagent-ul.readthedocs.io/en/latest/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| wistefan | stefan.wiedemann@fiware.org |  |

## Source Code

* <https://github.com/telefonicaid/iotagent-ul>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaling.enabled | bool | `false` | should autoscaling be enabled |
| autoscaling.maxReplicas | int | `10` | maximum number of running pods |
| autoscaling.metrics | list | `[]` | metrics to react on |
| autoscaling.minReplicas | int | `1` | minimum number of running pods |
| deployment.additionalAnnotations | object | `{}` | additional annotations for the deployment, if required |
| deployment.additionalLabels | object | `{}` | additional labels for the deployment, if required |
| deployment.affinity | object | `{}` | affinity template ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| deployment.amqpPort | int | `5672` | port to be used by the service for amqp communication |
| deployment.httpNorthPort | int | `4061` | port to be used by the service for northBound communication |
| deployment.httpSouthPort | int | `7896` | port to be used by the service for southBound communication |
| deployment.image.pullPolicy | string | `"IfNotPresent"` | specification of the image pull policy |
| deployment.image.repository | string | `"fiware/iotagent-ul"` | iotagent image name ref: https://hub.docker.com/r/fiware/iotagent-ul/ |
| deployment.image.tag | string | `"1.14.0"` | tag of the image to be used |
| deployment.livenessProbe.initialDelaySeconds | int | `30` |  |
| deployment.livenessProbe.periodSeconds | int | `10` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| deployment.mqttPort | int | `1883` | port to be used by the service for mqtt communication |
| deployment.nodeSelector | object | `{}` |  |
| deployment.readinessProbe.initialDelaySeconds | int | `30` |  |
| deployment.readinessProbe.periodSeconds | int | `10` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.timeoutSeconds | int | `31` |  |
| deployment.replicaCount | int | `1` | initial number of target replications, can be different if autoscaling is enabled |
| deployment.resources | object | `{}` | iotagent resource requests and limits, we leave the default empty to make that a concious choice by the user. for the autoscaling to make sense, you should configure this. |
| deployment.revisionHistoryLimit | int | `3` | number of old replicas to be retained |
| deployment.tolerations | list | `[]` | tolerations template ref: ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| deployment.updateStrategy | object | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` | configuration of the iotagent update strategy |
| deployment.updateStrategy.rollingUpdate | object | `{"maxSurge":1,"maxUnavailable":0}` | new pods will be added gradually |
| deployment.updateStrategy.rollingUpdate.maxSurge | int | `1` | number of pods that can be created above the desired amount while updating |
| deployment.updateStrategy.rollingUpdate.maxUnavailable | int | `0` | number of pods that can be unavailable while updating |
| deployment.updateStrategy.type | string | `"RollingUpdate"` | type of the update |
| deviceRegistry.type | string | `"memory"` | type of the registry, currently 'memory'(wiped on restart) and 'mongodb' are supported |
| fullnameOverride | string | `""` |  |
| http.timeout | int | `1000` | Timeout for the http command endpoint (in milliseconds) |
| ingress.amqp | object | `{"annotations":{},"enabled":false,"hosts":[],"tls":[]}` | configuration for the amqp ingress |
| ingress.amqp.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.amqp.enabled | bool | `false` | should there be an ingress to connect iotagent with the public internet |
| ingress.httpNorth | object | `{"annotations":null,"enabled":true,"hosts":null,"tls":[]}` | configuration for the north bound http ingress |
| ingress.httpNorth.annotations | string | `nil` | annotations to be added to the ingress |
| ingress.httpNorth.enabled | bool | `true` | should there be an ingress to connect iotagent with the public internet |
| ingress.httpSouth | object | `{"annotations":{},"enabled":true,"hosts":[],"tls":[]}` | configuration for the south bound http ingress |
| ingress.httpSouth.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.httpSouth.enabled | bool | `true` | should there be an ingress to connect iotagent with the public internet |
| ingress.mqtt | object | `{"annotations":{},"enabled":false,"hosts":[],"tls":[]}` | configuration for the mqtt ingress |
| ingress.mqtt.annotations | object | `{}` | annotations to be added to the ingress |
| ingress.mqtt.enabled | bool | `false` | should there be an ingress to connect iotagent with the public internet |
| iota.configRetrieval | bool | `false` | indicating whether the incoming notifications to the IoTAgent should be processed using the bidirectionality plugin from the latest versions of the library or the UL-specific configuration retrieval mechanism. |
| iota.contextBroker | object | `{"host":"orion","port":1026}` | contextbroker to be used with the agent |
| iota.contextBroker.host | string | `"orion"` | host of the broker |
| iota.contextBroker.port | int | `1026` | port of the broker |
| iota.defaultKey | string | `"TEF"` | Default API Key, to use with device that have been provisioned without a Configuration Group. |
| iota.defaultTransport | string | `"HTTP"` | Default transport protocol when no transport is provisioned through the Device Provisioning API. |
| iota.defaultType | string | `"Thing"` | Default type, for IoT Agent installations that won't require preregistration. |
| iota.deviceRegistrationDuration | string | `"P20Y"` | Default maximum expire date for device registrations |
| iota.explicitAttributes | bool | `false` | whether the incoming measures to the IoTAgent should be processed as per the "attributes" field. |
| iota.logLevel | string | `"DEBUG"` | Configures the log level. Appropriate values are: FATAL, ERROR, INFO, WARN and DEBUG. |
| iota.providerUrl | string | `"http://localhost:4061"` | URL Where the IoT Agent Will listen for incoming updateContext and queryContext requests |
| iota.service | string | `"howtoService"` |  |
| iota.subservice | string | `"/howto"` | Default subservice, for IoT Agent installations that won't require preregistration. |
| iota.timestamp | bool | `true` | should a timestamp be added to every entity, metadata and attributecreated |
| nameOverride | string | `""` |  |
| service.amqpPort | int | `5672` | port to be used by the service for amqp communication |
| service.annotations | object | `{}` | addtional annotations, if required |
| service.httpNorthPort | int | `4061` | port to be used by the service for northBound communication |
| service.httpSouthPort | int | `7896` | port to be used by the service for southBound communication |
| service.mqttPort | int | `1883` | port to be used by the service for mqtt communication |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount.create | bool | `false` | specifies if the account should be created |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.4.0](https://github.com/norwoodj/helm-docs/releases/v1.4.0)
