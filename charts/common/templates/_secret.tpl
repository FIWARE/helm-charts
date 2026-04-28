{{/* vim: set filetype=mustache: */}}
{{/*
Secret body helper for the FIWARE `common` library chart.

Renders a complete `v1/Secret` when the consumer has NOT supplied an
`existingSecret`. Mirrors the bodies in
charts/orion/templates/secret.yaml,
charts/mintaka/templates/secret.yaml and the (first document of)
charts/keyrock/templates/secret.yaml.

Call convention — always dict form:

  {{ include "fiwareCommon.secret.tpl" (dict
       "context"        $
       "existingSecret" .Values.broker.db.existingSecret
       "data"           (dict "dbPassword" .Values.broker.db.auth.password))
  }}

  {{ include "fiwareCommon.secret.tpl" (dict
       "context"        $
       "existingSecret" .Values.existingCertSecret
       "suffix"         "-certs"
       "data"           (dict "key" .Values.token.key "cert" .Values.token.cert))
  }}

Arguments (dict):
  context        - root context (`$`), required.
  existingSecret - user-supplied override. Same shape rules as
                   `fiwareCommon.secrets.name`:
                     * nil / empty / absent
                     * bare string
                     * map with an optional `.name`
                   When a real user-supplied name is present the helper
                   renders nothing (the consumer references the
                   existing secret by its resolved name).
  data           - map of {key: rawValue}. Values are base64-encoded
                   with Sprig's `b64enc`. Required only when no
                   `existingSecret` is supplied — when the helper
                   renders nothing (user-supplied existing secret) the
                   `data` argument may be omitted. Callers that only
                   want the `existingSecret` check semantics can also
                   use `fiwareCommon.secrets.name` directly.
  type           - string, defaults to "Opaque".
  suffix         - optional name suffix (e.g. "-certs") — used by
                   keyrock for its certificate Secret.
  component      - optional component name, forwarded to the name /
                   label helpers for multi-component charts.

When `existingSecret` resolves to a user-supplied name the helper is a
no-op; the consumer's deployment continues to reference the resolved
`fiwareCommon.secrets.name` output.
*/}}
{{- define "fiwareCommon.secret.tpl" -}}
{{- $ctx := .context -}}
{{- $existing := .existingSecret -}}
{{- $type := default "Opaque" .type -}}
{{- $suffix := default "" .suffix -}}
{{- $component := default "" .component -}}
{{- $labelArgs := dict "context" $ctx "component" $component -}}
{{- $userSupplied := false -}}
{{- if $existing -}}
  {{- if kindIs "map" $existing -}}
    {{- if $existing.name -}}{{- $userSupplied = true -}}{{- end -}}
  {{- else if kindIs "string" $existing -}}
    {{- $userSupplied = true -}}
  {{- end -}}
{{- end -}}
{{- if not $userSupplied -}}
{{- $data := required "fiwareCommon.secret.tpl: data is required" .data -}}
{{- $fullName := include "fiwareCommon.names.fullname" $labelArgs -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ printf "%s%s" $fullName $suffix }}
  namespace: {{ include "fiwareCommon.names.namespace" (dict "context" $ctx) | quote }}
  labels:
    {{- include "fiwareCommon.labels.standard" $labelArgs | nindent 4 }}
type: {{ $type }}
data:
  {{- range $key, $value := $data }}
  {{ $key }}: {{ $value | b64enc }}
  {{- end }}
{{- end -}}
{{- end -}}
