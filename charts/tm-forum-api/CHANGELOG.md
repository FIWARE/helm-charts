# tm-forum-api changelog

## 0.17.0

### Common library chart migration

The chart now depends on the local `common` library chart
(`charts/common`, introduced in ticket-9 steps 1–6). The migration is
narrower than the orion / keyrock / mintaka ones because
tm-forum-api's `service.yaml`, `ingress.yaml`, `route.yaml`,
`route-certificate.yaml`, `envoy.yaml`, `envoy-service.yaml`,
`envoy-configmap.yaml`, `deploy-all-in-one.yaml` and
`deployment.yaml` all iterate over `.Values.apis` to emit one
resource per API (and the Envoy templates carry sidecar-specific
bodies); none of those shapes fits the single-resource bodies
produced by `common.service.tpl` / `common.ingress.tpl` /
`common.route.tpl` / etc. Only the helpers and the ServiceAccount
template are migrated:

- `Chart.yaml` — added `common` under `dependencies` (consumed via a
  local-repository entry so publishing workflows do not need a
  separate repository entry — Helm packages the library alongside the
  consumer chart in the resulting `tm-forum-api-<version>.tgz`).
  Bumped `version: 0.16.16 → 0.17.0` (minor bump: new dependency and
  one breaking render delta on the ServiceAccount resource). The
  existing `redis` dependency is preserved unchanged. `apiVersion`
  was already `v2`, so no apiVersion bump was needed.
