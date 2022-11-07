{{/*
Helper template for container values, to avoid duplication due to having both a simplified and a full
container list spec option for the user
*/}}
{{- define "generic-microservice.deployment_containers_containerlist" -}}
- name: {{ .name | default $.Release.Name }}-container
  {{- if .image }}
  image: "{{ .image.repository | default $.Values.imageRepo }}:{{ .image.tag | default $.Values.imageTag }}"
  imagePullPolicy: {{ .image.pullPolicy | default "IfNotPresent" }}
  {{- else }}
  image: "{{ $.Values.imageRepo }}:{{ $.Values.imageTag }}"
  imagePullPolicy: IfNotPresent
  {{- end }}
  {{- with .command }}
  command:
  {{- range . }}
    - {{ . | quote }}
  {{- end }}
  {{- end }}
  {{- with .args }}
  args:
  {{- range . }}
    - {{ . | quote }}
  {{- end }}
  {{- end }}
  {{- if .configMaps }}
  envFrom:
  {{- if and .spring (eq $.Release.Namespace "bxd") }}
  - configMapRef:
      name: bxd-global-config
      optional: true
  - configMapRef:
      name: bxd-environment-config
      optional: true
  {{- end }}
  {{- range .configMaps }}
  - configMapRef:
      name: {{ .name }}
      {{- if .optional }}
      optional: true
      {{- end }}
  {{- end }}
  {{- else }}
  {{- if and .spring (eq $.Release.Namespace "bxd") }}
  envFrom:
  - configMapRef:
      name: bxd-global-config
      optional: true
  - configMapRef:
      name: bxd-environment-config
      optional: true
  {{- end }}
  {{- end }}
  {{- if .spring }}
  env:
  - name: server.port
    value: {{ (.port | default 80) | quote }}
  {{- end }}
  {{- if .ports }}
  ports:
    {{- range .ports }}
    - containerPort: {{ .containerPort | default 80 }}
      {{- if .protocol }}
      protocol: {{ .protocol }}
      {{- end }}
      {{- if .name }}
      name: {{ .name }}
    {{- end }}
  {{- end }}
  {{- else }}
  ports:
    - containerPort: {{ if .port }}{{ .port | default 80}}{{ else }}80{{ end }}
      protocol: TCP
      name: http
  {{- end }}
  {{- with .volumes }}
  volumeMounts:
  {{- range . }}
  - name: {{ .name }}
    mountPath: {{ .mountPath }}
    {{- if .readOnly }}
    readOnly: true
    {{- end }}
  {{- end }}
  {{- end }}
  {{- with .resources }}
  resources:
    {{- toYaml . | nindent 12 }}
  {{- end }}
{{- end }}


{{/*
Helper template for volumes, to avoid duplication due to having both a simplified and a full
container list spec option for the user
*/}}
{{- define "generic-microservice.deployment_containers_volumes" -}}
{{- with .volumes }}
volumes:
{{- range . }}
- name: {{ .name }}
  {{- .type | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
