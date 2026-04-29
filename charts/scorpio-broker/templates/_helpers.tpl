{{/* vim: set filetype=mustache: */}}
{{/*
scorpio-broker helpers.

Every helper in this file is now a thin wrapper around the matching
`fiwareCommon.*` helper from the `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Any external umbrella chart that already imports e.g.
    `include "scorpio-broker-dist.fullname" .` or
    `include "eureka.fullname" .` keeps working — no external
    breaking change.
  * The bodies below stay in lock-step with the rest of the FIWARE
    charts, because there is exactly one implementation of each
    helper (in `common`).

scorpio-broker is a multi-component chart: in addition to the
chart-wide helpers it ships a `<component>.fullname`,
`<component>.labels` and `<component>.matchLabels` helper for each of
the 10 microservices. Those per-component helpers forward the root
context plus the `<component>.name` value to the `fiwareCommon.*` helpers
via `(dict "context" $ "component" <name>)`, which is the dict call
style documented in `charts/common/templates/_names.tpl` for
multi-component charts.
*/}}

{{/*
Expand the name of the chart. Delegates to `fiwareCommon.names.name`.
*/}}
{{- define "scorpio-broker-dist.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "scorpio-broker-dist.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`fiwareCommon.names.chart`.
*/}}
{{- define "scorpio-broker-dist.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

{{/*
Selector labels. Delegates to `fiwareCommon.labels.matchLabels`.
*/}}
{{- define "scorpio-broker-dist.selectorLabels" -}}
{{- include "fiwareCommon.labels.matchLabels" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`fiwareCommon.serviceAccount.name`.
*/}}
{{- define "scorpio-broker-dist.serviceAccountName" -}}
{{- include "fiwareCommon.serviceAccount.name" . -}}
{{- end -}}

{{/*
Per-component `fullname` helpers. Each forwards the root context plus
the `<component>.name` from values to `fiwareCommon.names.fullname`, which
appends `-<component>` to the chart-wide fullname.
*/}}
{{- define "atContextServer.fullname" -}}
{{- include "fiwareCommon.names.fullname" (dict "context" . "component" .Values.atContextServer.name) -}}
{{- end -}}

{{- define "configServer.fullname" -}}
{{- include "fiwareCommon.names.fullname" (dict "context" . "component" .Values.configServer.name) -}}
{{- end -}}

{{- define "entityManager.fullname" -}}
{{- include "fiwareCommon.names.fullname" (dict "context" . "component" .Values.entityManager.name) -}}
{{- end -}}

{{- define "gateway.fullname" -}}
{{- include "fiwareCommon.names.fullname" (dict "context" . "component" .Values.gateway.name) -}}
{{- end -}}

{{- define "eureka.fullname" -}}
{{- include "fiwareCommon.names.fullname" (dict "context" . "component" .Values.eureka.name) -}}
{{- end -}}

{{- define "historyManager.fullname" -}}
{{- include "fiwareCommon.names.fullname" (dict "context" . "component" .Values.historyManager.name) -}}
{{- end -}}

{{- define "queryManager.fullname" -}}
{{- include "fiwareCommon.names.fullname" (dict "context" . "component" .Values.queryManager.name) -}}
{{- end -}}

{{- define "registryManager.fullname" -}}
{{- include "fiwareCommon.names.fullname" (dict "context" . "component" .Values.registryManager.name) -}}
{{- end -}}

{{- define "registrySubscriptionManager.fullname" -}}
{{- include "fiwareCommon.names.fullname" (dict "context" . "component" .Values.registrySubscriptionManager.name) -}}
{{- end -}}

{{- define "subscriptionManager.fullname" -}}
{{- include "fiwareCommon.names.fullname" (dict "context" . "component" .Values.subscriptionManager.name) -}}
{{- end -}}

{{/*
Per-component `labels` helpers. Each forwards the root context plus
the `<component>.name` from values to `fiwareCommon.labels.standard`, which
appends an `app.kubernetes.io/component: <name>` line to the canonical
5-label set.
*/}}
{{- define "atContextServer.labels" -}}
{{- include "fiwareCommon.labels.standard" (dict "context" . "component" .Values.atContextServer.name) -}}
{{- end -}}

{{- define "configServer.labels" -}}
{{- include "fiwareCommon.labels.standard" (dict "context" . "component" .Values.configServer.name) -}}
{{- end -}}

{{- define "entityManager.labels" -}}
{{- include "fiwareCommon.labels.standard" (dict "context" . "component" .Values.entityManager.name) -}}
{{- end -}}

{{- define "gateway.labels" -}}
{{- include "fiwareCommon.labels.standard" (dict "context" . "component" .Values.gateway.name) -}}
{{- end -}}

{{- define "eureka.labels" -}}
{{- include "fiwareCommon.labels.standard" (dict "context" . "component" .Values.eureka.name) -}}
{{- end -}}

{{- define "historyManager.labels" -}}
{{- include "fiwareCommon.labels.standard" (dict "context" . "component" .Values.historyManager.name) -}}
{{- end -}}

{{- define "queryManager.labels" -}}
{{- include "fiwareCommon.labels.standard" (dict "context" . "component" .Values.queryManager.name) -}}
{{- end -}}

{{- define "registryManager.labels" -}}
{{- include "fiwareCommon.labels.standard" (dict "context" . "component" .Values.registryManager.name) -}}
{{- end -}}

{{- define "registrySubscriptionManager.labels" -}}
{{- include "fiwareCommon.labels.standard" (dict "context" . "component" .Values.registrySubscriptionManager.name) -}}
{{- end -}}

{{- define "subscriptionManager.labels" -}}
{{- include "fiwareCommon.labels.standard" (dict "context" . "component" .Values.subscriptionManager.name) -}}
{{- end -}}

{{/*
Per-component `matchLabels` helpers. Each forwards the root context
plus the `<component>.name` from values to `fiwareCommon.labels.matchLabels`,
which appends an `app.kubernetes.io/component: <name>` line to the
canonical 2-label selector set.
*/}}
{{- define "atContextServer.matchLabels" -}}
{{- include "fiwareCommon.labels.matchLabels" (dict "context" . "component" .Values.atContextServer.name) -}}
{{- end -}}

{{- define "configServer.matchLabels" -}}
{{- include "fiwareCommon.labels.matchLabels" (dict "context" . "component" .Values.configServer.name) -}}
{{- end -}}

{{- define "entityManager.matchLabels" -}}
{{- include "fiwareCommon.labels.matchLabels" (dict "context" . "component" .Values.entityManager.name) -}}
{{- end -}}

{{- define "gateway.matchLabels" -}}
{{- include "fiwareCommon.labels.matchLabels" (dict "context" . "component" .Values.gateway.name) -}}
{{- end -}}

{{- define "eureka.matchLabels" -}}
{{- include "fiwareCommon.labels.matchLabels" (dict "context" . "component" .Values.eureka.name) -}}
{{- end -}}

{{- define "historyManager.matchLabels" -}}
{{- include "fiwareCommon.labels.matchLabels" (dict "context" . "component" .Values.historyManager.name) -}}
{{- end -}}

{{- define "queryManager.matchLabels" -}}
{{- include "fiwareCommon.labels.matchLabels" (dict "context" . "component" .Values.queryManager.name) -}}
{{- end -}}

{{- define "registryManager.matchLabels" -}}
{{- include "fiwareCommon.labels.matchLabels" (dict "context" . "component" .Values.registryManager.name) -}}
{{- end -}}

{{- define "registrySubscriptionManager.matchLabels" -}}
{{- include "fiwareCommon.labels.matchLabels" (dict "context" . "component" .Values.registrySubscriptionManager.name) -}}
{{- end -}}

{{- define "subscriptionManager.matchLabels" -}}
{{- include "fiwareCommon.labels.matchLabels" (dict "context" . "component" .Values.subscriptionManager.name) -}}
{{- end -}}
