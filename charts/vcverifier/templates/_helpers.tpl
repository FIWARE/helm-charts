
{{/* vim: set filetype=mustache: */}}
{{/*
VCVerifier-specific helpers.

Every helper in this file is now a thin wrapper around the matching
`common.*` helper from the `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Any external umbrella chart that already imports e.g.
    `include "vcverifier.fullname" .` keeps working — no external
    breaking change.
  * The bodies below stay in lock-step with the rest of the FIWARE
    charts, because there is exactly one implementation of each
    helper (in `common`).

*/}}

{{/*
Expand the name of the chart. Delegates to `common.names.name`.
*/}}
{{- define "vcverifier.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`common.names.fullname`.
*/}}
{{- define "vcverifier.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`common.names.chart`.
*/}}
{{- define "vcverifier.chart" -}}
{{- include "common.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`common.serviceAccount.name`.
*/}}
{{- define "vcverifier.serviceAccountName" -}}
{{- include "common.serviceAccount.name" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `common.labels.standard`.
*/}}
{{- define "vcverifier.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}
