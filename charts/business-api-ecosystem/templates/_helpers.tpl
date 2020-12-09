{{/*
Expand the name of the chart.
*/}}
{{- define "business-api-ecosystem.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "business-api-ecosystem.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "business-api-ecosystem.common.matchLabels" -}}
app: {{ template "business-api-ecosystem.name" . }}
release: {{ .Release.Name }}
{{- end -}}

{{- define "business-api-ecosystem.common.metaLabels" -}}
chart: {{ template "business-api-ecosystem.chart" . }}
heritage: {{ .Release.Service }}
{{- end -}}

{{/*
Create unified labels for BAE components
*/}}
{{- define "bizEcosystemApis.labels" -}}
{{ include "bizEcosystemApis.matchLabels" . }}
{{ include "business-api-ecosystem.common.metaLabels" . }}
{{- end -}}

{{- define "bizEcosystemApis.matchLabels" -}}
component: {{ .Values.bizEcosystemApis.name | quote }}
{{ include "business-api-ecosystem.common.matchLabels" . }}
{{- end -}}

{{- define "bizEcosystemRss.labels" -}}
{{ include "bizEcosystemRss.matchLabels" . }}
{{ include "business-api-ecosystem.common.metaLabels" . }}
{{- end -}}

{{- define "bizEcosystemRss.matchLabels" -}}
component: {{ .Values.bizEcosystemRss.name | quote }}
{{ include "business-api-ecosystem.common.matchLabels" . }}
{{- end -}}

{{- define "bizEcosystemChargingBackend.labels" -}}
{{ include "bizEcosystemChargingBackend.matchLabels" . }}
{{ include "business-api-ecosystem.common.metaLabels" . }}
{{- end -}}

{{- define "bizEcosystemChargingBackend.matchLabels" -}}
component: {{ .Values.bizEcosystemChargingBackend.name | quote }}
{{ include "business-api-ecosystem.common.matchLabels" . }}
{{- end -}}

{{- define "bizEcosystemLogicProxy.labels" -}}
{{ include "bizEcosystemLogicProxy.matchLabels" . }}
{{ include "business-api-ecosystem.common.metaLabels" . }}
{{- end -}}

