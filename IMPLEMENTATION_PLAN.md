# Implementation Plan: Update chart tm-forum-api to use common chart

## Overview

Migrate `charts/tm-forum-api` onto the in-repo `common` library chart following
the pattern already applied to `orion`, `keyrock`, and `mintaka` (see
`docs/common-chart.md`). Because tm-forum-api's `service.yaml`,
`ingress.yaml`, and `route.yaml` iterate over `.Values.apis` to emit one
resource per API — a shape that does not fit the single-resource bodies
produced by `common.service.tpl` / `common.ingress.tpl` / `common.route.tpl` —
the migration is narrower than the orion/mintaka ones: we replace the
**helpers** (`tmforum.name|fullname|chart|serviceAccountName|labels`) with
thin wrappers over `common.*`, and replace **only the ServiceAccount
template** with a single-line `include`. The per-API Service / Ingress /
Route templates keep their bodies but benefit indirectly because the
`tmforum.*` helpers they call now resolve through `common.*`. The migration
introduces no deliberate render deltas beyond those documented in
`docs/common-chart.md` under "Breaking changes" (in practice only the
ServiceAccount-name item applies to this chart).

## Steps

### Step 1: Add the `common` library chart as a dependency

**Files:** `charts/tm-forum-api/Chart.yaml`

- Append a `dependencies:` entry for `common` using the same form that
  `orion`, `keyrock`, and `mintaka` already use:

  ```yaml
  dependencies:
    - name: common
      repository: "https://fiware.github.io/helm-charts"
      version: "0.0.1"
    - name: redis
      version: 18.1.2
      repository: oci://registry-1.docker.io/bitnamicharts
      condition: redis.enabled
  ```

  Keep the existing `redis` dependency; only append `common`. (`apiVersion`
  is already `v2`, so no bump is needed there.)

- Bump `version: 0.16.16` → `0.17.0` (minor bump: new dependency and one
  breaking render delta on the ServiceAccount resource).

- Add a short comment above `dependencies:` explaining why `common` is
  used locally (mirrors the comment in `charts/orion/Chart.yaml`).

**Acceptance criteria:**

- `helm dependency update charts/tm-forum-api` succeeds and pulls
  `common-0.0.1.tgz` into `charts/tm-forum-api/charts/`.
- `./build.sh` exits 0.

### Step 2: Rewrite `_helpers.tpl` as thin wrappers over `common.*`

**File:** `charts/tm-forum-api/templates/_helpers.tpl`

