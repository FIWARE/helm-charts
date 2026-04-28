
{{/* vim: set filetype=mustache: */}}
{{/*
tm-forum-api-specific helpers.

Four of the five helpers in this file are now thin wrappers around the
matching `fiwareCommon.*` helper from the `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Any external umbrella chart that already imports e.g.
    `include "tmforum.fullname" .` keeps working — no external
    breaking change.
  * The bodies stay in lock-step with the rest of the FIWARE charts,
    because there is exactly one implementation of each helper (in
    `common`).

The `tmforum` prefix is intentionally different from the chart name
`tm-forum-api` and is preserved as-is (see docs/common-chart.md
"Non-goals: Changing chart prefixes").

`tmforum.labels` is intentionally kept as a chart-local 3-label
subset (helm.sh/chart, app.kubernetes.io/version,
app.kubernetes.io/managed-by) and does NOT delegate to
`fiwareCommon.labels.standard`.

Rationale: `fiwareCommon.labels.standard` emits the canonical 5-label set
(adds `app.kubernetes.io/name` + `app.kubernetes.io/instance`).
tm-forum-api's `templates/deployment.yaml`, `templates/service.yaml`,
`templates/deploy-all-in-one.yaml`, `templates/envoy.yaml`, and
`templates/envoy-service.yaml` already emit
`app.kubernetes.io/name: <fullname>-<api-name>` and
`app.kubernetes.io/instance: <release>` explicitly per-API _and_ then
include `tmforum.labels` immediately after. Switching `tmforum.labels`
to the 5-label set would yield duplicate map keys whose last-wins
semantics would override the per-API name with the chart-level name
and break selector matching across all per-API Deployments. The body
below therefore stays the original 3-label subset, while still
delegating its `helm.sh/chart` line to `fiwareCommon.names.chart` via
`tmforum.chart` (also a wrapper). See docs/common-chart.md
"Consumer-chart migration pattern" for the multi-component caveat.
*/}}

{{/*
Expand the name of the chart. Delegates to `fiwareCommon.names.name`.
*/}}
{{- define "tmforum.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "tmforum.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`fiwareCommon.names.chart`.
*/}}
{{- define "tmforum.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`fiwareCommon.serviceAccount.name`.
*/}}
{{- define "tmforum.serviceAccountName" -}}
{{- include "fiwareCommon.serviceAccount.name" . -}}
{{- end -}}

{{/*
Common labels — chart-local 3-label subset (see top-of-file rationale).
The `helm.sh/chart` value is sourced from `tmforum.chart`, which is a
wrapper around `fiwareCommon.names.chart`, so the canonical chart-and-version
formatting still lives in the `common` library chart.
*/}}
{{- define "tmforum.labels" -}}
helm.sh/chart: {{ include "tmforum.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
