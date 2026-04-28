
{{/* vim: set filetype=mustache: */}}
{{/*
Orion-specific helpers.

Every helper in this file is now a thin wrapper around the matching
`fiwareCommon.*` helper from the `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Any external umbrella chart that already imports e.g.
    `include "orion.fullname" .` keeps working — no external breaking
    change.
  * The bodies below stay in lock-step with the rest of the FIWARE
    charts, because there is exactly one implementation of each
    helper (in `common`).

*/}}

{{/*
Expand the name of the chart. Delegates to `fiwareCommon.names.name`.
*/}}
{{- define "orion.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "orion.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`fiwareCommon.names.chart`.
*/}}
{{- define "orion.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`fiwareCommon.serviceAccount.name`.
*/}}
{{- define "orion.serviceAccountName" -}}
{{- include "fiwareCommon.serviceAccount.name" . -}}
{{- end -}}

{{/*
Resolve the name of the Secret holding the mongo DB password.
Delegates to `fiwareCommon.secrets.name` with the orion-specific
`.Values.broker.db.existingSecret` key.
*/}}
{{- define "orion.secretName" -}}
{{- include "fiwareCommon.secrets.name" (dict "context" . "existingSecret" .Values.broker.db.existingSecret) -}}
{{- end -}}

{{/*
Resolve the key within the DB secret. Delegates to
`fiwareCommon.secrets.key`; orion's canonical default key is `dbPassword`.
*/}}
{{- define "orion.secretKey" -}}
{{- include "fiwareCommon.secrets.key" (dict "context" . "existingSecret" .Values.broker.db.existingSecret "defaultKey" "dbPassword") -}}
{{- end -}}

{{/*
Common labels. Delegates to `fiwareCommon.labels.standard`.
*/}}
{{- define "orion.labels" -}}
{{- include "fiwareCommon.labels.standard" . -}}
{{- end -}}
