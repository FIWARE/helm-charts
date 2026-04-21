# mintaka changelog

## 0.6.0

### Common library chart migration

The chart now depends on the local `common` library chart
(`charts/common`, introduced in ticket-9 steps 1–6). Every helper and
every resource template previously duplicated in this chart is now a
thin `include` of the matching `common.*` helper:

- `Chart.yaml` — bumped `apiVersion` v1→v2 (required to declare the
  `common` dependency), `version` 0.4.2→0.6.0. Added
  `kubeVersion: '>= 1.19-0'` (matching orion / keyrock) and the
  `common` entry under `dependencies`.
- `templates/_helpers.tpl` — `mintaka.name`, `mintaka.fullname`,
  `mintaka.chart`, `mintaka.serviceAccountName` and `mintaka.labels`
  now delegate to `common.names.*`, `common.serviceAccount.name` and
  `common.labels.standard`. The `<chart>.*` names are preserved so any
  external umbrella chart that imports them keeps working (a future
  major release will drop the wrappers per
  `charts/common/DEPRECATIONS.md`, scheduled in Step 11 of the
  ticket-9 plan).
- `templates/service.yaml` → `common.service.tpl`.
- `templates/ingress.yaml` → `common.ingress.tpl`.
- `templates/route.yaml` → `common.route.tpl`.
- `templates/serviceaccount.yaml` → `common.serviceAccount.tpl`.
- `templates/secret.yaml` → `common.secret.tpl`.
- `templates/deployment-hpa.yaml` → `common.hpa.tpl`.
- `templates/deployment.yaml` is intentionally **not** migrated — it
  contains mintaka-specific container / env / probe configuration
  that has no counterpart in the `common` helper surface. The
  deployment continues to reference `mintaka.fullname`, `mintaka.name`,
  `mintaka.labels` and `mintaka.serviceAccountName`, all of which are
  now wrappers around the common helpers.
- `.gitignore` — new file excluding the resolved `Chart.lock` and the
  `charts/` sub-directory (`common-<version>.tgz` is pulled in by
  `helm dependency update` on install / publish and does not need to
  live in git).

### Breaking changes

1. **`autoscaling.apiVersion` default** — a new `apiVersion` key has
   been added under `.Values.autoscaling` with a default of
   `"v2beta2"`, matching the value previously hard-coded in the
   legacy `deployment-hpa.yaml` body. Users who already set
   `.Values.autoscaling.apiVersion` are unaffected; users on
   Kubernetes 1.26+ may wish to override it to `"v2"`.

### Non-breaking cosmetic changes to rendered output

- The blank leading line inside the labels block (a side-effect of
  the legacy `{{ include "mintaka.labels" . | nindent 4 }}` pattern)
  is gone from the Service / Secret / HPA / ServiceAccount / Ingress /
  Route manifests — `common.*` helpers emit labels without a leading
  blank. The `Deployment` manifest still carries the blank line
  because `deployment.yaml` was not migrated in this step.
- Base64 Secret values are now emitted as single-line `key: <base64>`
  scalars rather than inside a block-scalar wrapper; both decode to
  identical bytes.
- HPA `metrics:` list items are indented by 4 spaces rather than 2.
  YAML-equivalent.

All of the above are cosmetic and do not alter the runtime behaviour
of any resource.

### Upgrade path

`helm upgrade` of an existing release should be a no-op for the
Service / Deployment selector pair (selector labels are unchanged),
and a standard field update for the Ingress / Secret / HPA /
ServiceAccount manifests. No data migration is required.
