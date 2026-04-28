
{{/* vim: set filetype=mustache: */}}
{{/*
contract-management-specific helpers.

The five core helpers in this file are now thin wrappers around the
matching `fiwareCommon.*` helper from the `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Any external umbrella chart that already imports e.g.
    `include "contract.fullname" .` keeps working — no external
    breaking change.
  * The bodies below stay in lock-step with the rest of the FIWARE
    charts, because there is exactly one implementation of each
    helper (in `common`).

See docs/common-chart-proposal.md for the migration rationale and the
planned deprecation window. Removal of the wrappers is scheduled as a
future major version bump (see charts/common/DEPRECATIONS.md).

The `contract.secretName` / `contract.passwordKey` helpers below use a
chart-specific `.Values.database.existingSecret.enabled` gate that is
not expressible in `fiwareCommon.secrets.name` / `fiwareCommon.secrets.key` (the
library helpers use a truthy-`existingSecret` gate instead). They are
retained verbatim for backwards compatibility with any external caller
that already relies on this shape.
*/}}

{{/*
Expand the name of the chart. Delegates to `fiwareCommon.names.name`.
*/}}
{{- define "contract.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "contract.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`fiwareCommon.names.chart`.
*/}}
{{- define "contract.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`fiwareCommon.serviceAccount.name`.
*/}}
{{- define "contract.serviceAccountName" -}}
{{- include "fiwareCommon.serviceAccount.name" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `fiwareCommon.labels.standard`.
*/}}
{{- define "contract.labels" -}}
{{- include "fiwareCommon.labels.standard" . -}}
{{- end -}}

{{/*
Support for an existing database secret. Preserved verbatim from the
pre-migration helper because it uses a chart-specific `.enabled` gate
(not supported by `fiwareCommon.secrets.name`, which treats any truthy
`existingSecret` value as "override active").
*/}}
{{- define "contract.secretName" -}}
    {{- if .Values.database.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.database.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "contract.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "contract.passwordKey" -}}
    {{- if and (.Values.database.existingSecret.enabled) (.Values.database.existingSecret.key) -}}
        {{- printf "%s" (tpl .Values.database.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}
