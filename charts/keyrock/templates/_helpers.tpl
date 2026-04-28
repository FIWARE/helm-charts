
{{/* vim: set filetype=mustache: */}}
{{/*
Keyrock-specific helpers.

Every helper in this file is now a thin wrapper around the matching
`fiwareCommon.*` helper from the `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Any external umbrella chart that already imports e.g.
    `include "keyrock.fullname" .` keeps working — no external
    breaking change.
  * The bodies below stay in lock-step with the rest of the FIWARE
    charts, because there is exactly one implementation of each
    helper (in `common`).

*/}}

{{/*
Expand the name of the chart. Delegates to `fiwareCommon.names.name`.
*/}}
{{- define "keyrock.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "keyrock.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`fiwareCommon.names.chart`.
*/}}
{{- define "keyrock.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`fiwareCommon.serviceAccount.name`.
*/}}
{{- define "keyrock.serviceAccountName" -}}
{{- include "fiwareCommon.serviceAccount.name" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `fiwareCommon.labels.standard`.
*/}}
{{- define "keyrock.labels" -}}
{{- include "fiwareCommon.labels.standard" . -}}
{{- end -}}

{{/*
Resolve the name of the credentials Secret. Delegates to
`fiwareCommon.secrets.name` with keyrock's `.Values.existingSecret` key.
*/}}
{{- define "keyrock.secretName" -}}
{{- include "fiwareCommon.secrets.name" (dict "context" . "existingSecret" .Values.existingSecret) -}}
{{- end -}}

{{/*
Resolve the name of the certificate Secret. Delegates to
`fiwareCommon.secrets.name` with keyrock's `.Values.existingCertSecret`
key and the `-certs` fallback suffix.
*/}}
{{- define "keyrock.certSecretName" -}}
{{- include "fiwareCommon.secrets.name" (dict "context" . "existingSecret" .Values.existingCertSecret "suffix" "-certs") -}}
{{- end -}}