- `templates/_helpers.tpl` — `tmforum.name`, `tmforum.fullname`,
  `tmforum.chart`, and `tmforum.serviceAccountName` now delegate to
  `common.names.name`, `common.names.fullname`, `common.names.chart`
  and `common.serviceAccount.name`. The `tmforum.*` names are
  preserved so any external umbrella chart that imports them keeps
  working (per `docs/common-chart.md` "Non-goals: Changing chart
  prefixes"); the `tmforum` prefix is intentionally different from
  the chart name `tm-forum-api`.

  `tmforum.labels` is intentionally **kept as a chart-local 3-label
  subset** (`helm.sh/chart`, `app.kubernetes.io/version`,
  `app.kubernetes.io/managed-by`) and does NOT delegate to
  `common.labels.standard`. Rationale:
  `common.labels.standard` emits the canonical 5-label set (adds
  `app.kubernetes.io/name` and `app.kubernetes.io/instance`).
  tm-forum-api's `templates/deployment.yaml`,
  `templates/service.yaml`, `templates/deploy-all-in-one.yaml`,
  `templates/envoy.yaml` and `templates/envoy-service.yaml` already
  emit per-API
  `app.kubernetes.io/name: <fullname>-<api-name>` and
  `app.kubernetes.io/instance: <release>` immediately before each
  `tmforum.labels` include. Switching `tmforum.labels` to the 5-label
  set would yield duplicate map keys whose last-wins semantics would
  override the per-API name with the chart-level name and break
  selector matching across every per-API Deployment. The
  `helm.sh/chart` line in `tmforum.labels` continues to flow through
  `tmforum.chart`, which is itself a wrapper around
  `common.names.chart`, so the canonical chart-and-version
  formatting still lives in the `common` library chart.
- `templates/serviceaccount.yaml` — replaced with a one-line
  `common.serviceAccount.tpl` include
  (`{{- include "common.serviceAccount.tpl" (dict "context" $) -}}`).

The following templates are intentionally **not** migrated; they
continue to reference `tmforum.fullname`, `tmforum.name`,
`tmforum.labels` and `tmforum.serviceAccountName`, all of which are
now wrappers around the common helpers:

- `templates/service.yaml`, `templates/ingress.yaml`,
  `templates/route.yaml`, `templates/route-certificate.yaml`,
  `templates/deployment.yaml`, `templates/deploy-all-in-one.yaml` —
  each one `range`s over `.Values.apis` to render one resource per
  API; `common.service.tpl` / `common.ingress.tpl` /
  `common.route.tpl` produce a single resource and have no
  per-API-iteration mode.
- `templates/envoy.yaml`, `templates/envoy-service.yaml`,
  `templates/envoy-configmap.yaml` — Envoy sidecar Deployment /
  Service / static-resources ConfigMap; chart-specific bodies with
  no counterpart on the common helper surface.

### Breaking changes

1. **ServiceAccount resource name honours `.Values.serviceAccount.name`**
   — the legacy `templates/serviceaccount.yaml` hard-coded
   `metadata.name: {{ include "tmforum.fullname" . }}` and ignored
   `.Values.serviceAccount.name`. The new `common.serviceAccount.tpl`
   uses `common.serviceAccount.name`, which applies
   `.Values.serviceAccount.name` as an override (same helper that
   already drove `serviceAccountName` on the per-API Deployment pod
   specs). Concretely, a release with `serviceAccount.create: true`
   and `serviceAccount.name: custom-sa` now renders a ServiceAccount
   named `custom-sa` instead of `<fullname>`. This is almost
   certainly a bug fix — the legacy combination left the per-API
   Deployments referencing `custom-sa` while the actual
   ServiceAccount resource was named `<fullname>`, so pods would fail
   to mount the intended SA — but it is a change in the rendered
   manifest and is called out here. Releases that did not set
   `serviceAccount.name` are unaffected (cross-references item 4 in
   `docs/common-chart.md` "Breaking changes").

### Non-breaking cosmetic changes to rendered output

- The blank leading line inside the `labels:` block on
  `templates/serviceaccount.yaml` (a side-effect of the legacy
  `{{ include "tmforum.labels" . | nindent 4 }}` pattern) is gone —
  `common.serviceAccount.tpl` emits labels without a leading blank.
  The blank line is still present on every other rendered manifest
  (per-API Service / Ingress / Route / Deployment, Envoy resources,
  the all-in-one Deployment) because those templates were not
  migrated and continue to use the `nindent`-based pattern.
- The ServiceAccount's `metadata.labels` map expands from the
  chart-local 3-label subset (`helm.sh/chart`,
  `app.kubernetes.io/version`, `app.kubernetes.io/managed-by`) to
  the canonical 5-label set emitted by `common.labels.standard`
  (adds `app.kubernetes.io/name` and `app.kubernetes.io/instance`).
  This is a direct consequence of `common.serviceAccount.tpl`
  rendering its own `labels:` block via `common.labels.standard`
  rather than the chart-local `tmforum.labels` helper. The
  expansion is non-functional: the SA's `metadata.labels` are
  metadata-only and are not consumed as a selector by any other
  resource in the chart, so the two extra metadata keys cannot
  change pod scheduling, service routing or selector matching. The
  chart-local `tmforum.labels` body itself is unchanged (still the
  3-label subset used by per-API Deployments / Services / Ingresses,
  where the duplicate-key risk discussed above applies); only the
  ServiceAccount resource — which is rendered by the common helper,
  not by an inline `tmforum.labels` include — picks up the canonical
  5-label set.
- Every rendered resource now carries
  `helm.sh/chart: tm-forum-api-0.17.0` instead of
  `tm-forum-api-0.16.16` — the universal label-propagation effect of
  the chart-version bump. This is not a migration regression; it is
  the expected consequence of any minor-version bump.

All of the above are cosmetic and do not alter the runtime behaviour
of any resource.

### Upgrade path

`helm upgrade` of an existing release should be a no-op for the
per-API Service / Deployment selector pairs (selector labels are
unchanged — they are emitted by the chart-local templates which were
not migrated), and a standard metadata update for the
ServiceAccount resource (the new `metadata.name` honours
`.Values.serviceAccount.name`, and `metadata.labels` gains the two
canonical `app.kubernetes.io/name` and `app.kubernetes.io/instance`
keys). No data migration is required.
