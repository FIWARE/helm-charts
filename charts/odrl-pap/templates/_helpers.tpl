
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "pap.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pap.fullname" -}}
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
{{- define "pap.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "pap.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "pap.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "pap.labels" -}}
app.kubernetes.io/name: {{ include "pap.name" . }}
helm.sh/chart: {{ include "pap.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Support for existing database secret 
*/}}
{{- define "pap.secretName" -}}
    {{- if .Values.database.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.database.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "pap.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "pap.passwordKey" -}}
    {{- if and (.Values.database.existingSecret.enabled) (.Values.database.existingSecret.key) -}}
        {{- printf "%s" (tpl .Values.database.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}