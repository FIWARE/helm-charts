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
  context      - root context (`$`), required.
  service      - the service sub-values, required. Map with at least
                 `.type` and optionally `.annotations`. `.port` is read
                 only as a fallback for a single-port caller that does
                 not pass `ports`.
  ports        - list of port maps, optional. Each entry accepts:
                   port       - int, required
                   targetPort - int|string, defaults to `port`
                   protocol   - string, defaults to "TCP"
                   name       - string, defaults to "http"
                   nodePort   - int, optional. When present the key
                                is rendered verbatim (including a
                                literal `null`) so callers can force a
                                ClusterIP to drop a previously-assigned
                                node port during a type switch.
                 When omitted, a single `http` port on `service.port`
                 is emitted (orion / mintaka / keyrock share this
                 shape).
  component    - optional component name, forwarded to the name and
                 label helpers for multi-component charts
                 (scorpio-broker, Step 10 of IMPLEMENTATION_PLAN.md).
  nameOverride - optional literal string to use as `metadata.name`
                 verbatim, bypassing `common.names.fullname`. Required
                 by scorpio-broker's two NodePort Services, whose
                 legacy names (`<fullname>-node-port` and
                 `scorpio-gateway-service`) do not follow the
                 canonical `<release>-<chart>[-<component>]` pattern.

Rendered output is identical (up to whitespace tolerated by
kubeconform) to the inlined canonical service template.
*/}}
{{- define "fiwareCommon.service.tpl" -}}
{{- $ctx := .context -}}
{{- $service := required "fiwareCommon.service.tpl: service is required" .service -}}
{{- $component := default "" .component -}}
{{- $nameOverride := default "" .nameOverride -}}
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
      name: {{ default "http" $port.name }}
      {{- if hasKey $port "nodePort" }}
      nodePort: {{ $port.nodePort }}
      {{- end }}
    {{- end }}
  selector:
    {{- include "fiwareCommon.labels.matchLabels" $labelArgs | nindent 4 }}
{{- end -}}
