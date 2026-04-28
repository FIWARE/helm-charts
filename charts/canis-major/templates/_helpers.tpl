
{{/* vim: set filetype=mustache: */}}
{{/*
Canis-major-specific helpers.

Every helper in this file is now a thin wrapper around the matching
`fiwareCommon.*` helper from the `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Any external umbrella chart that already imports e.g.
    `include "canis-major.fullname" .` keeps working — no external
    breaking change.
  * The bodies below stay in lock-step with the rest of the FIWARE
    charts, because there is exactly one implementation of each
    helper (in `common`).

See docs/common-chart.md for the migration rationale and the
planned deprecation window. Removal of the wrappers is scheduled as a
future major version bump (see charts/common/DEPRECATIONS.md).
*/}}

{{/*
Expand the name of the chart. Delegates to `fiwareCommon.names.name`.
*/}}
{{- define "canis-major.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "canis-major.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`fiwareCommon.names.chart`.
*/}}
{{- define "canis-major.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`fiwareCommon.serviceAccount.name`.
*/}}
{{- define "canis-major.serviceAccountName" -}}
{{- include "fiwareCommon.serviceAccount.name" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `fiwareCommon.labels.standard`.
*/}}
{{- define "canis-major.labels" -}}
{{- include "fiwareCommon.labels.standard" . -}}
{{- end -}}

{{/*
Resolve the name of the Secret that stores the default-account private
key. Delegates to `fiwareCommon.secrets.name`, which handles the keyrock-style
`.Values.existingSecret` (bare string) form used by canis-major as well
as the orion-style map form.
*/}}
{{- define "canis-major.secretName" -}}
{{- include "fiwareCommon.secrets.name" (dict "context" . "existingSecret" .Values.existingSecret) -}}
{{- end -}}
