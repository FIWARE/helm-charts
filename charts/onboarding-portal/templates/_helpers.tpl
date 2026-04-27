{{/* vim: set filetype=mustache: */}}
{{/*
Onboarding-portal-specific helpers.

Every helper in this file is now a thin wrapper around the matching
`common.*` helper from the `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Any external umbrella chart that already imports e.g.
    `include "onboarding.fullname" .` keeps working — no external
    breaking change.
  * The bodies below stay in lock-step with the rest of the FIWARE
    charts, because there is exactly one implementation of each
    helper (in `common`).

*/}}

{{/*
Expand the name of the chart. Delegates to `common.names.name`.
*/}}
{{- define "onboarding.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`common.names.fullname`.
*/}}
{{- define "onboarding.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`common.names.chart`.
*/}}
{{- define "onboarding.chart" -}}
{{- include "common.names.chart" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `common.labels.standard`.
*/}}
{{- define "onboarding.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}

{{/*
Selector labels. Delegates to `common.labels.matchLabels`.
*/}}
{{- define "onboarding.selectorLabels" -}}
{{- include "common.labels.matchLabels" . -}}
{{- end -}}
