# trusted-issuers-list changelog

## 0.18.0

### Common library chart migration

The chart now depends on the local `common` library chart
(`charts/common`, introduced in ticket-9 steps 1–6). The seven
canonical helpers and the mechanical Kubernetes resource templates
that have a matching `common.*` equivalent are now thin `include`
calls of the library helper:

- `Chart.yaml` — bumped `apiVersion` v1→v2 (required to declare the
  `common` dependency), `version` 0.16.2→0.18.0. Added the `common`
  entry under `dependencies` (`repository: "file://../common"`,
  `version: "0.0.2"`) so publishing workflows do not need a separate
  repository entry — Helm packages the library alongside the chart in
  the resulting `trusted-issuers-list-<version>.tgz`.
- `templates/_helpers.tpl` — `til.name`, `til.fullname`, `til.chart`,
  `til.serviceAccountName`, `til.labels`, `til.secretName` and
  `til.passwordKey` now delegate to `common.names.*`,
  `common.serviceAccount.name`, `common.labels.standard`,
  `common.secrets.name` and `common.secrets.key`. The `til.*` names
  are preserved so any external umbrella chart that imports them
  keeps working (a future major release will drop the wrappers per
  `charts/common/DEPRECATIONS.md`, scheduled in Step 11 of the
  ticket-9 plan).
- `templates/serviceaccount.yaml` → `common.serviceAccount.tpl`.
- `templates/secret.yaml` → `common.secret.tpl` (gated on
  `.Values.database.existingSecret.enabled` so the chart still skips
  rendering its own Secret when an existing one is referenced).
- `templates/deployment-hpa.yaml` → `common.hpa.tpl`.
- `.gitignore` — introduced in Step 1 to exclude the resolved
  `Chart.lock` and the `charts/` sub-directory
  (`common-<version>.tgz` is pulled in by `helm dependency update` on
  install / publish and does not need to live in git).

### Templates intentionally not migrated

The following templates stay chart-local because they have no clean
mapping onto the current `common.*` helper surface. Their helper
calls are still routed through the preserved `til.*` wrappers, which
transparently delegate to `common.*`:

- `templates/service.yaml` — honours the chart-specific
  `til.serviceName` helper (which consumes
  `.Values.service.serviceNameOverride`); the common `service.tpl`
  uses `common.names.fullname` unconditionally.
- `templates/ingress-til.yaml`, `templates/ingress-tir.yaml` — two
  per-endpoint Ingress resources with hard-coded paths (`/issuer` and
  `/v4/issuers`) and `-til` / `-tir` name suffixes; the common
  `ingress.tpl` renders a single, user-defined path set.
- `templates/route-til.yaml`, `templates/route-tir.yaml` — same
  per-endpoint shape as the Ingresses, plus OpenShift-specific
  routing; no common helper yet.
- `templates/route-til-certificate.yaml`,
  `templates/route-tir-certificate.yaml` — cert-manager `Certificate`
  CRs tied to the per-endpoint Routes; no common helper.
- `templates/deployment.yaml` — contains chart-specific container /
  env / probe wiring (including the `til.app.config` render) that
  has no counterpart in the `common` surface.
- `templates/til-configmap.yaml` — chart-specific application
  configuration ConfigMap.
- `templates/initdata-cm.yaml`,
  `templates/post-hook-initdata.yaml` — chart-specific init Job and
  the ConfigMap it consumes.

### Breaking changes

See `docs/common-chart.md#breaking-changes` for the full common-chart
breaking-change list.

1. **Explicit `metadata.namespace` on the rendered manifests** — the
   Secret, HorizontalPodAutoscaler and ServiceAccount produced by
   `common.*` helpers now set `metadata.namespace:
   {{ .Release.Namespace }}` explicitly, matching the rest of the
   FIWARE chart family. Previously the chart omitted the field and
   relied on Helm to inject the release namespace at install time.
   Both rendered outputs install into the same namespace; the
   difference is only visible in `helm template` / `helm get
   manifest` output and in static policy tooling that reads the YAML
   directly.

2. **`autoscaling.apiVersion` surfaced as a values key** — a new
   `apiVersion` key has been added under `.Values.autoscaling`, with
   a default of `"v2beta2"` that matches the value previously
   hard-coded in the legacy `deployment-hpa.yaml` body. Users who
   already set `.Values.autoscaling.apiVersion` are unaffected; users
   on Kubernetes 1.26+ may wish to override it to `"v2"`. The default
   preserves byte-for-byte parity with the pre-migration manifest.

3. **ServiceAccount resource name honours
   `.Values.serviceAccount.name`** — the legacy
   `templates/serviceaccount.yaml` hard-coded
   `metadata.name: {{ include "til.fullname" . }}` and ignored
   `.Values.serviceAccount.name`. The new
   `common.serviceAccount.tpl` uses `common.serviceAccount.name`,
   which applies `.Values.serviceAccount.name` as an override (same
   helper that already drove `serviceAccountName` on the Deployment
   pod spec). Concretely, a release with `serviceAccount.create:
   true` and `serviceAccount.name: custom-sa` now renders a
   ServiceAccount named `custom-sa` instead of `<fullname>`.

### Non-breaking cosmetic changes to rendered output

- The blank leading line inside the labels block (a side-effect of
  the legacy `{{ include "til.labels" . | nindent 4 }}` pattern) is
  gone from the Secret / HPA / ServiceAccount manifests — `common.*`
  helpers emit labels without a leading blank. The Service,
  Ingresses, Routes, Deployment and the cert-manager Certificates
  still carry the blank line because those templates were not
  migrated in this release.
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
and a standard field update for the Secret / HPA / ServiceAccount
manifests. No data migration is required.
