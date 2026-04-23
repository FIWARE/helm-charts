{{/* vim: set filetype=mustache: */}}
{{/*
Ingress body helper for the FIWARE `common` library chart.

Renders a complete `networking.k8s.io/v1` Ingress gated on
`.ingress.enabled`. Mirrors the bodies in
charts/orion/templates/ingress.yaml and
charts/mintaka/templates/ingress.yaml.

Keyrock currently branches on `semverCompare ">=1.14-0"` to emit the
legacy `extensions/v1beta1` Ingress shape. That branch is dropped here
and is called out as the only unavoidable breaking change in the
migration proposal (see docs/common-chart-proposal.md, "Breaking
Changes"). The chart's declared `kubeVersion` (>=1.19) already rules out
any cluster that would have needed the legacy apiVersion.

Call convention — always dict form:

  {{ include "common.ingress.tpl" (dict
       "context"     $
       "ingress"     .Values.ingress
       "servicePort" .Values.service.port)
  }}

Arguments (dict):
  context     - root context (`$`), required.
  ingress     - the ingress sub-values, required. Map shape:
                  enabled     bool
                  className   string (optional; keyrock-only today)
                  annotations map   (optional)
                  hosts       list of {host, paths: [string]}
                  tls         list of {hosts: [string], secretName}
  servicePort - int, required. Port number the Ingress backend points at
                (the consumer chart's `.Values.service.port`).
  component   - optional component name, forwarded to the name / label
                helpers for multi-component charts.

The helper renders nothing when `ingress.enabled` is false, so the
consumer chart can `include` it unconditionally from a dedicated
ingress.yaml file.
*/}}
{{- define "common.ingress.tpl" -}}
{{- $ctx := .context -}}
{{- $ingress := required "common.ingress.tpl: ingress is required" .ingress -}}
{{- $servicePort := required "common.ingress.tpl: servicePort is required" .servicePort -}}
{{- $component := default "" .component -}}
{{- $labelArgs := dict "context" $ctx "component" $component -}}
{{- if $ingress.enabled -}}
{{- $fullName := include "common.names.fullname" $labelArgs -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $fullName }}
  namespace: {{ include "common.names.namespace" (dict "context" $ctx) | quote }}
  labels:
    {{- include "common.labels.standard" $labelArgs | nindent 4 }}
  {{- with $ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with $ingress.className }}
  ingressClassName: {{ . }}
  {{- end }}
  {{- with $ingress.tls }}
  tls:
    {{- range . }}
    - hosts:
      {{- range .hosts }}
        - {{ . | quote }}
      {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
  {{- range $ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
        {{- range .paths }}
        - path: {{ . }}
          pathType: Prefix
          backend:
            service:
              name: {{ $fullName }}
              port:
                number: {{ $servicePort }}
        {{- end }}
  {{- end }}
{{- end -}}
{{- end -}}
