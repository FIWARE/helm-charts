{{/* vim: set filetype=mustache: */}}
{{/*
Inlined copies of the canonical orion/keyrock helpers. These exist only
in the fixture and are used to assert that `common.*` produces
byte-identical output for matching inputs. They are intentionally a
copy-paste of charts/orion/templates/_helpers.tpl (and, where relevant,
charts/keyrock/templates/_helpers.tpl); if a future change to the
canonical helper diverges from common, this fixture's diff test will
flag it.
*/}}

{{- define "legacy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "legacy.fullname" -}}
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

{{- define "legacy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "legacy.labels" -}}
app.kubernetes.io/name: {{ include "legacy.name" . }}
helm.sh/chart: {{ include "legacy.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "legacy.matchLabels" -}}
app.kubernetes.io/name: {{ include "legacy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
