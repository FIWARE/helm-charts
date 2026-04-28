{{/* vim: set filetype=mustache: */}}
{{/*
Service body helper for the FIWARE `common` library chart.

Renders a complete `v1/Service` manifest matching the canonical shape
currently copy-pasted into `charts/<chart>/templates/service.yaml`
across FIWARE (see charts/orion/templates/service.yaml,
charts/keyrock/templates/service.yaml and
charts/mintaka/templates/service.yaml for the reference bodies).

Call convention — always dict form, because the helper cannot guess
which sub-paths of `.Values` to look at:

  {{ include "fiwareCommon.service.tpl" (dict
       "context" $
       "service" .Values.service
       "ports"   (list (dict
                        "port"       .Values.service.port
                        "targetPort" .Values.broker.port)))
  }}

Arguments (dict):
  context   - root context (`$`), required.
  service   - the service sub-values, required. Map with at least
              `.type` and optionally `.annotations`. `.port` is read
              only as a fallback for a single-port caller that does not
              pass `ports`.
  ports     - list of port maps, optional. Each entry accepts:
                port       - int, required
                targetPort - int|string, defaults to `port`
                protocol   - string, defaults to "TCP"
                name       - string, defaults to "http"
              When omitted, a single `http` port on `service.port` is
              emitted (orion / mintaka / keyrock share this shape).
  component - optional component name, forwarded to the name and label
              helpers for multi-component charts (scorpio-broker, Step
              10 of IMPLEMENTATION_PLAN.md).

Rendered output is identical (up to whitespace tolerated by
kubeconform) to the inlined canonical service template.
*/}}
{{- define "fiwareCommon.service.tpl" -}}
{{- $ctx := .context -}}
{{- $service := required "fiwareCommon.service.tpl: service is required" .service -}}
{{- $component := default "" .component -}}
{{- $labelArgs := dict "context" $ctx "component" $component -}}
{{- $ports := required "fiwareCommon.service.tpl: ports is required" .ports -}}
{{- if not $ports -}}
{{- $ports = list (dict "port" $service.port) -}}
{{- end -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "fiwareCommon.names.fullname" $labelArgs }}
  namespace: {{ include "fiwareCommon.names.namespace" (dict "context" $ctx) | quote }}
  {{- with $service.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "fiwareCommon.labels.standard" $labelArgs | nindent 4 }}
spec:
  type: {{ $service.type }}
  ports:
    {{- range $port := $ports }}
    - port: {{ $port.port }}
      targetPort: {{ default $port.port $port.targetPort }}
      protocol: {{ default "TCP" $port.protocol }}
      name: {{ default "http" $port.name | quote }}
    {{- end }}
  selector:
    {{- include "fiwareCommon.labels.matchLabels" $labelArgs | nindent 4 }}
{{- end -}}
