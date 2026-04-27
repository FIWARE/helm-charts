
{{/* vim: set filetype=mustache: */}}
{{/*
credentials-config-service (`ccs.*`) helpers.

Most helpers in this file are now thin wrappers around the matching
`common.*` helper from the `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Any external umbrella chart that already imports e.g.
    `include "ccs.fullname" .` keeps working — no external
    breaking change.
  * The bodies below stay in lock-step with the rest of the FIWARE
    charts, because there is exactly one implementation of each
    helper (in `common`).

The chart-specific `ccs.app.config` helper, which renders the
application-config YAML consumed by the ConfigMap, has no counterpart
in the `common` library and is kept local.
*/}}

{{/*
Expand the name of the chart. Delegates to `common.names.name`.
*/}}
{{- define "ccs.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`common.names.fullname`.
*/}}
{{- define "ccs.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`common.names.chart`.
*/}}
{{- define "ccs.chart" -}}
{{- include "common.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`common.serviceAccount.name`.
*/}}
{{- define "ccs.serviceAccountName" -}}
{{- include "common.serviceAccount.name" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `common.labels.standard`.
*/}}
{{- define "ccs.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}

{{/*
Resolve the name of the database credentials Secret.

The ccs chart uses an opt-in `.Values.database.existingSecret.enabled`
flag (unlike the bare-string / map-with-name forms consumed by
`common.secrets.name` elsewhere). We translate that shape here: when
`enabled` is true we forward the map to `common.secrets.name`, which
tpl-expands `.name` and returns it verbatim; otherwise we pass an empty
override so the helper falls back to the chart's fullname.
*/}}
{{- define "ccs.secretName" -}}
{{- $existing := "" -}}
{{- if .Values.database.existingSecret.enabled -}}
{{- $existing = .Values.database.existingSecret -}}
{{- end -}}
{{- include "common.secrets.name" (dict "context" . "existingSecret" $existing) -}}
{{- end -}}

{{/*
Resolve the key within the database Secret to reference.

Same `enabled`-gated translation as `ccs.secretName` above; the default
key `password` matches the legacy `ccs.passwordKey` behaviour.
*/}}
{{- define "ccs.passwordKey" -}}
{{- $existing := "" -}}
{{- if and .Values.database.existingSecret.enabled .Values.database.existingSecret.key -}}
{{- $existing = .Values.database.existingSecret -}}
{{- end -}}
{{- include "common.secrets.key" (dict "context" . "existingSecret" $existing "defaultKey" "password") -}}
{{- end -}}

{{/*
Base application configuration based on dialect and persistence. This
renders the `application.yaml` consumed by the ConfigMap and is
chart-specific — it has no counterpart in the `common` library.
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
