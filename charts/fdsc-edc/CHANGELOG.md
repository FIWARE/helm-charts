# fdsc-edc changelog

## 0.2.0

### Common library chart migration

The chart now depends on the local `common` library chart
(`charts/common`). The migration is **scoped** to the portions that
preserve render parity byte-for-byte. Every per-deployment resource
template (`service.yaml`, `ingress.yaml`, `deployment.yaml`,
`config-map.yaml`) stays chart-local because those templates iterate
over `.Values.deployment` and use non-canonical selector labels of the
form `app.kubernetes.io/name: <fullname>-<deployment>` which cannot be
changed without breaking `helm upgrade` on existing releases (selectors
are immutable). Migrating those bodies is deferred to a future
major-version bump under the deprecation mechanism described in
`charts/common/DEPRECATIONS.md`.

Files touched in this release:

- `Chart.yaml` — bumped `apiVersion` v1→v2 (required to declare the
  `common` dependency), `version` 0.1.8→0.2.0. Added the `common`
  entry under `dependencies`, pulled from `file://../common`.
- `templates/_helpers.tpl` — `fdsc-edc.name`, `fdsc-edc.fullname`,
  `fdsc-edc.chart`, `fdsc-edc.serviceAccountName` and `fdsc-edc.labels`
  now delegate to `common.names.*`, `common.serviceAccount.name` and
  `common.labels.standard`. The `<chart>.*` names are preserved so any
  external umbrella chart that imports them keeps working (a future
  major release will drop the wrappers per
  `charts/common/DEPRECATIONS.md`).
- `templates/serviceaccount.yaml` → `common.serviceAccount.tpl`.
- `.gitignore` — excludes the resolved `Chart.lock` and the `charts/`
  sub-directory (`common-<version>.tgz` is pulled in by
  `helm dependency update` on install / publish and does not need to
  live in git).

Files intentionally **not** migrated:

- `templates/service.yaml`, `templates/ingress.yaml`,
  `templates/deployment.yaml` and `templates/config-map.yaml` — these
  iterate over `.Values.deployment` (a map of named deployments) and
  use non-canonical labels of the form
  `app.kubernetes.io/name: <fullname>-<component>`. Migrating them to
  `common.service.tpl` / `common.ingress.tpl` would require changing
  the Deployment's `spec.selector.matchLabels` in lock-step, which
  breaks `helm upgrade` on any existing release (Kubernetes selectors
  are immutable). The `config-map.yaml` body is also chart-specific
  (it renders a bespoke `dataspaceconnector-configuration.properties`)
  and has no counterpart in the `common` helper surface.

### Breaking changes

1. **Explicit `metadata.namespace` on the ServiceAccount** — the
   `common.serviceAccount.tpl` body emits
   `namespace: {{ .Release.Namespace | quote }}`. The legacy
   `serviceaccount.yaml` did not render this key. This matches the
   convention used elsewhere in the chart (`service.yaml`,
   `ingress.yaml`, `deployment.yaml` and `config-map.yaml` all
   already emit the explicit namespace). It does not change where the
   resource is deployed.

2. **ServiceAccount resource name honours `.Values.serviceAccount.name`**
   — the legacy `templates/serviceaccount.yaml` hard-coded
   `metadata.name: {{ include "fdsc-edc.fullname" . }}` and ignored
   `.Values.serviceAccount.name`. `common.serviceAccount.tpl` uses
   `common.serviceAccount.name`, which applies
   `.Values.serviceAccount.name` as an override. Concretely, a release
   with `serviceAccount.create: true` and
   `serviceAccount.name: custom-sa` now renders a ServiceAccount named
   `custom-sa` instead of `<fullname>`. The pod spec's
   `serviceAccountName` already resolved to `custom-sa` via
   `fdsc-edc.serviceAccountName`, so this is a bug fix — the
   ServiceAccount's own name now agrees with what the pod spec
   expects.

### Non-breaking cosmetic changes to rendered output

- The blank leading line inside the labels block (a side-effect of the
  legacy `{{ include "fdsc-edc.labels" . | nindent 4 }}` pattern) is
  gone from the ServiceAccount manifest — `common.serviceAccount.tpl`
  emits labels without a leading blank. The same cosmetic delta
  applies to the `annotations:` block on the ServiceAccount when
  `.Values.serviceAccount.annotations` is set (the legacy body used
  the same `{{ toYaml ... | nindent 4 }}` pattern). The chart-local
  templates (`service.yaml` / `ingress.yaml` / `deployment.yaml` /
  `config-map.yaml`) still carry their existing whitespace because
  they were not migrated.

All of the above are cosmetic and do not alter the runtime behaviour
of any resource.

### Upgrade path

`helm upgrade` of an existing release is a standard field update for
the ServiceAccount resource (adding `metadata.namespace` and, if
`.Values.serviceAccount.name` is set, renaming the ServiceAccount) and
a no-op for every other manifest. No data migration is required.
