
{{/* vim: set filetype=mustache: */}}
{{/*
fdsc-dashboard-specific helpers.

Every name/label helper is a thin wrapper around the matching
`fiwareCommon.*` helper from the in-repo `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Consumer umbrella charts that already `include "fdsc-dashboard.name" .`
    keep working — no external breaking change.
  * The bodies stay in lock-step with the rest of the FIWARE charts,
    because there is exactly one implementation of each helper in
    `common`.
*/}}

{{/*
Expand the name of the chart. Delegates to `fiwareCommon.names.name`.
*/}}
{{- define "fdsc-dashboard.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "fdsc-dashboard.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`fiwareCommon.names.chart`.
*/}}
{{- define "fdsc-dashboard.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`fiwareCommon.serviceAccount.name`.
*/}}
{{- define "fdsc-dashboard.serviceAccountName" -}}
{{- include "fiwareCommon.serviceAccount.name" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `fiwareCommon.labels.standard`.
*/}}
{{- define "fdsc-dashboard.labels" -}}
{{- include "fiwareCommon.labels.standard" . -}}
{{- end -}}

{{/*
Resolve the name of the Secret holding the runtime `AUTH_CONFIG_JSON`
OIDC providers blob.

When `.Values.auth.existingSecret` is set the resolved value is that
user-supplied string; otherwise the helper falls back to the chart
fullname (the Secret rendered by `templates/secret.yaml`). Delegates to
`fiwareCommon.secrets.name`.
*/}}
{{- define "fdsc-dashboard.authSecretName" -}}
{{- include "fiwareCommon.secrets.name" (dict
      "context"        .
      "existingSecret" .Values.auth.existingSecret) -}}
{{- end -}}
