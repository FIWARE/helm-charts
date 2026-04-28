{{/* vim: set filetype=mustache: */}}
{{/*
Secret-name / secret-key helpers for the FIWARE `common` library chart.

Generalises the two secret-resolution idioms currently copy-pasted
across FIWARE charts:

  1. keyrock-style — `.Values.existingSecret` is a bare string (the
     name of a user-supplied Secret). When set, the chart must use the
     `tpl`-expanded string; otherwise it falls back to its own fullname
     (optionally with a suffix, as in keyrock's `-certs`).

     See charts/keyrock/templates/_helpers.tpl::keyrock.secretName and
     charts/keyrock/templates/_helpers.tpl::keyrock.certSecretName.

  2. orion-style — `.Values.broker.db.existingSecret` is a map with
     optional `name` and `key` keys. Each key is `tpl`-expanded when
     present; sane per-chart defaults are used when not.

     See charts/orion/templates/_helpers.tpl::orion.secretName and
     orion.secretKey.

Both idioms render byte-identical output when invoked via the helpers
below, so a consumer chart can replace its copy-pasted body with a
single `include`.

Call convention (always dict form — secrets take parameters that can't
be deduced from `.`):

  {{- include "fiwareCommon.secrets.name" (dict
        "context"        $
        "existingSecret" .Values.existingSecret
        "suffix"         "-certs") }}

  {{- include "fiwareCommon.secrets.key" (dict
        "context"        $
        "existingSecret" .Values.broker.db.existingSecret
        "defaultKey"     "dbPassword") }}
*/}}

{{/*
fiwareCommon.secrets.name

Resolve the name of a Secret to reference.

Arguments (dict):
  context        - root context ($), required for `tpl` expansion and
                   for fullname fallback.
  existingSecret - user-supplied override. Accepted shapes:
                     * nil / empty / absent:
                         fall back to `<fullname><suffix>`.
                     * string:
                         tpl-expand against the root context and return
                         verbatim (keyrock / keyrock.certSecretName).
                     * map with a non-empty `name`:
                         tpl-expand `.name` against the root context and
                         return (orion.secretName).
                     * map without `name`:
                         treated as "no override" → fall back.
  suffix         - optional string appended to the fullname fallback.
                   Used by keyrock.certSecretName ("-certs"); defaults
                   to empty for the orion/keyrock.secretName case.
  component      - optional component name, forwarded to
                   `fiwareCommon.names.fullname` (multi-component charts).

Rendering parity:
  * `keyrock.secretName` == this helper with `existingSecret =
    .Values.existingSecret` and no `suffix`.
  * `keyrock.certSecretName` == this helper with `existingSecret =
    .Values.existingCertSecret` and `suffix = "-certs"`.
  * `orion.secretName` == this helper with `existingSecret =
    .Values.broker.db.existingSecret` and no `suffix`.
*/}}
{{- define "fiwareCommon.secrets.name" -}}
{{- $ctx := .context -}}
{{- $existing := .existingSecret -}}
{{- $suffix := default "" .suffix -}}
{{- $component := default "" .component -}}
{{- $fallback := printf "%s%s" (include "fiwareCommon.names.fullname" (dict "context" $ctx "component" $component)) $suffix -}}
{{- if $existing -}}
{{- if kindIs "map" $existing -}}
{{- if $existing.name -}}
{{- tpl $existing.name $ctx -}}
{{- else -}}
{{- $fallback -}}
{{- end -}}
{{- else if kindIs "string" $existing -}}
{{- tpl $existing $ctx -}}
{{- else -}}
{{- $fallback -}}
{{- end -}}
{{- else -}}
{{- $fallback -}}
{{- end -}}
{{- end -}}

{{/*
fiwareCommon.secrets.key

Resolve the key within a Secret to reference.

Arguments (dict):
  context        - root context ($), required for `tpl` expansion of a
                   user-supplied key.
  existingSecret - as for `fiwareCommon.secrets.name`. Only the map form with
                   a `.key` entry participates in key resolution; other
                   shapes silently fall back to `defaultKey`.
  defaultKey     - the per-chart default key name (required).
                   Examples: orion uses "dbPassword".

Rendering parity:
  * `orion.secretKey` == this helper with `existingSecret =
    .Values.broker.db.existingSecret` and `defaultKey = "dbPassword"`.
*/}}
{{- define "fiwareCommon.secrets.key" -}}
{{- $ctx := .context -}}
{{- $existing := .existingSecret -}}
{{- $defaultKey := required "fiwareCommon.secrets.key: defaultKey is required" .defaultKey -}}
{{- if and (kindIs "map" $existing) $existing.key -}}
{{- tpl $existing.key $ctx -}}
{{- else -}}
{{- $defaultKey -}}
{{- end -}}
{{- end -}}
