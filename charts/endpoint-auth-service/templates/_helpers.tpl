
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "configService.name" -}}
{{- $chartName := printf "%s-%s" "cs" .Chart.Name }}
{{- default $chartName .Values.configService.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ishare.name" -}}
{{- $chartName := printf "%s-%s" "ishare" .Chart.Name }}
{{- default $chartName .Values.ishare.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "sidecarInjector.name" -}}
{{- $chartName := printf "%s-%s" "injector" .Chart.Name }}
{{- default $chartName .Values.sidecarInjector.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "endpointAuthService.name" -}}
{{- $chartName := printf "%s-%s" "eas" .Chart.Name }}
{{- default $chartName .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "configService.fullname" -}}
{{- if .Values.configService.fullnameOverride -}}
{{- .Values.configService.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $chartName := printf "%s-%s" "cs" .Chart.Name }}
{{- $name := default $chartName .Values.configService.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "endpointAuthService.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $chartName := printf "%s-%s" "eas" .Chart.Name }}
{{- $name := default $chartName .Values.nameOverride -}}
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
{{- $chartName := printf "%s-%s" "ishare" .Chart.Name }}
{{- $name := default $chartName .Values.ishare.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "sidecarInjector.fullname" -}}
{{- if .Values.sidecarInjector.fullnameOverride -}}
{{- .Values.sidecarInjector.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $chartName := printf "%s-%s" "injector" .Chart.Name }}
{{- $name := default $chartName .Values.sidecarInjector.nameOverride -}}
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
{{- define "endpointAuthService.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use for the configService
*/}}
{{- define "configService.serviceAccountName" -}}
{{- if .Values.configService.serviceAccount.create -}}
    {{ default (include "configService.fullname" .) .Values.configService.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.configService.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "ishare.serviceAccountName" -}}
{{- if .Values.ishare.serviceAccount.create -}}
    {{ default (include "ishare.fullname" .) .Values.ishare.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.ishare.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{- define "sidecarInjector.serviceAccountName" -}}
{{- if .Values.sidecarInjector.serviceAccount.create -}}
    {{ default (include "sidecarInjector.fullname" .) .Values.sidecarInjector.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.sidecarInjector.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Common labels
*/}}
{{- define "endpointAuthService.labels" -}}
helm.sh/chart: {{ include "endpointAuthService.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "configService.labels" -}}
{{ include "endpointAuthService.labels" . }}
app.kubernetes.io/name: {{ include "configService.name" . }}
{{- end -}}

{{- define "ishare.labels" -}}
{{ include "endpointAuthService.labels" . }}
app.kubernetes.io/name: {{ include "ishare.name" . }}
{{- end -}}

{{- define "sidecarInjector.labels" -}}
{{ include "endpointAuthService.labels" . }}
app.kubernetes.io/name: {{ include "sidecarInjector.name" . }}
{{- end -}}