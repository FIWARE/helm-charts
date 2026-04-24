
{{/* vim: set filetype=mustache: */}}
{{/*
Scorpio-broker-aaio-specific helpers.

Every helper in this file is now a thin wrapper around the matching
`common.*` helper from the `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Any external umbrella chart that already imports e.g.
    `include "scorpioBroker-aaio.fullname" .` keeps working — no
    external breaking change.
  * The bodies below stay in lock-step with the rest of the FIWARE
    charts, because there is exactly one implementation of each
    helper (in `common`).

*/}}

{{/*
Expand the name of the chart. Delegates to `common.names.name`.
*/}}
{{- define "scorpioBroker-aaio.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`common.names.fullname`.
*/}}
{{- define "scorpioBroker-aaio.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`common.names.chart`.
*/}}
{{- define "scorpioBroker-aaio.chart" -}}
{{- include "common.names.chart" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `common.labels.standard`.
*/}}
{{- define "scorpioBroker-aaio.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}

{{/*
Selector labels. Delegates to `common.labels.matchLabels`.
*/}}
{{- define "scorpioBroker-aaio.selectorLabels" -}}
{{- include "common.labels.matchLabels" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`common.serviceAccount.name`.
*/}}
{{- define "scorpioBroker-aaio.serviceAccountName" -}}
{{- include "common.serviceAccount.name" . -}}
{{- end -}}

{{/*
Resolve the name of the Secret holding the DB password.

Gated on `.Values.db.existingSecret.enabled` so that the chart's
legacy "enabled bool + default name/key" shape renders byte-identically
to the pre-migration output: when `enabled` is false the helper returns
`<fullname>` regardless of the default `name` / `key` values shipped in
values.yaml. Delegates to `common.secrets.name` only when the user has
explicitly opted into an existing Secret.
*/}}
{{- define "scorpioBroker-aaio.secretName" -}}
{{- if .Values.db.existingSecret.enabled -}}
{{- include "common.secrets.name" (dict "context" . "existingSecret" .Values.db.existingSecret) -}}
{{- else -}}
{{- include "common.names.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Resolve the key within the DB Secret.

Same `enabled`-gating rationale as `scorpioBroker-aaio.secretName`:
when the user has not opted into an existing Secret the helper returns
the canonical default key `password` (matching the key emitted by the
chart's own Secret). Delegates to `common.secrets.key` otherwise.
*/}}
{{- define "scorpioBroker-aaio.passwordKey" -}}
{{- if .Values.db.existingSecret.enabled -}}
{{- include "common.secrets.key" (dict "context" . "existingSecret" .Values.db.existingSecret "defaultKey" "password") -}}
{{- else -}}
{{- "password" -}}
{{- end -}}
{{- end -}}