{{- define "bizEcosystemLogicProxy.matchLabels" -}}
component: {{ .Values.bizEcosystemLogicProxy.name | quote }}
{{ include "business-api-ecosystem.common.matchLabels" . }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "business-api-ecosystem.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create a fully qualified bizEcosystemApis name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "bizEcosystemApis.fullname" -}}
{{- if .Values.bizEcosystemApis.fullnameOverride -}}
{{- .Values.bizEcosystemApis.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.bizEcosystemApis.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.bizEcosystemApis.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified bizEcosystemRss name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "bizEcosystemRss.fullname" -}}
{{- if .Values.bizEcosystemRss.fullnameOverride -}}
{{- .Values.bizEcosystemRss.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.bizEcosystemRss.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.bizEcosystemRss.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified bizEcosystemChargingBackend name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "bizEcosystemChargingBackend.fullname" -}}
{{- if .Values.bizEcosystemChargingBackend.fullnameOverride -}}
{{- .Values.bizEcosystemChargingBackend.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.bizEcosystemChargingBackend.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.bizEcosystemChargingBackend.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified bizEcosystemLogicProxy name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "bizEcosystemLogicProxy.fullname" -}}
{{- if .Values.bizEcosystemLogicProxy.fullnameOverride -}}
{{- .Values.bizEcosystemLogicProxy.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.bizEcosystemLogicProxy.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.bizEcosystemLogicProxy.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts.
*/}}
{{- define "business-api-ecosystem.namespace" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.namespaceOverride }}
            {{- .Values.global.namespaceOverride -}}
        {{- else -}}
            {{- .Release.Namespace -}}
        {{- end -}}
    {{- else -}}
        {{- .Release.Namespace -}}
    {{- end }}
{{- end -}}

{{/*
Create the name of the bizEcosystemApis service account to use
*/}}
{{- define "bizEcosystemApis.serviceAccountName" -}}
{{- if .Values.bizEcosystemApis.serviceAccount.create }}
    {{- default (include "bizEcosystemApis.fullname" .) .Values.bizEcosystemApis.serviceAccount.name }}
{{- else }}
    {{- default "default" .Values.bizEcosystemApis.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the bizEcosystemRss service account to use
*/}}
{{- define "bizEcosystemRss.serviceAccountName" -}}
{{- if .Values.bizEcosystemRss.serviceAccount.create }}
    {{- default (include "bizEcosystemRss.fullname" .) .Values.bizEcosystemRss.serviceAccount.name }}
{{- else }}
    {{- default "default" .Values.bizEcosystemRss.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the bizEcosystemChargingBackend service account to use
*/}}
{{- define "bizEcosystemChargingBackend.serviceAccountName" -}}
{{- if .Values.bizEcosystemChargingBackend.serviceAccount.create }}
    {{- default (include "bizEcosystemChargingBackend.fullname" .) .Values.bizEcosystemChargingBackend.serviceAccount.name }}
{{- else }}
    {{- default "default" .Values.bizEcosystemChargingBackend.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the bizEcosystemLogicProxy service account to use
*/}}
{{- define "bizEcosystemLogicProxy.serviceAccountName" -}}
{{- if .Values.bizEcosystemLogicProxy.serviceAccount.create }}
    {{- default (include "bizEcosystemLogicProxy.fullname" .) .Values.bizEcosystemLogicProxy.serviceAccount.name }}
{{- else }}
    {{- default "default" .Values.bizEcosystemLogicProxy.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the full hostname:port for the TMForum APIs endpoints
*/}}
{{- define "bizEcosystemApis.fullhostname" -}}
{{ include "bizEcosystemApis.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.bizEcosystemApis.service.port }}
{{- end }}

{{/*
Create the hostname only for the TMForum APIs
*/}}
{{- define "bizEcosystemApis.hostnameonly" -}}
{{ include "bizEcosystemApis.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local
{{- end }}

{{/*
Create the full hostname:port for the RSS APIs endpoints
*/}}
{{- define "bizEcosystemRss.fullhostname" -}}
{{ include "bizEcosystemRss.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.bizEcosystemRss.service.port }}
{{- end }}

{{/*
Create the hostname only for the RSS
*/}}
{{- define "bizEcosystemRss.hostnameonly" -}}
{{ include "bizEcosystemRss.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local
{{- end }}

{{/*
Create the full hostname:port for the Charging Backend APIs endpoints
*/}}
{{- define "bizEcosystemChargingBackend.fullhostname" -}}
{{ include "bizEcosystemChargingBackend.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.bizEcosystemChargingBackend.service.port }}
{{- end }}

{{/*
Create the hostname only for the Charging Backend
*/}}
{{- define "bizEcosystemChargingBackend.hostnameonly" -}}
{{ include "bizEcosystemChargingBackend.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local
{{- end }}

{{/*
Create the hostname only for the Logic Proxy
*/}}
{{- define "bizEcosystemLogicProxy.hostnameonly" -}}
{{ include "bizEcosystemLogicProxy.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local
{{- end }}

{{/*
Create the full hostname:port for the Logic Proxy
*/}}
{{- define "bizEcosystemLogicProxy.fullhostname" -}}
{{ include "bizEcosystemLogicProxy.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.bizEcosystemLogicProxy.service.port }}
{{- end }}

{{/*
Create the name of the API check initContainer for bizEcosystemRss
*/}}
{{- define "bizEcosystemRss.apiInitContainer" -}}
{{- printf "%s-%s-%s" .Release.Name .Values.bizEcosystemRss.name .Values.initContainer.apis.name | trunc 50 | trimSuffix "-" -}}
{{- end }}

{{/*
Create the name of the API check initContainer for bizEcosystemChargingBackend
*/}}
{{- define "bizEcosystemChargingBackend.apiInitContainer" -}}
{{- printf "%s-%s-%s" .Release.Name .Values.bizEcosystemChargingBackend.name .Values.initContainer.apis.name | trunc 50 | trimSuffix "-" -}}
{{- end }}

{{/*
Create the name of the API check initContainer for bizEcosystemLogicProxy
*/}}
{{- define "bizEcosystemLogicProxy.apiInitContainer" -}}
{{- printf "%s-%s-%s" .Release.Name .Values.bizEcosystemLogicProxy.name .Values.initContainer.apis.name | trunc 50 | trimSuffix "-" -}}
{{- end }}

{{/*
Template for MySQL initContainer check
*/}}
{{- define "business-api-ecosystem.initContainer.mysql" }}
- name: {{ tpl .name .ctx }}-{{ .ctx.Values.initContainer.mysql.name }}
  image: '{{ .ctx.Values.initContainer.mysql.image }}:{{ .ctx.Values.initContainer.mysql.imageTag }}'
  imagePullPolicy: {{ .ctx.Values.initContainer.mysql.imagePullPolicy | quote }}
  command: ['sh', '-c',
    'while ! mysqladmin ping -h{{ .host | quote }} --silent; do echo "Waiting for MySQL"; ((i++)) && ((i=={{ .ctx.Values.initContainer.mysql.maxRetries }})) && break; sleep {{ .ctx.Values.initContainer.mysql.sleepInterval }}; done;']        
{{- end }}

{{/*

*/}}
{{- define "business-api-ecosystem.initContainer.mongodb" }}
- name: {{ .ctx.Release.Name }}-{{ tpl .name .ctx }}-{{ .ctx.Values.initContainer.mongodb.name }}
  image: '{{ .ctx.Values.initContainer.mongodb.image }}:{{ .ctx.Values.initContainer.mongodb.imageTag }}'
  imagePullPolicy: {{ .ctx.Values.initContainer.mongodb.imagePullPolicy | quote }}
  command: ['sh', '-c',
    'while ! mongo --host {{ .host | quote }} --eval "printjson(db.serverStatus())"; do echo "Waiting for MongoDB"; ((i++)) && ((i=={{ .ctx.Values.initContainer.mongodb.maxRetries }})) && break; sleep {{ .ctx.Values.initContainer.mongodb.sleepInterval }}; done;']
{{- end }}

{{/*
Template for TMForum APIs initContainer check
*/}}
{{- define "business-api-ecosystem.initContainer.apis" }}
- name: {{ tpl .name .ctx }}
  image: "{{ .ctx.Values.initContainer.apis.image }}"
  imagePullPolicy: {{ .ctx.Values.initContainer.apis.imagePullPolicy | quote }}
  command: ['sh', '-c',
    'while ! wget "http://{{ include "bizEcosystemApis.fullhostname" .ctx }}/{{ .path }}"; do echo "Waiting for APIs"; ((i++)) && ((i=={{ .ctx.Values.initContainer.apis.maxRetries }})) && break; sleep {{ .ctx.Values.initContainer.apis.sleepInterval }}; done;']
{{- end }}

{{/*
Template for CHarging Backend initContainer check
*/}}
{{- define "business-api-ecosystem.initContainer.charging" }}
- name: {{ tpl .name .ctx }}
  image: "{{ .ctx.Values.initContainer.apis.image }}"
  imagePullPolicy: {{ .ctx.Values.initContainer.apis.imagePullPolicy | quote }}
  command: ['sh', '-c',
    'while ! wget "http://{{ include "bizEcosystemChargingBackend.fullhostname" .ctx }}/{{ .path }}"; do echo "Waiting for APIs"; ((i++)) && ((i=={{ .ctx.Values.initContainer.apis.maxRetries }})) && break; sleep {{ .ctx.Values.initContainer.apis.sleepInterval }}; done;']
{{- end }}

