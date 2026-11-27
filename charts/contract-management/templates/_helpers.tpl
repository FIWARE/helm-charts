
{{/* vim: set filetype=mustache: */}}
{{/*
contract-management-specific helpers.

The five core helpers in this file are now thin wrappers around the
matching `fiwareCommon.*` helper from the `common` library chart (see
charts/common/templates/*.tpl). The wrappers exist so that:

  * Any external umbrella chart that already imports e.g.
    `include "contract.fullname" .` keeps working — no external
    breaking change.
  * The bodies below stay in lock-step with the rest of the FIWARE
    charts, because there is exactly one implementation of each
    helper (in `common`).

See docs/common-chart-proposal.md for the migration rationale and the
planned deprecation window. Removal of the wrappers is scheduled as a
future major version bump (see charts/common/DEPRECATIONS.md).

The `contract.secretName` / `contract.passwordKey` helpers below use a
chart-specific `.Values.database.existingSecret.enabled` gate that is
not expressible in `fiwareCommon.secrets.name` / `fiwareCommon.secrets.key` (the
library helpers use a truthy-`existingSecret` gate instead). They are
retained verbatim for backwards compatibility with any external caller
that already relies on this shape.
*/}}

{{/*
Expand the name of the chart. Delegates to `fiwareCommon.names.name`.
*/}}
{{- define "contract.name" -}}
{{- include "fiwareCommon.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name. Delegates to
`fiwareCommon.names.fullname`.
*/}}
{{- define "contract.fullname" -}}
{{- include "fiwareCommon.names.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label. Delegates to
`fiwareCommon.names.chart`.
*/}}
{{- define "contract.chart" -}}
{{- include "fiwareCommon.names.chart" . -}}
{{- end -}}

{{/*
Create the name of the service account to use. Delegates to
`fiwareCommon.serviceAccount.name`.
*/}}
{{- define "contract.serviceAccountName" -}}
{{- include "fiwareCommon.serviceAccount.name" . -}}
{{- end -}}

{{/*
Common labels. Delegates to `fiwareCommon.labels.standard`.
*/}}
{{- define "contract.labels" -}}
{{- include "fiwareCommon.labels.standard" . -}}
{{- end -}}

{{/*
Support for an existing database secret. Preserved verbatim from the
pre-migration helper because it uses a chart-specific `.enabled` gate
(not supported by `fiwareCommon.secrets.name`, which treats any truthy
`existingSecret` value as "override active").
*/}}
{{- define "contract.secretName" -}}
    {{- if .Values.database.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.database.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "contract.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "contract.passwordKey" -}}
    {{- if and (.Values.database.existingSecret.enabled) (.Values.database.existingSecret.key) -}}
        {{- printf "%s" (tpl .Values.database.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}

{{/*
Directory the data space events ConfigMap is mounted at. Mounted without subPath, so updates reach the pod.
*/}}
{{- define "contract.dataspaceEvents.mountPath" -}}
/dataspace-events
{{- end -}}

{{/*
Key and file name of the data space events configuration inside the ConfigMap and the mount.
*/}}
{{- define "contract.dataspaceEvents.fileName" -}}
dataspace-events.yaml
{{- end -}}

{{/*
Name of the data space events ConfigMap.
*/}}
{{- define "contract.dataspaceEvents.configMapName" -}}
{{- printf "%s-dataspace-events" (include "contract.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
"true" when listener, publisher or subscriber is enabled, otherwise empty; gates every eventing resource.
*/}}
{{- define "contract.dataspaceEvents.enabled" -}}
{{- $events := .Values.dataspace.events | default dict -}}
{{- if or (dig "listener" "enabled" false $events) (dig "publisher" "enabled" false $events) (dig "subscriber" "enabled" false $events) -}}
true
{{- end -}}
{{- end -}}

{{/*
The `dataspace.events` tree as rendered, as YAML. `listener.watch.enabled` and `.path` default to the mount;
user-set keys win, including `false` (hasKey, since merge/mergeOverwrite drop zero values).
*/}}
{{- define "contract.dataspaceEvents.config" -}}
{{- $events := deepCopy (.Values.dataspace.events | default dict) -}}
{{- $listener := get $events "listener" | default dict -}}
{{- $watch := get $listener "watch" | default dict -}}
{{- if not (hasKey $watch "enabled") -}}
{{- $_ := set $watch "enabled" true -}}
{{- end -}}
{{- if not (hasKey $watch "path") -}}
{{- $_ := set $watch "path" (include "contract.dataspaceEvents.mountPath" .) -}}
{{- end -}}
{{- $_ := set $listener "watch" $watch -}}
{{- $_ := set $events "listener" $listener -}}
{{- toYaml $events -}}
{{- end -}}

{{/*
Checksum over the startup-only keys: the enabled flags, `listener.watch` and the publisher's sink timeouts.
A change to them rolls the pod; every other key reaches the running pod through the watch.
*/}}
{{- define "contract.dataspaceEvents.startupChecksum" -}}
{{- $events := include "contract.dataspaceEvents.config" . | fromYaml -}}
{{- $publisher := get $events "publisher" | default dict -}}
{{- $startup := dict
      "listener" (pick (get $events "listener") "enabled" "watch")
      "publisher" (pick $publisher "enabled" "sink-connect-timeout" "sink-read-timeout")
      "subscriber" (pick (get $events "subscriber" | default dict) "enabled")
      "tir-watcher" (pick (get $events "tir-watcher" | default dict) "enabled") -}}
{{- toYaml $startup | sha256sum -}}
{{- end -}}
