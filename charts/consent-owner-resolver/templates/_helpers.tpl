{{/* vim: set filetype=mustache: */}}
{{/*
consent-owner-resolver-specific helpers.

Every helper below is a thin wrapper around the matching `fiwareCommon.*`
helper from the `common` library chart, so that there is exactly one
implementation of each across the FIWARE charts.
*/}}

{{/*
Expand the name of the chart. Delegates to `fiwareCommon.names.name`.
*/}}
{{- define "resolver.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "resolver.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`fiwareCommon.names.chart`.
*/}}
{{- define "resolver.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`fiwareCommon.serviceAccount.name`.
*/}}
{{- define "resolver.serviceAccountName" -}}
{{- include "fiwareCommon.serviceAccount.name" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `fiwareCommon.labels.standard`.
*/}}
{{- define "resolver.labels" -}}
{{- include "fiwareCommon.labels.standard" . -}}
{{- end -}}

{{/*
The resolver configuration, as the JSON the service reads at CONFIG_PATH.

`config` is written verbatim when set, so a deployment can supply a shape
this chart does not model. Otherwise the document is assembled from the
`defaults`, `contractService` and `rules` values.
*/}}
{{- define "resolver.config" -}}
{{- if .Values.config -}}
{{- toPrettyJson .Values.config -}}
{{- else -}}
{{- $config := dict
      "defaultConsentRequired" .Values.defaults.consentRequired
      "defaultScheme" .Values.defaults.scheme -}}
{{- if .Values.contractService.enabled -}}
{{- $contractService := dict "url" (tpl .Values.contractService.url $) "timeoutMs" (int .Values.contractService.timeoutMs) -}}
{{- if .Values.contractService.providerSelfDescription -}}
{{- $_ := set $contractService "providerSelfDescription" (tpl .Values.contractService.providerSelfDescription $) -}}
{{- end -}}
{{- if .Values.contractService.resourceCacheTtlMs -}}
{{- $_ := set $contractService "resourceCacheTtlMs" (int .Values.contractService.resourceCacheTtlMs) -}}
{{- end -}}
{{- $_ := set $config "contractService" $contractService -}}
{{- end -}}
{{- $_ := set $config "rules" (.Values.rules | default list) -}}
{{- toPrettyJson $config -}}
{{- end -}}
{{- end -}}

{{/*
Name of the Secret holding the shared token that authenticates callers of
/resolve. Delegates to `fiwareCommon.secrets.name`.
*/}}
{{- define "resolver.authSecretName" -}}
{{- include "fiwareCommon.secrets.name" (dict
      "context"        $
      "existingSecret" .Values.auth.existingSecret) -}}
{{- end -}}

{{/*
Key of that token inside the Secret. Delegates to `fiwareCommon.secrets.key`.
*/}}
{{- define "resolver.authSecretKey" -}}
{{- include "fiwareCommon.secrets.key" (dict
      "context"        $
      "existingSecret" .Values.auth.existingSecret
      "defaultKey"     "authToken") -}}
{{- end -}}
