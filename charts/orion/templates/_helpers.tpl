
{{/* vim: set filetype=mustache: */}}
{{/*
Orion-specific helpers.

Every helper in this file is now a thin wrapper around the matching
`common.*` helper from the `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Any external umbrella chart that already imports e.g.
    `include "orion.fullname" .` keeps working — no external breaking
    change.
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
{{- define "orion.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`common.names.fullname`.
*/}}
{{- define "orion.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`common.names.chart`.
*/}}
{{- define "orion.chart" -}}
{{- include "common.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`common.serviceAccount.name`.
*/}}
{{- define "orion.serviceAccountName" -}}
{{- include "common.serviceAccount.name" . -}}
{{- end -}}

{{/*
Resolve the name of the Secret holding the mongo DB password.
Delegates to `common.secrets.name` with the orion-specific
`.Values.broker.db.existingSecret` key.
*/}}
{{- define "orion.secretName" -}}
{{- include "common.secrets.name" (dict "context" . "existingSecret" .Values.broker.db.existingSecret) -}}
{{- end -}}

{{/*
Resolve the key within the DB secret. Delegates to
`common.secrets.key`; orion's canonical default key is `dbPassword`.
*/}}
{{- define "orion.secretKey" -}}
{{- include "common.secrets.key" (dict "context" . "existingSecret" .Values.broker.db.existingSecret "defaultKey" "dbPassword") -}}
{{- end -}}

{{/*
Common labels. Delegates to `common.labels.standard`.
*/}}
{{- define "orion.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}
