
{{/* vim: set filetype=mustache: */}}
{{/*
Keyrock-specific helpers.

Every helper in this file is now a thin wrapper around the matching
`common.*` helper from the `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Any external umbrella chart that already imports e.g.
    `include "keyrock.fullname" .` keeps working — no external
    breaking change.
  * The bodies below stay in lock-step with the rest of the FIWARE
    charts, because there is exactly one implementation of each
    helper (in `common`).

See docs/common-chart-proposal.md for the migration rationale and the
planned deprecation window. Removal of the wrappers is scheduled as a
future major version bump (see charts/common/DEPRECATIONS.md in Step
11 of the plan).
*/}}

{{/*
Expand the name of the chart. Delegates to `common.names.name`.
*/}}
{{- define "keyrock.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`common.names.fullname`.
*/}}
{{- define "keyrock.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`common.names.chart`.
*/}}
{{- define "keyrock.chart" -}}
{{- include "common.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`common.serviceAccount.name`.
*/}}
{{- define "keyrock.serviceAccountName" -}}
{{- include "common.serviceAccount.name" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `common.labels.standard`.
*/}}
{{- define "keyrock.labels" -}}
{{ include "common.labels.standard" . }}
{{- end -}}

{{/*
Resolve the name of the credentials Secret. Delegates to
`common.secrets.name` with keyrock's `.Values.existingSecret` key.
*/}}
{{- define "keyrock.secretName" -}}
{{- include "common.secrets.name" (dict "context" . "existingSecret" .Values.existingSecret) -}}
{{- end -}}

{{/*
Resolve the name of the certificate Secret. Delegates to
`common.secrets.name` with keyrock's `.Values.existingCertSecret`
key and the `-certs` fallback suffix.
*/}}
{{- define "keyrock.certSecretName" -}}
{{- include "common.secrets.name" (dict "context" . "existingSecret" .Values.existingCertSecret "suffix" "-certs") -}}
{{- end -}}
