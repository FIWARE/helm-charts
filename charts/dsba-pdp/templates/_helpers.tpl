
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "dsba-pdp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dsba-pdp.fullname" -}}
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
{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dsba-pdp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "dsba-pdp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "dsba-pdp.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "dsba-pdp.labels" -}}
app.kubernetes.io/name: {{ include "dsba-pdp.name" . }}
helm.sh/chart: {{ include "dsba-pdp.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}


{{- define "dsba-pdp.secretName" -}}
    {{- if .Values.db.existingSecret -}}
        {{- printf "%s" (tpl .Values.db.existingSecret $) -}}
    {{- else -}}
        {{- printf "%s" (include "dsba-pdp.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "dsba-pdp.ishareSecret" -}}
    {{- if .Values.deployment.ishare.existingSecret -}}
        {{- printf "%s" (tpl .Values.deployment.ishare.existingSecret $) -}}
    {{- else -}}
        {{- printf "%s-ishare" (include "dsba-pdp.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "dsba-pdp.ishareTrustedList" -}}
{{- join "," .Values.deployment.ishare.trustedFingerprints }}
{{- end -}}