
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ccs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ccs.fullname" -}}
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
{{- define "ccs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "ccs.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "ccs.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "ccs.labels" -}}
app.kubernetes.io/name: {{ include "ccs.name" . }}
helm.sh/chart: {{ include "ccs.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Support for existing database secret
*/}}
{{- define "ccs.secretName" -}}
    {{- if .Values.database.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.database.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "ccs.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "ccs.passwordKey" -}}
    {{- if and (.Values.database.existingSecret.enabled) (.Values.database.existingSecret.key) -}}
        {{- printf "%s" (tpl .Values.database.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}

{{/*
Base application configuration base on dialec and persistence
 */}}
{{- define "ccs.app.config" -}}
endpoints:
  all:
    port: {{ .Values.deployment.healthPort }}
  micronaut:
    server:
      port: {{ .Values.port }}
    metrics:
      enabled: {{ .Values.prometheus.enabled }}
datasources:
  default:
    username: {{ .Values.database.username }}
{{- if .Values.database.persistence }}
  {{- if eq (.Values.database.dialect | upper) "POSTGRES" }}
    url: jdbc:postgresql://{{ .Values.database.host }}:{{ .Values.database.port }}/{{ .Values.database.name }}
    driverClassName: org.postgresql.Driver
    dialect: POSTGRES
  {{- else if eq (.Values.database.dialect | upper) "MYSQL" }}
    url: jdbc:mysql://{{ .Values.database.host }}:{{ .Values.database.port }}/{{ .Values.database.name }}
    driverClassName: com.mysql.cj.jdbc.Driver
    dialect: MYSQL
  {{- end }}
{{- else }}
    url: jdbc:h2:mem:devDb;LOCK_TIMEOUT=10000;DB_CLOSE_ON_EXIT=FALSE
    driverClassName: org.h2.Driver
    dialect: H2
{{- end -}}
{{- end -}}