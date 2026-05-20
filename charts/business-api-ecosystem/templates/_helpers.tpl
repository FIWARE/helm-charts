{{/* vim: set filetype=mustache: */}}
{{/*
business-api-ecosystem helpers.

The chart-level helpers (`business-api-ecosystem.name`,
`business-api-ecosystem.chart`, `business-api-ecosystem.fullname`) are
now thin wrappers around the matching `fiwareCommon.*` helpers shipped by the
`common` library chart (see charts/common/templates/*.tpl and
docs/common-chart.md). The wrappers exist so that:

  * Any external umbrella chart that already imports e.g.
    `include "business-api-ecosystem.name" .` keeps working — no
    external breaking change.
  * The bodies stay in lock-step with the rest of the FIWARE charts,
    because there is exactly one implementation of each helper (in
    `common`).

The per-component helpers (`bizEcosystemChargingBackend.*`,
`bizEcosystemLogicProxy.*`) remain
chart-local on purpose. Their rendered names depend on a legacy
`default "" .Values.nameOverride` base (empty fallback instead of
`.Chart.Name`), and migrating them to `fiwareCommon.names.fullname` with a
`component` argument would change the rendered names of every Service,
Deployment, StatefulSet, PVC, Secret and ServiceAccount in the chart —
a breaking change that cannot be absorbed by `helm upgrade`. The same
reasoning applies to the per-component `serviceAccountName` and
`secretName` / `certSecretName` helpers: they resolve relative to the
per-component `bizEcosystem<X>.fullname`, so migrating them would only
make sense once the per-component fullnames themselves move over.

Chart-local, by design, and called out as non-goals in
docs/common-chart.md:

  * `bizEcosystem<X>.fullhostname` / `bizEcosystem<X>.hostnameonly`
    — chart-specific hostname helpers.
  * `business-api-ecosystem.initContainer.*` — MySQL / MongoDB /
    Charging init-container body templates.
  * `bizEcosystem<X>.labels` / `matchLabels` — legacy
    `app` / `release` / `component` / `chart` / `heritage` label schema.
    Switching to `fiwareCommon.labels.standard` (which emits
    `app.kubernetes.io/*`) would change Service / Deployment selectors
    and block `helm upgrade`; these stay chart-local until the chart is
    willing to accept that break.
*/}}

