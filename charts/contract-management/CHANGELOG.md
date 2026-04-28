# contract-management changelog

## 3.5.23

### Common library chart migration

The chart now depends on the local `common` library chart
(`charts/common`) and delegates every shared helper and the Service /
ServiceAccount resource bodies to it. The five core helpers remain
defined in `templates/_helpers.tpl` as thin `include` wrappers so any
external umbrella chart that already imports
`contract.name` / `contract.fullname` / `contract.chart` /
`contract.serviceAccountName` / `contract.labels` keeps working
unchanged.

- `Chart.yaml` — bumped `apiVersion` v1→v2 (required to declare the
  `common` dependency), `version` 3.5.22→3.5.23. Added
  `kubeVersion: '>= 1.19-0'` (matching orion / keyrock / mintaka) and
  the `common` entry under `dependencies`.
- `templates/_helpers.tpl` — `contract.name`, `contract.fullname`,
  `contract.chart`, `contract.serviceAccountName` and
  `contract.labels` now delegate to `common.names.*`,
  `common.serviceAccount.name` and `common.labels.standard`. The
  `contract.secretName` / `contract.passwordKey` helpers are kept
  verbatim — their `.Values.database.existingSecret.enabled` gate has
  no equivalent in `common.secrets.name`.
- `templates/service.yaml` → `common.service.tpl`.
- `templates/serviceaccount.yaml` → `common.serviceAccount.tpl`.
- `templates/deployment.yaml` and `templates/configmap.yaml` are
  intentionally **not** migrated — they contain chart-specific
  container / env / probe / application.yaml configuration that has no
  counterpart in the `common` helper surface. Both continue to
  reference `contract.fullname`, `contract.name` and `contract.labels`,
  all of which are now wrappers around the common helpers.

### Breaking changes

1. **ServiceAccount resource name honours `.Values.serviceAccount.name`**
   — the legacy `templates/serviceaccount.yaml` hard-coded
   `metadata.name: {{ include "contract.fullname" . }}` and ignored
   `.Values.serviceAccount.name`. The new `common.serviceAccount.tpl`
   uses `common.serviceAccount.name`, which applies
   `.Values.serviceAccount.name` as an override (same helper that
   already drives `serviceAccountName` on the Deployment pod spec).
   Concretely, a release with `serviceAccount.create: true` and
   `serviceAccount.name: custom-sa` now renders a ServiceAccount named
   `custom-sa` instead of `<fullname>`. Default installs
   (`serviceAccount.create: false`) are unaffected — no ServiceAccount
   is emitted.

### Non-breaking cosmetic changes to rendered output

- The blank leading line inside the labels block (a side-effect of
  the legacy `{{ include "contract.labels" . | nindent 4 }}` pattern)
  is gone from the Service / ServiceAccount manifests — `common.*`
  helpers emit labels without a leading blank. The `Deployment` and
  `ConfigMap` manifests still carry the blank line because those
  templates were not migrated in this step.
- The Service selector now carries the full match-label pair emitted
  by `common.labels.matchLabels`; the rendered key/value pairs are
  identical to the pre-migration inline selector.

All of the above are cosmetic and do not alter the runtime behaviour
of any resource.

### Upgrade path

`helm upgrade` of an existing release is a no-op for the
Service / Deployment selector pair (selector labels are unchanged),
and a standard metadata update for the ServiceAccount manifest (only
rendered when `serviceAccount.create: true`). No data migration is
required.
