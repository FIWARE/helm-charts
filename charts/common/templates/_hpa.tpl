{{/* vim: set filetype=mustache: */}}
{{/*
HorizontalPodAutoscaler body helper for the FIWARE `common` library
chart.

Renders a complete `autoscaling/<apiVersion>` HPA gated on
`.autoscaling.enabled`. Mirrors the bodies in
charts/orion/templates/deployment-hpa.yaml,
charts/mintaka/templates/deployment-hpa.yaml and
charts/keyrock/templates/statefulset-hpa.yaml.

Call convention — always dict form:

  {{ include "fiwareCommon.hpa.tpl" (dict
       "context"     $
       "autoscaling" .Values.autoscaling)
  }}

  {{ include "fiwareCommon.hpa.tpl" (dict
       "context"     $
       "autoscaling" .Values.autoscaling
       "kind"        "StatefulSet")
  }}

Arguments (dict):
  context     - root context (`$`), required.
  autoscaling - the autoscaling sub-values, required. Map shape:
                  enabled      bool
                  apiVersion   string (e.g. "v2beta2", "v2"),
                               defaults to "v2" when empty
                  minReplicas  int
                  maxReplicas  int
                  metrics      list (optional; rendered verbatim via
                               toYaml)
  kind        - "Deployment" (default) or "StatefulSet" — names the
                `scaleTargetRef.kind`. Keyrock uses "StatefulSet"; every
                other FIWARE chart uses "Deployment".
  component   - optional component name, forwarded to the name / label
                helpers for multi-component charts.

The helper renders nothing when `autoscaling.enabled` is false.

*/}}
{{- define "fiwareCommon.hpa.tpl" -}}
{{- $ctx := .context -}}
{{- $autoscaling := required "fiwareCommon.hpa.tpl: autoscaling is required" .autoscaling -}}
{{- $kind := default "Deployment" .kind -}}
{{- $component := default "" .component -}}
{{- $labelArgs := dict "context" $ctx "component" $component -}}
{{- if $autoscaling.enabled -}}
{{- $fullName := include "fiwareCommon.names.fullname" $labelArgs -}}
apiVersion: autoscaling/{{ default "v2" $autoscaling.apiVersion }}
kind: HorizontalPodAutoscaler
metadata:
  name: {{ $fullName }}
  namespace: {{ include "fiwareCommon.names.namespace" (dict "context" $ctx) | quote }}
  labels:
    {{- include "fiwareCommon.labels.standard" $labelArgs | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: {{ $kind }}
    name: {{ $fullName }}
  minReplicas: {{ $autoscaling.minReplicas }}
  maxReplicas: {{ $autoscaling.maxReplicas }}
  {{- with $autoscaling.metrics }}
  metrics:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}
{{- end -}}
