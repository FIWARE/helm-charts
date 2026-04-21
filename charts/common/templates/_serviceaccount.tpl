{{/* vim: set filetype=mustache: */}}
{{/*
Service-account helpers for the FIWARE `common` library chart.

Reproduces the canonical `<chart>.serviceAccountName` helper currently
copy-pasted across every FIWARE chart (see
charts/orion/templates/_helpers.tpl and
charts/keyrock/templates/_helpers.tpl). Rendered output is byte-identical
to the legacy helper when called with the root context.

Call styles — consistent with _names.tpl and _labels.tpl:

  {{- include "common.serviceAccount.name" . }}

  {{- include "common.serviceAccount.name" (dict "context" $ "component" "worker") }}

The dict form exists so multi-component charts (scorpio-broker, Step 10
in IMPLEMENTATION_PLAN.md) can scope the default SA name to a single
component. It is additive: when `component` is empty (or the helper is
called with the root context) the result is exactly what the legacy
`<chart>.serviceAccountName` helper produced.

The helpers assume the consumer chart exposes the standard
`.Values.serviceAccount` block:

  serviceAccount:
    create: <bool>
    name:   <string, optional>

  * If `create` is true, the default name is
    `common.names.fullname` (optionally suffixed with `-<component>`);
    `.Values.serviceAccount.name` overrides when set.
  * If `create` is false, the name is `.Values.serviceAccount.name` or
    literally `default` — matching the behaviour of every FIWARE chart
    today.
*/}}

{{/*
common.serviceAccount.name

Return the name of the ServiceAccount a pod should use. Exactly
reproduces the legacy `<chart>.serviceAccountName` body:

    {{- if .Values.serviceAccount.create -}}
        {{ default (include "<chart>.fullname" .) .Values.serviceAccount.name }}
    {{- else -}}
        {{ default "default" .Values.serviceAccount.name }}
    {{- end -}}

When called in the dict form with a non-empty `component`, the default
(create=true, no override) becomes `<fullname>-<component>`.
*/}}
{{- define "common.serviceAccount.name" -}}
{{- $ctx := . -}}
{{- $component := "" -}}
{{- if and (kindIs "map" .) (hasKey . "context") -}}
{{- $ctx = .context -}}
{{- $component = default "" .component -}}
{{- end -}}
{{- if $ctx.Values.serviceAccount.create -}}
{{- $defaultName := include "common.names.fullname" (dict "context" $ctx "component" $component) -}}
{{- default $defaultName $ctx.Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" $ctx.Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}
