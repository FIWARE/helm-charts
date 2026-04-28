{{/* vim: set filetype=mustache: */}}
{{/*
Inlined copies of the canonical orion/keyrock helpers. These exist only
in the fixture and are used to assert that `fiwareCommon.*` produces
byte-identical output for matching inputs. They are intentionally a
copy-paste of charts/orion/templates/_helpers.tpl (and, where relevant,
charts/keyrock/templates/_helpers.tpl); if a future change to the
canonical helper diverges from common, this fixture's diff test will
flag it.
*/}}

{{- define "legacy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "legacy.fullname" -}}
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

{{- define "legacy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "legacy.labels" -}}
app.kubernetes.io/name: {{ include "legacy.name" . }}
helm.sh/chart: {{ include "legacy.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "legacy.matchLabels" -}}
app.kubernetes.io/name: {{ include "legacy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Legacy copies of the serviceAccount / secret helpers. Same purpose as
the name/labels copies above — the parity ConfigMap renders them
side-by-side with the `fiwareCommon.*` output so `diff` catches divergence.

`legacy.serviceAccountName` matches charts/orion/templates/_helpers.tpl
and charts/keyrock/templates/_helpers.tpl verbatim.

`legacy.keyrockSecretName` / `legacy.keyrockCertSecretName` match
charts/keyrock/templates/_helpers.tpl.

`legacy.orionSecretName` / `legacy.orionSecretKey` match
charts/orion/templates/_helpers.tpl.
*/}}

{{- define "legacy.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "legacy.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "legacy.keyrockSecretName" -}}
    {{- if .Values.existingSecret -}}
        {{- printf "%s" (tpl .Values.existingSecret $) -}}
    {{- else -}}
        {{- printf "%s" (include "legacy.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "legacy.keyrockCertSecretName" -}}
    {{- if .Values.existingCertSecret -}}
        {{- printf "%s" (tpl .Values.existingCertSecret $) -}}
    {{- else -}}
        {{- printf "%s-certs" (include "legacy.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "legacy.orionSecretName" -}}
    {{- if .Values.broker.db.existingSecret -}}
        {{- if .Values.broker.db.existingSecret.name -}}
            {{- printf "%s" (tpl .Values.broker.db.existingSecret.name $) -}}
        {{- else -}}
            {{- printf "%s" (include "legacy.fullname" .) -}}
        {{- end -}}
    {{- else -}}
        {{- printf "%s" (include "legacy.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "legacy.orionSecretKey" -}}
    {{- if .Values.broker.db.existingSecret -}}
        {{- if .Values.broker.db.existingSecret.key -}}
            {{- printf "%s" (tpl .Values.broker.db.existingSecret.key $) -}}
        {{- else -}}
            {{- printf "dbPassword" -}}
        {{- end -}}
    {{- else -}}
        {{- printf "dbPassword" -}}
    {{- end -}}
{{- end -}}
