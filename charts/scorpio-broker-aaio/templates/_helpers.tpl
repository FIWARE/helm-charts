
{{/* vim: set filetype=mustache: */}}
{{/*
Scorpio-broker-aaio-specific helpers.

Every helper in this file is now a thin wrapper around the matching
`fiwareCommon.*` helper from the `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Any external umbrella chart that already imports e.g.
    `include "scorpioBroker-aaio.fullname" .` keeps working — no
    external breaking change.
  * The bodies below stay in lock-step with the rest of the FIWARE
    charts, because there is exactly one implementation of each
    helper (in `common`).

*/}}

{{/*
Expand the name of the chart. Delegates to `fiwareCommon.names.name`.
*/}}
{{- define "scorpioBroker-aaio.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "scorpioBroker-aaio.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`fiwareCommon.names.chart`.
*/}}
{{- define "scorpioBroker-aaio.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `fiwareCommon.labels.standard`.
*/}}
{{- define "scorpioBroker-aaio.labels" -}}
{{- include "fiwareCommon.labels.standard" . -}}
{{- end -}}

{{/*
Selector labels. Delegates to `fiwareCommon.labels.matchLabels`.
*/}}
{{- define "scorpioBroker-aaio.selectorLabels" -}}
{{- include "fiwareCommon.labels.matchLabels" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`fiwareCommon.serviceAccount.name`.
*/}}
{{- define "scorpioBroker-aaio.serviceAccountName" -}}
{{- include "fiwareCommon.serviceAccount.name" . -}}
{{- end -}}

{{/*
Resolve the name of the Secret holding the DB password.

Gated on `.Values.db.existingSecret.enabled` so that the chart's
legacy "enabled bool + default name/key" shape renders byte-identically
to the pre-migration output: when `enabled` is false the helper returns
`<fullname>` regardless of the default `name` / `key` values shipped in
values.yaml. Delegates to `fiwareCommon.secrets.name` only when the user has
explicitly opted into an existing Secret.
*/}}
{{- define "scorpioBroker-aaio.secretName" -}}
{{- if .Values.db.existingSecret.enabled -}}
{{- include "fiwareCommon.secrets.name" (dict "context" . "existingSecret" .Values.db.existingSecret) -}}
{{- else -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Resolve the key within the DB Secret.

Same `enabled`-gating rationale as `scorpioBroker-aaio.secretName`:
when the user has not opted into an existing Secret the helper returns
the canonical default key `password` (matching the key emitted by the
chart's own Secret). Delegates to `fiwareCommon.secrets.key` otherwise.
*/}}
{{- define "scorpioBroker-aaio.passwordKey" -}}
{{- if .Values.db.existingSecret.enabled -}}
{{- include "fiwareCommon.secrets.key" (dict "context" . "existingSecret" .Values.db.existingSecret "defaultKey" "password") -}}
{{- else -}}
{{- "password" -}}
{{- end -}}
{{- end -}}
