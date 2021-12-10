
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "config-service.name" -}}
{{- default .Chart.Name .Values.config-service.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ishare.name" -}}
{{- default .Chart.Name .Values.ishare.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "endpoint-auth-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "config-service.fullname" -}}
{{- if .Values.config-service.fullnameOverride -}}
{{- .Values.config-service.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.config-service.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "endpoint-auth-service.fullname" -}}
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

{{- define "ishare.fullname" -}}
{{- if .Values.ishare.fullnameOverride -}}
{{- .Values.ishare.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.ishare.nameOverride -}}
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
{{- define "endpoint-auth-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use for the config-service
*/}}
{{- define "config-service.serviceAccountName" -}}
{{- if .Values.config-service.serviceAccount.create -}}
    {{ default (include "config-service.fullname" .) .Values.config-service.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.config-service.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "endpoint-auth-service.labels" -}}
{{ include "endpoint-auth-service.labels" . | nindent 4 }}
helm.sh/chart: {{ include "endpoint-auth-service.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "config-service.labels" -}}
app.kubernetes.io/name: {{ include "config-service.name" . }}
{{- end -}}

{{- define "ishare.labels" -}}
app.kubernetes.io/name: {{ include "ishare.name" . }}
{{- end -}}