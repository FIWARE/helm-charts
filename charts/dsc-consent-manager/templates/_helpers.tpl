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

{{/*
Component label telling the management Service apart from the API Service.
*/}}
{{- define "dscConsentManager.managementComponentLabel" -}}
app.kubernetes.io/component: management
{{- end -}}

{{/*
Labels the ServiceMonitor selects the management Service by.
*/}}
{{- define "dscConsentManager.managementSelectorLabels" -}}
{{ include "dscConsentManager.selectorLabels" . }}
{{ include "dscConsentManager.managementComponentLabel" . }}
{{- end -}}

{{/*
Path the application serves Prometheus metrics on, on the management port.
*/}}
{{- define "dscConsentManager.metricsPath" -}}
/prometheus
{{- end -}}

{{/*
Secret keys every pod requires, space-separated; read with splitList.
*/}}
{{- define "dscConsentManager.mandatorySecretKeys" -}}
DB_USER DB_PASSWORD LOG_PSEUDONYM_KEY ERASURE_VERIFICATION_SECRET
{{- end -}}

{{/*
Secret keys a pod may lack, space-separated; read with splitList.
*/}}
{{- define "dscConsentManager.optionalSecretKeys" -}}
SMTP_USER SMTP_PASSWORD
{{- end -}}

{{/*
Placeholder default of `identityProviders.primary.issuer`; must match values.yaml.
*/}}
{{- define "dscConsentManager.placeholderIssuer" -}}
https://idp.example.org/realms/consent-manager
{{- end -}}

{{/*
Placeholder default of `identityProviders.primary.discoveryUrl`; must match values.yaml.
*/}}
{{- define "dscConsentManager.placeholderDiscoveryUrl" -}}
{{- include "dscConsentManager.placeholderIssuer" . }}/.well-known/openid-configuration
{{- end -}}

{{/*
Placeholder default of `config.database.url`; must match values.yaml.
*/}}
{{- define "dscConsentManager.placeholderDatabaseUrl" -}}
jdbc:postgresql://postgres:5432/consent_manager
{{- end -}}

{{/*
Value paths still holding a placeholder, one per line; empty when none. NOTES.txt warns while
any is listed. `audience` is not checked: its default is a plausible real value.
*/}}
{{- define "dscConsentManager.placeholdersInUse" -}}
{{- $inUse := list }}
{{- $primary := .Values.identityProviders.primary }}
{{- if eq $primary.issuer (include "dscConsentManager.placeholderIssuer" .) }}
{{- $inUse = append $inUse "identityProviders.primary.issuer" }}
{{- end }}
{{- if eq $primary.discoveryUrl (include "dscConsentManager.placeholderDiscoveryUrl" .) }}
{{- $inUse = append $inUse "identityProviders.primary.discoveryUrl" }}
{{- end }}
{{- if eq .Values.config.database.url (include "dscConsentManager.placeholderDatabaseUrl" .) }}
{{- $inUse = append $inUse "config.database.url" }}
{{- end }}
{{- if and (not .Values.secrets.existingSecret) (not .Values.secrets.dbPassword) }}
{{- $inUse = append $inUse "secrets.* (or secrets.existingSecret)" }}
{{- end }}
{{- join "\n" $inUse -}}
{{- end -}}

{{/*
Non-empty when the chart-owned Secret falls back to a looked-up or generated key, which
rotates on every render wherever `lookup` is unavailable (helm template, Argo CD, Flux).
*/}}
{{- define "dscConsentManager.secretKeysFallback" -}}
{{- $s := .Values.secrets }}
{{- if and (not $s.existingSecret) (or (not $s.logPseudonymKey) (not $s.erasureVerificationSecret)) -}}
true
{{- end -}}
{{- end -}}

{{/*
Fails rendering when a provider entry declares a key this chart does not map; the application
would otherwise never see it. Takes a dict with "name" and "entry".
*/}}
{{- define "dscConsentManager.validateProvider" -}}
{{- $path := printf "identityProviders.%s" .name }}
{{- $settingKeys := list "issuer" "discoveryUrl" "audience" "allowInsecureTransport" "clockSkew" "claims" "roleMapping" }}
{{- range $key, $_ := .entry }}
{{- if not (has $key $settingKeys) }}
{{- fail (printf "%s declares unsupported key '%s'; supported: %s" $path $key (join ", " $settingKeys)) }}
{{- end }}
{{- end }}
{{- $claimKeys := list "userIdentifier" "participantIdentifier" "roles" }}
{{- range $key, $_ := (.entry.claims | default dict) }}
{{- if not (has $key $claimKeys) }}
{{- fail (printf "%s.claims declares unsupported key '%s'; supported: %s" $path $key (join ", " $claimKeys)) }}
{{- end }}
{{- end }}
{{- $roleKeys := include "dscConsentManager.roles" . | splitList " " }}
{{- range $key, $_ := (.entry.roleMapping | default dict) }}
{{- if not (has $key $roleKeys) }}
{{- fail (printf "%s.roleMapping declares unsupported role '%s'; supported: %s" $path $key (join ", " $roleKeys)) }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Application roles an IdP role is mapped to, space-separated; read with splitList.
*/}}
{{- define "dscConsentManager.roles" -}}
user participant catalog
{{- end -}}

{{/*
Claim and role-mapping defaults of an additional provider; application.yml's for primary.
*/}}
{{- define "dscConsentManager.additionalProviderDefaults" -}}
claims:
  userIdentifier: [sub]
  participantIdentifier: [participant_id]
  roles: [realm_access, roles]
roleMapping:
  user: consent-user
  participant: consent-participant
  catalog: consent-catalog
{{- end -}}

{{/*
Default clock skew of an additional provider that sets none.
*/}}
{{- define "dscConsentManager.defaultClockSkew" -}}
30s
{{- end -}}

{{/*
Quoted env value; a number renders as an integer, never in float notation such as 1e+06.
*/}}
{{- define "dscConsentManager.envValue" -}}
{{- if and (kindIs "float64" .) (eq (float64 (int64 .)) .) }}
{{- int64 . | toString | quote }}
{{- else }}
{{- toString . | quote }}
{{- end }}
{{- end -}}

{{/*
Random bytes of a generated fallback key, as `openssl rand -base64 32` produces.
*/}}
{{- define "dscConsentManager.generatedKeyBytes" -}}
32
{{- end -}}
