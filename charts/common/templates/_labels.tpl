{{/* vim: set filetype=mustache: */}}
{{/*
Label helpers for the FIWARE `common` library chart.

Reproduces the label fragments currently copied into every chart's
`_helpers.tpl` and inlined in several `service.yaml` / `deployment.yaml`
files. Rendered output is byte-identical to the canonical `<chart>.labels`
helper (see charts/orion/templates/_helpers.tpl) when called with the
root context or a dict form with an empty `component`.

Call styles — like the name helpers in _names.tpl:

  {{- include "common.labels.standard" . }}

  {{- include "common.labels.standard" (dict "context" $ "component" "db") }}

When a `component` is supplied the optional `app.kubernetes.io/component`
line is appended to the existing 5-label set (respectively to the
2-label match-labels set). This variant is used by scorpio-broker in
Step 10 and is additive — single-component charts that keep calling
with the root context render exactly the same YAML they do today.
*/}}

{{/*
common.labels.standard

The full 5-label set used on `metadata.labels:` across FIWARE charts:

  app.kubernetes.io/name: <chart-name>
  helm.sh/chart:          <chart-name>-<chart-version>
  app.kubernetes.io/instance: <release-name>
  app.kubernetes.io/version: "<app-version>"   # only if Chart.AppVersion
  app.kubernetes.io/managed-by: <release-service>

When called via the dict form with a non-empty `component`, an extra

  app.kubernetes.io/component: <component>

line is appended.
*/}}
{{- define "common.labels.standard" -}}
{{- $ctx := . -}}
{{- $component := "" -}}
{{- if and (kindIs "map" .) (hasKey . "context") -}}
{{- $ctx = .context -}}
{{- $component = default "" .component -}}
{{- end -}}
app.kubernetes.io/name: {{ include "common.names.name" (dict "context" $ctx "component" $component) }}
helm.sh/chart: {{ include "common.names.chart" (dict "context" $ctx) }}
app.kubernetes.io/instance: {{ $ctx.Release.Name }}
{{- if $ctx.Chart.AppVersion }}
app.kubernetes.io/version: {{ $ctx.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $ctx.Release.Service }}
{{- if $component }}
app.kubernetes.io/component: {{ $component }}
{{- end }}
{{- end -}}

{{/*
common.labels.matchLabels

The 2-label selector set used on `spec.selector.matchLabels:` and on
service selectors across FIWARE charts:

  app.kubernetes.io/name: <chart-name>
  app.kubernetes.io/instance: <release-name>

When called via the dict form with a non-empty `component`, an extra

  app.kubernetes.io/component: <component>

line is appended. Match-label stability (selectors cannot change after
a release is installed) means consumer charts should only start
passing `component` on a fresh release.
*/}}
{{- define "common.labels.matchLabels" -}}
{{- $ctx := . -}}
{{- $component := "" -}}
{{- if and (kindIs "map" .) (hasKey . "context") -}}
{{- $ctx = .context -}}
{{- $component = default "" .component -}}
{{- end -}}
app.kubernetes.io/name: {{ include "common.names.name" (dict "context" $ctx "component" $component) }}
app.kubernetes.io/instance: {{ $ctx.Release.Name }}
{{- if $component }}
app.kubernetes.io/component: {{ $component }}
{{- end }}
{{- end -}}
