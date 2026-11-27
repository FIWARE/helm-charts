{{/* vim: set filetype=mustache: */}}
{{/*
consent-facade-specific helpers.

Every helper below is a thin wrapper around the matching `fiwareCommon.*`
helper from the `common` library chart, so that there is exactly one
implementation of each across the FIWARE charts. Umbrella charts that
already include `facade.fullname` keep working if the bodies move.
*/}}

{{/*
Expand the name of the chart. Delegates to `fiwareCommon.names.name`.
*/}}
{{- define "facade.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "facade.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`fiwareCommon.names.chart`.
*/}}
{{- define "facade.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`fiwareCommon.serviceAccount.name`.
*/}}
{{- define "facade.serviceAccountName" -}}
{{- include "fiwareCommon.serviceAccount.name" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `fiwareCommon.labels.standard`.
*/}}
{{- define "facade.labels" -}}
{{- include "fiwareCommon.labels.standard" . -}}
{{- end -}}

{{/*
The public base url the facade mints its ids with.

It is written into the contracts, catalog entries and participant
self-descriptions the facade serves, and consumers match participants on
those exact strings - so it must be the address the facade is reachable at
from outside the cluster, not a cluster-internal name. Falls back to the
in-cluster service address, which is only right for a single-cluster
deployment with no external consumer.
*/}}
{{- define "facade.selfUrl" -}}
{{- if .Values.selfUrl -}}
{{- tpl .Values.selfUrl $ -}}
{{- else -}}
{{- printf "http://%s:%v" (include "facade.fullname" .) .Values.service.port -}}
{{- end -}}
{{- end -}}

{{/*
Name of the Secret holding the provider registry's database password.
Delegates to `fiwareCommon.secrets.name`: the map's `name` wins when set,
otherwise the chart's fullname is used.
*/}}
{{- define "facade.databaseSecretName" -}}
{{- include "fiwareCommon.secrets.name" (dict
      "context"        $
      "existingSecret" .Values.providerRegistry.database.existingSecret) -}}
{{- end -}}

{{/*
Key within that Secret. Delegates to `fiwareCommon.secrets.key`.
*/}}
{{- define "facade.databaseSecretKey" -}}
{{- include "fiwareCommon.secrets.key" (dict
      "context"        $
      "existingSecret" .Values.providerRegistry.database.existingSecret
      "defaultKey"     "password") -}}
{{- end -}}
