{{/* vim: set filetype=mustache: */}}
{{/*
Name helpers for the FIWARE `common` library chart.

Every helper is designed to reproduce the body of the matching helper
currently copied into each consumer chart's `templates/_helpers.tpl`,
byte-for-byte. A consumer chart's wrapper (`<chart>.name`,
`<chart>.fullname`, …) can delegate to the `common.*` helper without
changing any rendered manifest.

Argument convention: helpers accept either

  * the root context (`.`) directly — identical to how the existing
    `<chart>.*` helpers are called today, OR

  * a dict of the form `(dict "context" $ "component" "<name>")` — used
    by multi-component charts (scorpio-broker, see Step 10 of
    IMPLEMENTATION_PLAN.md) so the rendered name/labels also carry a
    component suffix. When `component` is empty the output is identical
    to the single-argument form.

The helpers detect the call style by checking whether the argument is a
map with a `context` key; no JSON round-tripping (which would lose
fidelity on Helm's typed `.Chart` / `.Release` objects) is performed.
*/}}

{{/*
common.names.name

Expand the name of the chart. Replicates the canonical `<chart>.name`
helper (see charts/orion/templates/_helpers.tpl):

  default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-"

A `component` in the dict form is appended as `-<component>` before the
final trunc/trim.
*/}}
{{- define "common.names.name" -}}
{{- if and (kindIs "map" .) (hasKey . "context") -}}
{{- $ctx := .context -}}
{{- $component := default "" .component -}}
{{- $name := default $ctx.Chart.Name $ctx.Values.nameOverride -}}
{{- if $component -}}
{{- printf "%s-%s" $name $component | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- else -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
common.names.fullname

Create a default fully qualified app name. Replicates the canonical
`<chart>.fullname` helper:

  - If `.Values.fullnameOverride` is set, use it verbatim (trunc 63).
  - Otherwise compute `$name = nameOverride || Chart.Name`, and use
    `.Release.Name` when it already contains `$name`, else
    `"<Release.Name>-<name>"`.
  - Truncated to 63 chars with trailing `-` trimmed (DNS 1123 limit).

A `component` in the dict form is appended as `-<component>` after the
initial base is computed, then the whole thing is trunc/trimmed again.
When called with the root context (or with `component` empty) the
output is byte-identical to the existing `<chart>.fullname` helper.
*/}}
{{- define "common.names.fullname" -}}
{{- if and (kindIs "map" .) (hasKey . "context") -}}
{{- $ctx := .context -}}
{{- $component := default "" .component -}}
{{- $base := "" -}}
{{- if $ctx.Values.fullnameOverride -}}
{{- $base = $ctx.Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default $ctx.Chart.Name $ctx.Values.nameOverride -}}
{{- if contains $name $ctx.Release.Name -}}
{{- $base = $ctx.Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $base = printf "%s-%s" $ctx.Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- if $component -}}
{{- printf "%s-%s" $base $component | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $base -}}
{{- end -}}
{{- else -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
common.names.chart

Create the chart name and version as used by the `helm.sh/chart` label.
Replicates the canonical `<chart>.chart` helper:

  printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-"

The `component` argument of the dict form is intentionally ignored
here: `helm.sh/chart` identifies the shipped chart, not a component
within it, and must remain constant across components of a multi-
component release.
*/}}
{{- define "common.names.chart" -}}
{{- if and (kindIs "map" .) (hasKey . "context") -}}
{{- $ctx := .context -}}
{{- printf "%s-%s" $ctx.Chart.Name $ctx.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
common.names.namespace

Return the namespace a rendered resource should live in. Defaults to
`.Release.Namespace`; honours `.Values.namespaceOverride` when the
consumer chart exposes that value. Matches the `namespace: {{
.Release.Namespace | quote }}` pattern used across FIWARE charts, with
the addition of an opt-in override.
*/}}
{{- define "common.names.namespace" -}}
{{- if and (kindIs "map" .) (hasKey . "context") -}}
{{- $ctx := .context -}}
{{- default $ctx.Release.Namespace $ctx.Values.namespaceOverride -}}
{{- else -}}
{{- default .Release.Namespace .Values.namespaceOverride -}}
{{- end -}}
{{- end -}}
