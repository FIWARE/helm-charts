# onboarding-portal changelog

## 1.3.0

### Common library chart migration

The chart now depends on the FIWARE `common` library chart
(`charts/common`). The shared name / label / selector helpers and the
`Service` resource template are now thin `include` calls of the
matching `common.*` helper:

- `Chart.yaml` — bumped `version` 1.2.6 → 1.3.0 and added the
  `common` entry under `dependencies` (sourced from the published
  FIWARE helm repository, packaged into the resulting
  `onboarding-portal-<version>.tgz`).
- `templates/_helpers.tpl` — `onboarding.name`, `onboarding.fullname`,
  `onboarding.chart`, `onboarding.labels` and
  `onboarding.selectorLabels` now delegate to `common.names.*` and
  `common.labels.*`. The `onboarding.*` names are preserved so any
  external umbrella chart that imports them keeps working (a future
  major release will drop the wrappers per
  `charts/common/DEPRECATIONS.md`).
- `templates/service.yaml` → one-line `common.service.tpl` call.
- `templates/deployment.yaml`, `templates/configmap.yaml`,
  `templates/pvc.yaml` and `templates/ingress.yaml` are intentionally
  **not** migrated:
  - `deployment.yaml` carries onboarding-portal-specific container,
    env, configmap-volume, PVC-volume and probe configuration that
    has no counterpart in the `common` helper surface.
  - `configmap.yaml` renders the bespoke `application.yaml` from
    `.Values.config`.
  - `pvc.yaml` is a small bespoke `PersistentVolumeClaim` body.
  - `ingress.yaml` uses the `.Values.ingress.hosts[].paths` schema
    with per-path `{path, pathType}` objects, while
    `common.ingress.tpl` expects a list of plain strings and
    hard-codes `pathType: Prefix`. Migrating to the common helper
    would silently drop per-path `pathType` overrides, which is a
    breaking change for users — the ticket explicitly asks for a
    minimally breaking migration, so the ingress body is kept as-is.
  These four templates continue to reference `onboarding.fullname`,
  `onboarding.name`, `onboarding.labels` and `onboarding.selectorLabels`,
  all of which are now wrappers around the common helpers.

### Breaking changes

1. **Explicit `metadata.namespace` on the rendered `Service`** —
   `common.service.tpl` emits `metadata.namespace:
   {{ .Release.Namespace }}` whereas the legacy `templates/service.yaml`
   relied on the implicit install-namespace. The rendered field value
   matches the install namespace for any standard `helm install`/
   `helm upgrade`, so this is a render-shape change only and does not
   move the resource between namespaces.

No other behavioural change. Service selector labels, the
`Deployment`, `Ingress`, `ConfigMap` and `PVC` are byte-identical to
the pre-migration render.

### Non-breaking cosmetic changes

- The leading blank line inside the labels block on the rendered
  `Service` (a side-effect of the legacy `{{ include
  "onboarding.labels" . | nindent 4 }}` pattern) is gone —
  `common.labels.standard` emits labels without a leading blank.
  The chart-local `Deployment`, `ConfigMap`, `PVC` and `Ingress`
  templates still carry the blank line because they were not
  migrated in this pass.

### Upgrade path

`helm upgrade` of an existing release is a no-op for the
Service / Deployment selector pair (selector labels are unchanged),
and a standard field update for the `Service` (adds
`metadata.namespace`, drops one leading blank line). No data
migration is required.
