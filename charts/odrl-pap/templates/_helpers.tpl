
{{/* vim: set filetype=mustache: */}}
{{/*
odrl-pap-specific helpers.

Every helper in this file is now a thin wrapper around the matching
`fiwareCommon.*` helper from the `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Any external umbrella chart that already imports e.g.
    `include "pap.fullname" .` keeps working — no external
    breaking change.
  * The bodies below stay in lock-step with the rest of the FIWARE
    charts, because there is exactly one implementation of each
    helper (in `common`).

*/}}

{{/*
Expand the name of the chart. Delegates to `fiwareCommon.names.name`.
*/}}
{{- define "pap.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "pap.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`fiwareCommon.names.chart`.
*/}}
{{- define "pap.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`fiwareCommon.serviceAccount.name`.
*/}}
{{- define "pap.serviceAccountName" -}}
{{- include "fiwareCommon.serviceAccount.name" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `fiwareCommon.labels.standard`.
*/}}
{{- define "pap.labels" -}}
{{- include "fiwareCommon.labels.standard" . -}}
{{- end -}}

{{/*
Resolve the name of the database Secret. Delegates to
`fiwareCommon.secrets.name` with odrl-pap's `.Values.database.existingSecret`
key.

odrl-pap follows the DB-flavoured shape (`existingSecret` is a map with
an `enabled` gate plus always-populated `name` / `key` placeholders).
The override is only honoured when `enabled: true`; otherwise the
helper falls back to `<fullname>` for byte-for-byte parity with the
legacy body.
*/}}
{{- define "pap.secretName" -}}
{{- $existing := "" -}}
{{- if .Values.database.existingSecret.enabled -}}
{{- $existing = .Values.database.existingSecret -}}
{{- end -}}
{{- include "fiwareCommon.secrets.name" (dict "context" $ "existingSecret" $existing) -}}
{{- end -}}

{{/*
Resolve the key within the database Secret. Delegates to
`fiwareCommon.secrets.key`, falling back to `password` (the legacy default).
The `enabled` gate is honoured for byte-for-byte parity with the legacy
body — when `enabled: false`, the chart-local default `password` is
returned regardless of any `.Values.database.existingSecret.key` value.
*/}}
{{- define "pap.passwordKey" -}}
{{- $existing := "" -}}
{{- if .Values.database.existingSecret.enabled -}}
{{- $existing = .Values.database.existingSecret -}}
{{- end -}}
{{- include "fiwareCommon.secrets.key" (dict "context" $ "existingSecret" $existing "defaultKey" "password") -}}
{{- end -}}
