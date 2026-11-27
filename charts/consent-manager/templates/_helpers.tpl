{{/* vim: set filetype=mustache: */}}
{{/*
consent-manager-specific helpers.

Every helper below is a thin wrapper around the matching `fiwareCommon.*`
helper from the `common` library chart, so that there is exactly one
implementation of each across the FIWARE charts.
*/}}

{{/*
Expand the name of the chart. Delegates to `fiwareCommon.names.name`.
*/}}
{{- define "consentManager.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "consentManager.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`fiwareCommon.names.chart`.
*/}}
{{- define "consentManager.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`fiwareCommon.serviceAccount.name`.
*/}}
{{- define "consentManager.serviceAccountName" -}}
{{- include "fiwareCommon.serviceAccount.name" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `fiwareCommon.labels.standard`.
*/}}
{{- define "consentManager.labels" -}}
{{- include "fiwareCommon.labels.standard" . -}}
{{- end -}}

{{/*
The application's own base url (APP_ENDPOINT / URL).

Defaults to the in-cluster service, which is right while nothing outside the
cluster dereferences it. A deployment that publishes the consent-manager - or
puts a gateway in front of it - has to set `appEndpoint` to that address,
because the value ends up in the links the application emits.
*/}}
{{- define "consentManager.appEndpoint" -}}
{{- if .Values.appEndpoint -}}
{{- tpl .Values.appEndpoint $ -}}
{{- else -}}
{{- printf "http://%s:%v" (include "consentManager.fullname" .) .Values.service.port -}}
{{- end -}}
{{- end -}}

{{/*
Base url of the contract service (a consent-facade) the privacy notices are
derived from. Templated, so a cross-namespace FQDN can carry
`{{ .Release.Namespace }}`.
*/}}
{{- define "consentManager.contractServiceUrl" -}}
{{- tpl (required "consentManager: contractService.url is required - the privacy notices are derived from it" .Values.contractService.url) $ -}}
{{- end -}}

{{/*
Name of the Secret holding the session/JWT/OAuth secrets and the consent key.
Delegates to `fiwareCommon.secrets.name`, so a user-supplied
`secret.existingSecret` wins over the chart's own.
*/}}
{{- define "consentManager.secretName" -}}
{{- include "fiwareCommon.secrets.name" (dict
      "context"        $
      "existingSecret" .Values.secret.existingSecret) -}}
{{- end -}}

{{/*
Whether this chart creates that Secret: only when it is not supplied from
outside.
*/}}
{{- define "consentManager.createSecret" -}}
{{- if and .Values.secret.create (not .Values.secret.existingSecret) -}}
true
{{- end -}}
{{- end -}}

{{/*
Name of the Secret holding the MongoDB password.
*/}}
{{- define "consentManager.mongoSecretName" -}}
{{- include "fiwareCommon.secrets.name" (dict
      "context"        $
      "existingSecret" .Values.mongo.auth.existingSecret
      "suffix"         "-mongo") -}}
{{- end -}}

{{/*
Key of the MongoDB password within that Secret.
*/}}
{{- define "consentManager.mongoSecretKey" -}}
{{- include "fiwareCommon.secrets.key" (dict
      "context"        $
      "existingSecret" .Values.mongo.auth.existingSecret
      "defaultKey"     "password") -}}
{{- end -}}
