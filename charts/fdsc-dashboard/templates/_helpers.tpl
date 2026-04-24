
{{/* vim: set filetype=mustache: */}}
{{/*
fdsc-dashboard-specific helpers.

Every name/label helper is a thin wrapper around the matching
`common.*` helper from the in-repo `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Consumer umbrella charts that already `include "fdsc-dashboard.name" .`
    keep working — no external breaking change.
  * The bodies stay in lock-step with the rest of the FIWARE charts,
    because there is exactly one implementation of each helper in
    `common`.
*/}}

{{/*
Expand the name of the chart. Delegates to `common.names.name`.
*/}}
{{- define "fdsc-dashboard.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`common.names.fullname`.
*/}}
{{- define "fdsc-dashboard.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`common.names.chart`.
*/}}
{{- define "fdsc-dashboard.chart" -}}
{{- include "common.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`common.serviceAccount.name`.
*/}}
{{- define "fdsc-dashboard.serviceAccountName" -}}
{{- include "common.serviceAccount.name" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `common.labels.standard`.
*/}}
{{- define "fdsc-dashboard.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}

{{/*
Resolve the name of the Secret holding the runtime `AUTH_CONFIG_JSON`
OIDC providers blob.

When `.Values.auth.existingSecret` is set the resolved value is that
user-supplied string; otherwise the helper falls back to the chart
fullname (the Secret rendered by `templates/secret.yaml`). Delegates to
`common.secrets.name`.
*/}}
{{- define "fdsc-dashboard.authSecretName" -}}
{{- include "common.secrets.name" (dict
      "context"        .
      "existingSecret" .Values.auth.existingSecret) -}}
{{- end -}}
