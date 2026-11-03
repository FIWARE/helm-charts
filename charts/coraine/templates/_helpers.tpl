{{/* vim: set filetype=mustache: */}}
{{/*
coraine-specific helpers.

Every helper in this file is a thin wrapper around the matching
`fiwareCommon.*` helper from the `common` library chart (see
charts/common/templates/*.tpl), following the same convention as
charts/orion, charts/mintaka and charts/did-helper.
*/}}

{{/*
Expand the name of the chart. Delegates to `fiwareCommon.names.name`.
*/}}
{{- define "coraine.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "coraine.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`fiwareCommon.names.chart`.
*/}}
{{- define "coraine.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`fiwareCommon.serviceAccount.name`.
*/}}
{{- define "coraine.serviceAccountName" -}}
{{- include "fiwareCommon.serviceAccount.name" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `fiwareCommon.labels.standard`.
*/}}
{{- define "coraine.labels" -}}
{{- include "fiwareCommon.labels.standard" . -}}
{{- end -}}

{{/*
Selector labels. Delegates to `fiwareCommon.labels.matchLabels`.
*/}}
{{- define "coraine.selectorLabels" -}}
{{- include "fiwareCommon.labels.matchLabels" . -}}
{{- end -}}
