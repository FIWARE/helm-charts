{{/* vim: set filetype=mustache: */}}
{{/*
Image helpers for the FIWARE `common` library chart.

Renders the three image-related fragments that every FIWARE chart
currently inlines in its deployment / statefulset template:

  image: "<repository>:<tag>"
  imagePullPolicy: <policy>
  imagePullSecrets:
    - name: ...

Call convention (always dict form — helpers cannot guess which of the
many per-chart `.image` blocks to look at):

  {{- include "fiwareCommon.images.image" (dict "context" $ "image" .Values.deployment.image) }}
  {{- include "fiwareCommon.images.pullPolicy" (dict "image" .Values.deployment.image) }}
  {{- include "fiwareCommon.images.pullSecrets" (dict "pullSecrets" .Values.imagePullSecrets) | nindent 6 }}

Accepted shape of the `image` block (the FIWARE convention):

  image:
    repository: string    (required)
    tag:        string    (optional, falls back to .Chart.AppVersion)
    pullPolicy: string    (optional, defaults to "IfNotPresent")

The helpers deliberately render the minimal string the caller asks for
(no leading indentation, no trailing newline) so the consumer controls
placement. Use `| nindent N` at the call site when multi-line output is
embedded in a surrounding YAML block.
*/}}

{{/*
fiwareCommon.images.image

Render the `repository:tag` fragment for a container image. The tag
defaults to `.Chart.AppVersion` when `image.tag` is empty, matching the
`{{ .Values.image.tag | default .Chart.AppVersion }}` idiom found in
onboarding-portal, did-helper, odrl-pap, etc. Charts that have always
set `image.tag` explicitly (orion, keyrock, mintaka) are byte-compatible
because their values.yaml pins a tag.

Arguments (dict):
  context - root context, used only for `.Chart.AppVersion` fallback.
  image   - the image sub-map (map with `.repository` and optional
            `.tag`), required.
*/}}
{{- define "fiwareCommon.images.image" -}}
{{- $ctx := .context -}}
{{- $image := required "fiwareCommon.images.image: image is required" .image -}}
{{- $repository := required "fiwareCommon.images.image: image.repository is required" $image.repository -}}
{{- $tag := default $ctx.Chart.AppVersion $image.tag -}}
{{- printf "%s:%s" $repository (toString $tag) -}}
{{- end -}}

{{/*
fiwareCommon.images.pullPolicy

Render the pull-policy string for a container image. Returns
`image.pullPolicy` when set, otherwise the Kubernetes default
`IfNotPresent`.

Arguments (dict):
  image - the image sub-map (map with optional `.pullPolicy`), required.
*/}}
{{- define "fiwareCommon.images.pullPolicy" -}}
{{- $image := required "fiwareCommon.images.pullPolicy: image is required" .image -}}
{{- default "IfNotPresent" $image.pullPolicy -}}
{{- end -}}

{{/*
fiwareCommon.images.pullSecrets

Render the `imagePullSecrets:` block when one or more pull secrets are
configured. Accepts the two shapes currently used in FIWARE charts:

  imagePullSecrets:
    - name: my-registry-secret
    - name: another-secret

or, equivalently, a list of bare strings:

  imagePullSecrets:
    - my-registry-secret

The helper normalises both into the Kubernetes canonical form
(`- name: <secret>`). When `pullSecrets` is empty or absent, renders
nothing — the consumer's deployment template can unconditionally
`include` this helper without an `if` guard.

Arguments (dict):
  pullSecrets - list of secrets (list of strings and/or
                `{name: <string>}` maps).

The caller is expected to indent the output (usually `| nindent 8`)
because the surrounding `spec:` block lives at various depths.
*/}}
{{- define "fiwareCommon.images.pullSecrets" -}}
{{- $pullSecrets := .pullSecrets -}}
{{- if $pullSecrets -}}
imagePullSecrets:
{{- range $pullSecrets }}
{{- if kindIs "string" . }}
  - name: {{ . }}
{{- else if and (kindIs "map" .) .name }}
  - name: {{ .name }}
{{- end }}
{{- end }}
{{- end -}}
{{- end -}}
