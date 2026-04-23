{{/* vim: set filetype=mustache: */}}
{{/*
OpenShift Route body helper for the FIWARE `common` library chart.

Renders a complete `route.openshift.io/v1` Route gated on
`.route.enabled`. Mirrors the body in
charts/orion/templates/route.yaml and
charts/mintaka/templates/route.yaml.

Keyrock ships a multi-route variant (iterates `.Values.route.routes` and
emits `cert-utils-operator.redhat-cop.io/certs-from-secret` annotations
for each). That shape is chart-specific and stays as a bespoke
`templates/route.yaml` in keyrock; it is NOT replaced by this helper in
the migration (see docs/common-chart-proposal.md, "Charts that keep a
bespoke route template").

Call convention — always dict form:

  {{ include "common.route.tpl" (dict
       "context" $
       "route"   .Values.route)
  }}

Arguments (dict):
  context   - root context (`$`), required.
  route     - the route sub-values, required. Map shape:
                enabled     bool
                host        string (optional; when empty the Route
                                    relies on the OpenShift default
                                    host generation)
                annotations map    (optional)
                tls         map    (optional, rendered verbatim via
                                    toYaml)
  component - optional component name, forwarded to the name / label
              helpers for multi-component charts.

The helper renders nothing when `route.enabled` is false.
*/}}
{{- define "common.route.tpl" -}}
{{- $ctx := .context -}}
{{- $route := required "common.route.tpl: route is required" .route -}}
{{- $component := default "" .component -}}
{{- $labelArgs := dict "context" $ctx "component" $component -}}
{{- if $route.enabled -}}
{{- $fullName := include "common.names.fullname" $labelArgs -}}
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: {{ $fullName }}
  namespace: {{ include "common.names.namespace" (dict "context" $ctx) | quote }}
  labels:
    {{- include "common.labels.standard" $labelArgs | nindent 4 }}
  {{- with $route.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with $route.host }}
  host: {{ . }}
  {{- end }}
  to:
    kind: Service
    name: {{ $fullName }}
  {{- with $route.tls }}
  tls:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}
{{- end -}}
