
{{/* vim: set filetype=mustache: */}}
{{/*
Helpers for the `trusted-issuers-list` chart.

The seven canonical FIWARE helpers (`name`, `fullname`, `chart`,
`serviceAccountName`, `labels`, `secretName`, `passwordKey`) are thin
wrappers over the in-repo `common` library chart. The include paths
`til.*` are preserved verbatim so umbrella charts that already call
e.g. `include "til.fullname" .` continue to resolve without change.
See docs/common-chart.md for the library contract.

The two chart-specific helpers — `til.serviceName` (honours
`service.serviceNameOverride`) and `til.app.config` (renders the
micronaut + datasource configuration fragment consumed by the
initdata Job and the main Deployment) — stay chart-local.
*/}}

{{/*
Expand the name of the chart — delegates to `fiwareCommon.names.name`.
*/}}
{{- define "til.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name — delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "til.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label — delegates
to `fiwareCommon.names.chart`.
*/}}
{{- define "til.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use — delegates to
`fiwareCommon.serviceAccount.name`.
*/}}
{{- define "til.serviceAccountName" -}}
{{- include "fiwareCommon.serviceAccount.name" . -}}
{{- end -}}

{{/*
Create the name of the service. Chart-specific: honours
`.Values.service.serviceNameOverride` before falling back to the
fullname. Stays chart-local because `common` has no matching helper
today.
*/}}
{{- define "til.serviceName" -}}
{{- if .Values.service.serviceNameOverride -}}
    {{- .Values.service.serviceNameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{ include "til.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Common labels — delegates to `fiwareCommon.labels.standard`.
*/}}
{{- define "til.labels" -}}
{{- include "fiwareCommon.labels.standard" . -}}
{{- end -}}

{{/*
Support for existing database secret — delegates to
`fiwareCommon.secrets.name`. The legacy behaviour only treats
`.Values.database.existingSecret` as an override when its `enabled`
flag is true; otherwise the chart falls back to `<fullname>` even if
a stray `name` remains set. That gate is preserved here.
*/}}
{{- define "til.secretName" -}}
{{- $existing := "" -}}
{{- if .Values.database.existingSecret.enabled -}}
{{-   $existing = .Values.database.existingSecret -}}
{{- end -}}
{{- include "fiwareCommon.secrets.name"
      (dict "context" . "existingSecret" $existing) -}}
{{- end -}}

{{/*
Key within the database Secret that carries the password — delegates
to `fiwareCommon.secrets.key`. Same `enabled` gate as `til.secretName`;
defaults to `"password"` to match the legacy body.
*/}}
{{- define "til.passwordKey" -}}
{{- $existing := "" -}}
{{- if .Values.database.existingSecret.enabled -}}
{{-   $existing = .Values.database.existingSecret -}}
{{- end -}}
{{- include "fiwareCommon.secrets.key"
      (dict "context" . "existingSecret" $existing "defaultKey" "password") -}}
{{- end -}}

{{/*
Base application configuration based on dialect and persistence.
Chart-specific micronaut + datasource renderer consumed by the
initdata Job and the main Deployment; no equivalent in `common`.
 */}}
{{- define "til.app.config" -}}
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
