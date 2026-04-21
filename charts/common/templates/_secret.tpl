{{/* vim: set filetype=mustache: */}}
{{/*
Secret body helper for the FIWARE `common` library chart.

Renders a complete `v1/Secret` when the consumer has NOT supplied an
`existingSecret`. Mirrors the bodies in
charts/orion/templates/secret.yaml,
charts/mintaka/templates/secret.yaml and the (first document of)
charts/keyrock/templates/secret.yaml.

Call convention — always dict form:

  {{ include "common.secret.tpl" (dict
       "context"        $
       "existingSecret" .Values.broker.db.existingSecret
       "data"           (dict "dbPassword" .Values.broker.db.auth.password))
  }}

  {{ include "common.secret.tpl" (dict
       "context"        $
       "existingSecret" .Values.existingCertSecret
       "suffix"         "-certs"
       "data"           (dict "key" .Values.token.key "cert" .Values.token.cert))
  }}

Arguments (dict):
  context        - root context (`$`), required.
  existingSecret - user-supplied override. Same shape rules as
                   `common.secrets.name`:
                     * nil / empty / absent
                     * bare string
                     * map with an optional `.name`
                   When a real user-supplied name is present the helper
                   renders nothing (the consumer references the
                   existing secret by its resolved name).
  data           - map of {key: rawValue}. Values are base64-encoded
                   with Sprig's `b64enc`. Required and non-empty;
                   callers that only want the `existingSecret` check
                   semantics (no Secret rendered) should use
                   `common.secrets.name` directly.
  type           - string, defaults to "Opaque".
  suffix         - optional name suffix (e.g. "-certs") — used by
                   keyrock for its certificate Secret.
  component      - optional component name, forwarded to the name /
                   label helpers for multi-component charts.

When `existingSecret` resolves to a user-supplied name the helper is a
no-op; the consumer's deployment continues to reference the resolved
`common.secrets.name` output.
*/}}
{{- define "common.secret.tpl" -}}
{{- $ctx := .context -}}
{{- $existing := .existingSecret -}}
{{- $data := required "common.secret.tpl: data is required" .data -}}
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
{{- $fullName := include "common.names.fullname" $labelArgs -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ printf "%s%s" $fullName $suffix }}
  namespace: {{ include "common.names.namespace" (dict "context" $ctx) | quote }}
  labels:
    {{- include "common.labels.standard" $labelArgs | nindent 4 }}
type: {{ $type }}
data:
  {{- range $key, $value := $data }}
  {{ $key }}: {{ $value | b64enc }}
  {{- end }}
{{- end -}}
{{- end -}}