{{/*
Expand the name of the chart. Delegates to `fiwareCommon.names.name`.
*/}}
{{- define "business-api-ecosystem.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`fiwareCommon.names.chart`.
*/}}
{{- define "business-api-ecosystem.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

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
{{- define "bizEcosystemChargingBackend.labels" -}}
{{ include "bizEcosystemChargingBackend.matchLabels" . }}
{{ include "business-api-ecosystem.common.metaLabels" . }}
{{- end -}}

{{- define "bizEcosystemChargingBackend.matchLabels" -}}
component: {{ .Values.bizEcosystemChargingBackend.name | quote }}
{{ include "business-api-ecosystem.common.matchLabels" . }}
{{- end -}}

{{- define "bizEcosystemLogicProxy.labels" -}}
{{- $match := include "bizEcosystemLogicProxy.matchLabels" . | fromYaml -}}
{{- $meta := include "business-api-ecosystem.common.metaLabels" . | fromYaml -}}
{{- $merged := merge $match $meta -}}
{{- toYaml $merged -}}
{{- end -}}

{{- define "bizEcosystemLogicProxy.matchLabels" -}}
{{- $labels := include "business-api-ecosystem.common.matchLabels" . | fromYaml -}}
{{- $_ := set $labels "component" .Values.bizEcosystemLogicProxy.name | quote -}}
{{- $_ := set $labels "app" (include "bizEcosystemLogicProxy.fullname" .) -}}
{{- toYaml $labels -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "business-api-ecosystem.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create a fully qualified bizEcosystemChargingBackend name. Kept chart-
local with legacy naming behavior.
We truncate at 63 chars because some Kubernetes name fields are limited
to this (by the DNS naming spec).
*/}}

{{- define "bizEcosystemChargingBackend.fullname" -}}
{{- if .Values.bizEcosystemChargingBackend.fullnameOverride -}}
{{- .Values.bizEcosystemChargingBackend.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "" .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.bizEcosystemChargingBackend.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.bizEcosystemChargingBackend.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified bizEcosystemLogicProxy name. Kept chart-local
with legacy naming behavior.
We truncate at 63 chars because some Kubernetes name fields are limited
to this (by the DNS naming spec).
*/}}

{{- define "bizEcosystemLogicProxy.fullname" -}}
{{- if .Values.bizEcosystemLogicProxy.fullnameOverride -}}
{{- .Values.bizEcosystemLogicProxy.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "" .Values.nameOverride -}}
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
- name: {{ tpl .name .ctx }}-{{ .ctx.Values.initContainer.mongodb.name }}
  image: '{{ .ctx.Values.initContainer.mongodb.image }}:{{ .ctx.Values.initContainer.mongodb.imageTag }}'
  imagePullPolicy: {{ .ctx.Values.initContainer.mongodb.imagePullPolicy | quote }}
  command: ['sh', '-c',
    'while ! mongo --host {{ .host | quote }} --eval "printjson(db.serverStatus())"; do echo "Waiting for MongoDB"; ((i++)) && ((i=={{ .ctx.Values.initContainer.mongodb.maxRetries }})) && break; sleep {{ .ctx.Values.initContainer.mongodb.sleepInterval }}; done;']
{{- end }}

{{/*
Template for Charging Backend initContainer check
*/}}
{{- define "business-api-ecosystem.initContainer.charging" }}
- name: {{ tpl .name .ctx }}
  image: "{{ .ctx.Values.initContainer.apis.image }}"
  imagePullPolicy: {{ .ctx.Values.initContainer.apis.imagePullPolicy | quote }}
  command: ['sh', '-c',
    'while ! wget "http://{{ include "bizEcosystemChargingBackend.fullhostname" .ctx }}/{{ .path }}"; do echo "Waiting for APIs"; ((i++)) && ((i=={{ .ctx.Values.initContainer.apis.maxRetries }})) && break; sleep {{ .ctx.Values.initContainer.apis.sleepInterval }}; done;']
{{- end }}

{{/*
Logic proxy secrets are kept chart-local because the fallback secret
name is derived from `bizEcosystemLogicProxy.fullname`, which uses this
chart's legacy per-component fullname behavior (`default "" .Values.nameOverride`).
Switching to `fiwareCommon.secrets.name` would change rendered secret names.
*/}}
{{- define "bizEcosystemLogicProxy.secretName" -}}
    {{- if .Values.bizEcosystemLogicProxy.existingSecret -}}
        {{- printf "%s" (tpl .Values.bizEcosystemLogicProxy.existingSecret $) -}}
    {{- else -}}
        {{- printf "%s" (include "bizEcosystemLogicProxy.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "bizEcosystemLogicProxy.certSecretName" -}}
    {{- if .Values.bizEcosystemLogicProxy.existingCertSecret -}}
        {{- printf "%s" (tpl .Values.bizEcosystemLogicProxy.existingCertSecret $) -}}
    {{- else -}}
        {{- printf "%s-certs" (include "bizEcosystemLogicProxy.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{/*
Charging backend secrets are kept chart-local because the fallback
secret name is derived from `bizEcosystemChargingBackend.fullname`,
which uses this chart's legacy per-component fullname behavior
(`default "" .Values.nameOverride`). Switching to
`fiwareCommon.secrets.name` would change rendered secret names.
*/}}
{{- define "bizEcosystemChargingBackend.secretName" -}}
    {{- if .Values.bizEcosystemChargingBackend.existingSecret -}}
        {{- printf "%s" (tpl .Values.bizEcosystemChargingBackend.existingSecret $) -}}
    {{- else -}}
        {{- printf "%s" (include "bizEcosystemChargingBackend.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "bizEcosystemChargingBackend.certSecretName" -}}
    {{- if .Values.bizEcosystemChargingBackend.existingCertSecret -}}
        {{- printf "%s" (tpl .Values.bizEcosystemChargingBackend.existingCertSecret $) -}}
    {{- else -}}
        {{- printf "%s-certs" (include "bizEcosystemChargingBackend.fullname" .) -}}
    {{- end -}}
{{- end -}}