Replace the five existing helper bodies with thin wrappers so any external
umbrella chart that `include`s `tmforum.fullname` / `tmforum.labels` / etc.
keeps working (per `docs/common-chart.md` Non-goals: "Changing chart
prefixes"). The prefix `tmforum` is deliberately kept different from the
chart name `tm-forum-api`.

- `tmforum.name` → `include "common.names.name" .`
- `tmforum.fullname` → `include "common.names.fullname" .`
- `tmforum.chart` → `include "common.names.chart" .`
- `tmforum.serviceAccountName` → `include "common.serviceAccount.name" .`
- `tmforum.labels` → **kept as the chart-local 3-label subset**
  (`helm.sh/chart` + `app.kubernetes.io/version` +
  `app.kubernetes.io/managed-by`). The `helm.sh/chart` value continues
  to flow through `tmforum.chart`, which is itself a wrapper around
  `common.names.chart`, so the canonical chart-and-version formatting
  still lives in the library chart.

  Why not delegate to `common.labels.standard`?
  `common.labels.standard` emits the canonical 5-label set (adds
  `app.kubernetes.io/name` and `app.kubernetes.io/instance`).
  tm-forum-api's `templates/deployment.yaml`, `templates/service.yaml`,
  `templates/deploy-all-in-one.yaml`, `templates/envoy.yaml`, and
  `templates/envoy-service.yaml` already emit per-API
  `app.kubernetes.io/name: <fullname>-<api-name>` and
  `app.kubernetes.io/instance: <release>` immediately before each
  `tmforum.labels` include. Delegating `tmforum.labels` to the 5-label
  set would yield duplicate map keys whose last-wins semantics would
  override the per-API name with the chart-level name and break
  selector matching across every per-API Deployment. This is the same
  multi-component caveat that prevents the per-API
  Service/Ingress/Route templates from being collapsed into
  `common.*.tpl` (see Overview).

Pattern to follow: `charts/mintaka/templates/_helpers.tpl` for the
four name-style wrappers. The opening `vim: set filetype=mustache`
comment is preserved. A top-of-file docstring (mirroring mintaka's)
explains that the four name helpers are now wrappers, that the
`tmforum` prefix is intentionally kept, and that `tmforum.labels` is
kept chart-local with the rationale above.

**Acceptance criteria:**

- `helm template charts/tm-forum-api` renders without template errors.
- `grep -rn "default .Chart.Name" charts/tm-forum-api/templates/_helpers.tpl`
  returns nothing — the wrapper bodies for `name`/`fullname` no longer
  copy the canonical logic.
- `helm template charts/tm-forum-api` renders byte-identical YAML to the
  pre-step-2 baseline (the `tmforum.labels` body intentionally stays a
  3-label subset so render parity is preserved).

### Step 3: Replace `serviceaccount.yaml` with `common.serviceAccount.tpl`

**File:** `charts/tm-forum-api/templates/serviceaccount.yaml`

Replace the entire body with a single line:

```yaml
{{- include "common.serviceAccount.tpl" (dict "context" $) -}}
```

This is the only standard-body template the chart ships that maps cleanly
onto the `common.*.tpl` helper surface. `service.yaml`, `ingress.yaml`,
`route.yaml`, `route-certificate.yaml`, `envoy*.yaml`,
`deploy-all-in-one.yaml`, and `deployment.yaml` are all kept chart-local
— their per-API `range` loops, Envoy-sidecar specifics, or all-in-one
branches do not fit the common single-resource helpers.

**Expected render delta** (documented in `docs/common-chart.md` §
Breaking changes item 4):

> ServiceAccount resource name now honours `.Values.serviceAccount.name`.
> Concretely, a release with `serviceAccount.create: true` and
> `serviceAccount.name: custom-sa` now renders a ServiceAccount named
> `custom-sa` instead of `<fullname>`. Releases that did not set
> `serviceAccount.name` are unaffected.

Two additional non-breaking cosmetic deltas appear on the
`templates/serviceaccount.yaml` output:

1. The blank leading line inside the `labels:` block is gone — see
   the "Non-breaking cosmetic changes" section of `docs/common-chart.md`.
2. The SA's `metadata.labels` map expands from the chart-local 3-label
   subset (`helm.sh/chart`, `app.kubernetes.io/version`,
   `app.kubernetes.io/managed-by`) to the canonical 5-label set
   emitted by `common.labels.standard` (adds `app.kubernetes.io/name`
   and `app.kubernetes.io/instance`). This is a direct consequence of
   `common.serviceAccount.tpl` rendering its own `labels:` block via
   `common.labels.standard` rather than the chart-local
   `tmforum.labels` helper. The expansion is non-functional: the SA's
   `metadata.labels` are not used as a selector by any other resource
   in the chart, so adding two extra metadata keys cannot change pod
   scheduling, service routing, or selector matching. The chart-local
   `tmforum.labels` body itself is unchanged (still the 3-label subset
   used by per-API Deployments / Services / Ingresses, where the
   duplicate-key risk discussed in step 2 applies); only the SA
   resource — which is rendered by the common helper, not by an
   inline `tmforum.labels` include — picks up the canonical 5-label
   set.

**Acceptance criteria:**

- `helm template charts/tm-forum-api --show-only templates/serviceaccount.yaml`
  renders a valid `v1/ServiceAccount` whose `metadata.name` matches
  `<fullname>` when `serviceAccount.name` is unset.
- Rendered manifest carries `metadata.namespace` explicitly (unchanged
  from legacy).

### Step 4: Render-parity verification and document deltas

**Files:** none edited in this step — verification only.

Run the canonical render-parity check used by every prior migration PR:

```
diff <(helm template tmforum charts/tm-forum-api@main) \
     <(helm template tmforum charts/tm-forum-api@<branch>)
```

Also run it with a non-default value set to exercise the SA rename path:

```
--set serviceAccount.name=custom-sa
```

The diff is expected to contain **only** these items:

1. `templates/serviceaccount.yaml` — rename from `<fullname>` to
   `custom-sa` when `serviceAccount.name` is set (documented breaking
   change #4).
2. `templates/serviceaccount.yaml` — the blank leading line inside
   `labels:` is gone (cosmetic).
3. `templates/serviceaccount.yaml` — `metadata.labels` gains
   `app.kubernetes.io/name` and `app.kubernetes.io/instance` (the SA
   now carries the canonical 5-label set produced by
   `common.labels.standard` instead of the chart-local 3-label
   `tmforum.labels` subset). Non-functional, since SA labels are not
   used as selectors by any other resource in the chart.

Any other diff hunk is a regression and must be fixed before merging.

**Acceptance criteria:**

- Render parity holds for the default values (empty diff).
- Render parity with `serviceAccount.name=custom-sa` shows only the
  documented SA-name delta plus the cosmetic labels-blank-line delta.

### Step 5: Add `CHANGELOG.md` entry for the chart

**File (new):** `charts/tm-forum-api/CHANGELOG.md`

Model the file on `charts/mintaka/CHANGELOG.md`:

- Heading `## 0.17.0` with a `### Common library chart migration` section
  listing:
  - `Chart.yaml` — new `common` dependency (`file://`-style comment
    rationale), version bump `0.16.16 → 0.17.0`.
  - `templates/_helpers.tpl` — `tmforum.name`, `tmforum.fullname`,
    `tmforum.chart`, and `tmforum.serviceAccountName` now delegate to
    `common.*`. `tmforum.labels` is intentionally kept as a chart-local
    3-label subset (rationale: per-API templates already emit
    `app.kubernetes.io/name` / `app.kubernetes.io/instance` per API; the
    5-label `common.labels.standard` would create duplicate keys and
    break selector matching).
  - `templates/serviceaccount.yaml` — replaced with one-line
    `common.serviceAccount.tpl` include.
  - `templates/service.yaml`, `templates/ingress.yaml`,
    `templates/route.yaml`, `templates/route-certificate.yaml`,
    `templates/envoy.yaml`, `templates/envoy-service.yaml`,
    `templates/envoy-configmap.yaml`, `templates/deploy-all-in-one.yaml`,
    `templates/deployment.yaml` — **intentionally NOT migrated**; explain
    that per-API iteration and Envoy-specific bodies have no counterpart
    on the common helper surface. These templates continue to reference
    `tmforum.fullname`, `tmforum.name`, `tmforum.labels`, and
    `tmforum.serviceAccountName`, all of which are now wrappers around
    the common helpers.
- `### Breaking changes` section calling out the SA-name rename
  (item 4 from `docs/common-chart.md`).
- `### Non-breaking cosmetic changes to rendered output` section calling
  out:
  - the labels-blank-line removal on the new `serviceaccount.yaml`;
  - the SA `metadata.labels` expansion from the chart-local 3-label
    subset to the canonical 5-label `common.labels.standard` set
    (adds `app.kubernetes.io/name` and `app.kubernetes.io/instance`).
    Non-functional — the SA's `metadata.labels` are metadata-only and
    not consumed as a selector by any other resource in the chart.
- `### Upgrade path` paragraph stating that `helm upgrade` of an
  existing release is a no-op for the Service / Deployment selector
  pair and a standard metadata update for the ServiceAccount resource.

**Acceptance criteria:**

- File exists and is consistent in style with `charts/mintaka/CHANGELOG.md`.
- `docs/common-chart.md` "Charts migrated so far" list is updated to
  include `tm-forum-api` with a pointer to the new CHANGELOG.

### Step 6: Validate with build / lint / eval and finalise the PR

**Files:** none — validation only.

Run, in order, from the repository root:

```
./build.sh
./lint.sh
./eval.sh
```

Each must exit 0. `./eval.sh` renders every chart through `helm template`
and pipes it to `kubeconform -strict -ignore-missing-schemas`; a regression
on tm-forum-api will show up as a kubeconform error on one of the
rendered manifests.

If any script exits non-zero, fix the underlying issue and re-run all
three — do not skip or narrow the validation.

**Acceptance criteria:**

- `./build.sh`, `./lint.sh`, `./eval.sh` all exit 0.
- `git status` after the migration shows only: modified `Chart.yaml`,
  modified `templates/_helpers.tpl`, modified `templates/serviceaccount.yaml`,
  new `CHANGELOG.md`, modified `docs/common-chart.md`.
- No changes to `service.yaml`, `ingress.yaml`, `route.yaml`,
  `route-certificate.yaml`, `envoy*.yaml`, `deploy-all-in-one.yaml`,
  `deployment.yaml`, `NOTES.txt`, `values.yaml`, or `README.md*`.
