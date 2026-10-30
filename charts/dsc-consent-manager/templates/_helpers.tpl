{{/* vim: set filetype=mustache: */}}
{{/*
dsc-consent-manager helpers. The generic ones are thin wrappers over the
`fiwareCommon.*` helpers of the `common` library chart.
*/}}

{{/*
Expand the name of the chart. Delegates to `fiwareCommon.names.name`.
*/}}
{{- define "dscConsentManager.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "dscConsentManager.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`fiwareCommon.names.chart`.
*/}}
{{- define "dscConsentManager.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `fiwareCommon.labels.standard`.
*/}}
{{- define "dscConsentManager.labels" -}}
{{- include "fiwareCommon.labels.standard" . -}}
{{- end -}}

{{/*
Selector labels; immutable on a Deployment, so never add to them.
*/}}
{{- define "dscConsentManager.selectorLabels" -}}
{{- include "fiwareCommon.labels.matchLabels" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`fiwareCommon.serviceAccount.name`.
*/}}
{{- define "dscConsentManager.serviceAccountName" -}}
{{- include "fiwareCommon.serviceAccount.name" . -}}
{{- end -}}

{{/*
Secret holding the credentials: `secrets.existingSecret` if set, else the chart's own.
*/}}
{{- define "dscConsentManager.secretName" -}}
{{- include "fiwareCommon.secrets.name" (dict
      "context"        $
      "existingSecret" .Values.secrets.existingSecret) -}}
{{- end -}}

{{/*
Cluster-internal Service for health and metrics; the ServiceMonitor selects it too.
*/}}
{{- define "dscConsentManager.managementServiceName" -}}
{{- printf "%s-management" (include "dscConsentManager.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Out-of-band Secret holding the receipt signing keys; the chart never creates it.
*/}}
{{- define "dscConsentManager.signingKeysSecretName" -}}
{{- default (printf "%s-signing-keys" .Release.Name) .Values.signingKeys.secretName -}}
{{- end -}}

{{/*
ConfigMap holding identity-providers.yml for the additional providers.
*/}}
{{- define "dscConsentManager.identityProvidersConfigMapName" -}}
{{- printf "%s-identity-providers" (include "dscConsentManager.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Directory the additional-provider file is mounted into.
*/}}
{{- define "dscConsentManager.identityProvidersDir" -}}
/etc/consent-manager/config
{{- end -}}

{{/*
Data key and file name of the additional-provider file.
*/}}
{{- define "dscConsentManager.identityProvidersFile" -}}
identity-providers.yml
{{- end -}}

{{/*
Directory the signing-key Secret is mounted into.
*/}}
{{- define "dscConsentManager.signingKeysDir" -}}
/etc/consent-manager/keys
{{- end -}}

{{/*
Mode of the signing-key files: owner read only, see the volume in deployment.yaml.
*/}}
{{- define "dscConsentManager.signingKeysMode" -}}
0400
{{- end -}}

{{/*
Writable scratch directory on the otherwise read-only root filesystem.
*/}}
{{- define "dscConsentManager.tmpDir" -}}
/tmp
{{- end -}}
