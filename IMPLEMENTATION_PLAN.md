# Implementation Plan: Update chart fdsc-edc to use common chart

## Overview

Migrate `charts/fdsc-edc` onto the in-repo `common` library chart
(`charts/common`) following the pattern documented in
`docs/common-chart.md` and already applied to `orion`, `keyrock` and
`mintaka`. Because `fdsc-edc` carries a per-deployment iteration pattern
and **non-canonical selector labels** on its Service / Deployment /
ConfigMap bodies (see [Scope](#scope) below), the migration is
deliberately scoped to the portions that preserve render parity
byte-for-byte: the chart metadata, the five standard helpers in
`_helpers.tpl`, and the singleton `serviceaccount.yaml`. The
per-deployment Service / Ingress / Deployment / ConfigMap bodies stay
chart-local to keep immutable selector labels unchanged.

## Scope

### What moves to `common`

- `Chart.yaml` gets the `common` dependency (and the `apiVersion` v1→v2
  bump that library dependencies require).
- `templates/_helpers.tpl` — `fdsc-edc.name|fullname|chart|serviceAccountName|labels`
  become thin wrappers over `common.names.name` / `common.names.fullname`
  / `common.names.chart` / `common.serviceAccount.name` /
  `common.labels.standard`. The `fdsc-edc.*` names are kept so any
  external umbrella chart that references them continues to work.
- `templates/serviceaccount.yaml` — replaced with a single-line
  `include "common.serviceAccount.tpl" …` call. This template is a
  singleton (not per-deployment) and uses the canonical `fdsc-edc.labels`
  today, so it maps cleanly onto `common.serviceAccount.tpl`.

### What stays chart-local (and why)

- `templates/service.yaml`, `templates/ingress.yaml`,
  `templates/deployment.yaml`, `templates/config-map.yaml` — all four
  iterate over `.Values.deployment` (a map of named deployments) and
  use **non-canonical labels** of the form:

  ```yaml
  labels:
    app.kubernetes.io/name: {{ $fullName }}-{{ $name }}
    app.kubernetes.io/instance: {{ $.Release.Name }}
    app.kubernetes.io/component: {{ $fullName }}-{{ $name }}
  ```

  `common.labels.standard` (and, by extension, `common.service.tpl` /
  `common.ingress.tpl`) emit the canonical 5-label set with
  `app.kubernetes.io/name: <chart-name>[-<component>]`. Because the
  Deployment's `spec.selector.matchLabels` references these same labels
  and **selectors are immutable once a workload is created**, switching
  the Service / Ingress to common helpers would require changing the
  Deployment's labels in lock-step — which breaks `helm upgrade` on any
  existing release. That is explicitly not what the ticket asks for
  ("update as minimal breaking as possible").

- `templates/config-map.yaml` — bespoke body that renders a long
  `dataspaceconnector-configuration.properties` from `.Values.common` +
  per-deployment overrides. No counterpart in the `common` helper
  surface (same category as `orion/deployment-mongo.yaml`,
  `vcverifier/configmap-templates.yaml`).

- `templates/deployment.yaml` — same call-out as `mintaka`:
  chart-specific container / env / probes / volumes / multi-deployment
  range loop. The `common` library intentionally stops short of
  Deployment bodies (see `docs/common-chart.md` §Non-goals).

## Verification requirements

Each step below must pass the following checks before being considered
done:

1. `helm dependency update charts/fdsc-edc` succeeds (pulls `common`
   from `file://../common`).
2. `helm lint charts/fdsc-edc` is clean.
3. `helm template charts/fdsc-edc` followed by
   `kubeconform -strict -ignore-missing-schemas` is clean.
4. `./build.sh`, `./lint.sh` and `./eval.sh` at the repo root all pass
   (these are the repository-wide CI entry points).
5. **Render-parity diff.** For every step that may change rendered
   output, run:

   ```bash
   git worktree add /tmp/fdsc-edc-main origin/main
   helm template fdsc-edc /tmp/fdsc-edc-main/charts/fdsc-edc \
     --values charts/fdsc-edc/values.yaml > /tmp/before.yaml

   helm dependency update charts/fdsc-edc
   helm template fdsc-edc charts/fdsc-edc \
     --values charts/fdsc-edc/values.yaml > /tmp/after.yaml

   diff -u /tmp/before.yaml /tmp/after.yaml
   ```

   The diff must be empty for Step 2 and limited to the documented
   breaking changes for Step 3. Use a values file that sets at least
   one entry in `.Values.deployment` so the iteration templates render.

## Steps

### Step 1: Bump `Chart.yaml` to apiVersion v2 and declare the `common` dependency

Goal: make `fdsc-edc` a v2 chart with a local `file://../common`
dependency, so subsequent steps can `include` `common.*` helpers.
Rendered output is unchanged in this step.

Changes:

- `charts/fdsc-edc/Chart.yaml`
  - Change `apiVersion: v1` to `apiVersion: v2` (library dependencies
    require v2).
  - Bump `version` from `0.1.8` to `0.2.0` (minor bump signals the new
    dependency and matches the versioning rhythm used by `mintaka`'s
    migration).
  - Leave `appVersion: 0.1.7` unchanged.
  - Add a `dependencies:` block with a `common` entry pointing at the
    local chart:

    ```yaml
    dependencies:
      - name: common
        repository: "file://../common"
        version: "0.0.1"
    ```

  - Add a short comment above the `dependencies:` block explaining
    what the library chart is (paraphrase `charts/mintaka/Chart.yaml`).
- `charts/fdsc-edc/.gitignore` — new file. Ignore `Chart.lock` and the
  resolved `charts/` directory (the `common-<version>.tgz` is pulled in
  by `helm dependency update` at install / publish time and should not
  live in git):

  ```
  Chart.lock
  charts/
  ```

Verification:

- `helm dependency update charts/fdsc-edc` succeeds.
- `helm lint charts/fdsc-edc` is clean.
- `diff <(helm template … main) <(helm template … branch)` is **empty**
  — this step only adds metadata, no template changes.
- `./build.sh`, `./lint.sh`, `./eval.sh` pass.

Acceptance criteria:

- `Chart.yaml` declares `apiVersion: v2` and lists `common` as a
  dependency.
- `.gitignore` is committed with `Chart.lock` / `charts/` entries.
- No rendered manifest changes vs. `main`.

---

### Step 2: Rewrite `_helpers.tpl` as thin wrappers over `common.*`

Goal: replace every helper body in `charts/fdsc-edc/templates/_helpers.tpl`
with a one-line `include` of the matching `common.*` helper. The
external `include "fdsc-edc.<helper>"` surface is preserved so any
umbrella chart that references these names keeps working. Rendered
output must remain byte-identical.

Changes to `charts/fdsc-edc/templates/_helpers.tpl`:

- `fdsc-edc.name` → `{{- include "common.names.name" . -}}`
- `fdsc-edc.fullname` → `{{- include "common.names.fullname" . -}}`
- `fdsc-edc.chart` → `{{- include "common.names.chart" . -}}`
- `fdsc-edc.serviceAccountName` → `{{- include "common.serviceAccount.name" . -}}`
- `fdsc-edc.labels` → `{{- include "common.labels.standard" . -}}`

Refresh the top-of-file comment block to mirror the explanation in
`charts/mintaka/templates/_helpers.tpl` (why the wrappers exist, that
they delegate to `common.*`, that they are kept for backwards
compatibility). Each wrapper must carry a short GoDoc-style comment
identifying the `common.*` helper it delegates to.

Verification:

- `helm lint charts/fdsc-edc` is clean.
- **Render-parity diff must be empty.** Run the diff recipe from the
  [Verification requirements](#verification-requirements) section with
  a values override that populates at least one entry under
  `.Values.deployment` (e.g. `deployment: { oid4vc: {} }`). The
  rendered Service / Ingress / Deployment / ConfigMap / ServiceAccount
  bodies must be byte-identical to `main`, because:
  - `common.names.*` / `common.serviceAccount.name` /
    `common.labels.standard` all reproduce the canonical helper bodies
    byte-for-byte when called with the root context (documented in
    `docs/common-chart.md`).
  - The non-canonical label strings in `service.yaml`,
    `ingress.yaml`, `deployment.yaml` and `config-map.yaml` do not
    reference the helpers, so wrapping the helpers cannot affect them.
- `./build.sh`, `./lint.sh`, `./eval.sh` pass.

Acceptance criteria:

- All five helpers are thin `include` wrappers of a `common.*` helper.
- Render-parity diff vs. `main` is empty.
- No other template file is touched in this step.

---

### Step 3: Migrate `serviceaccount.yaml` to `common.serviceAccount.tpl`, update `CHANGELOG.md`, and verify

Goal: replace the only resource template that maps cleanly onto the
shared helper (`serviceaccount.yaml` is singleton and already uses the
canonical `fdsc-edc.labels`) with a one-line `include`, document the
two documented breaking-change deltas the `common.serviceAccount.tpl`
body introduces, and add a CHANGELOG entry describing the scope of
the migration.

Changes:

- `charts/fdsc-edc/templates/serviceaccount.yaml` — replace entire body
  with the single line used by `mintaka`:

  ```gotpl
  {{- include "common.serviceAccount.tpl" (dict "context" $) }}
  ```

- `charts/fdsc-edc/CHANGELOG.md` — new file (this chart does not ship a
  CHANGELOG today). Use the `charts/mintaka/CHANGELOG.md` structure:
  - Header with the new version `0.2.0`.
  - `### Common library chart migration` section enumerating exactly
    the files touched in Steps 1–3 (Chart.yaml dependency + v1→v2 bump,
    `_helpers.tpl` wrapping, `serviceaccount.yaml` delegation,
    `.gitignore`). Explicitly call out that `service.yaml`,
    `ingress.yaml`, `deployment.yaml` and `config-map.yaml` stay
    chart-local (see [Scope](#scope) above).
  - `### Breaking changes` section listing:
    1. **Explicit `metadata.namespace` on the ServiceAccount** — the
       `common.serviceAccount.tpl` body emits
       `namespace: {{ .Release.Namespace | quote }}`. The legacy
       `serviceaccount.yaml` did not render this key. This matches
       the convention used elsewhere in the chart (`service.yaml`,
       `ingress.yaml`, `deployment.yaml` and `config-map.yaml` all
       already emit the explicit namespace). It does not change where
       the resource is deployed.
    2. **ServiceAccount resource name honours
       `.Values.serviceAccount.name`** — the legacy
       `serviceaccount.yaml` hard-coded
       `metadata.name: {{ include "fdsc-edc.fullname" . }}` and ignored
       `.Values.serviceAccount.name`. `common.serviceAccount.tpl` uses
       `common.serviceAccount.name`, which applies
       `.Values.serviceAccount.name` as an override. Concretely, a
       release with `serviceAccount.create: true` and
       `serviceAccount.name: custom-sa` now renders a ServiceAccount
       named `custom-sa` instead of `<fullname>`. The pod spec's
       `serviceAccountName` already resolved to `custom-sa` via
       `fdsc-edc.serviceAccountName`, so this is a bug fix.
  - `### Non-breaking cosmetic changes to rendered output` section
    listing:
    - The blank leading line inside the ServiceAccount labels block (a
      side-effect of the legacy `{{ include "fdsc-edc.labels" . | nindent 4 }}`
      pattern) is gone — `common.serviceAccount.tpl` emits labels
      without a leading blank. The chart-local templates
      (`service.yaml` / `ingress.yaml` / `deployment.yaml` /
      `config-map.yaml`) still carry their existing whitespace because
      they were not migrated.
  - `### Upgrade path` section stating that `helm upgrade` of an
    existing release is a standard field update for the ServiceAccount
    resource and a no-op for everything else.

Verification:

- `helm dependency update charts/fdsc-edc` succeeds.
- `helm lint charts/fdsc-edc` is clean.
- `helm template charts/fdsc-edc | kubeconform -strict -ignore-missing-schemas`
  is clean.
- **Render-parity diff.** Run the same diff recipe as in Step 2. The
  diff is expected to be limited to:
  - The new `metadata.namespace` line on the ServiceAccount.
  - The labels block whitespace delta (no leading blank line).
  - (Only if the values file exercises it) the ServiceAccount name
    change when `.Values.serviceAccount.name` is set. For the default
    values file the name is unchanged.
  Verify each line of the diff matches one of the two documented
  breaking changes or the cosmetic delta. No other manifest should
  differ.
- `./build.sh`, `./lint.sh`, `./eval.sh` pass.

Acceptance criteria:

- `templates/serviceaccount.yaml` is a single `include` of
  `common.serviceAccount.tpl`.
- `CHANGELOG.md` is committed and accurately describes scope,
  breaking changes and the upgrade path.
- Render-parity diff vs. `main` is limited to the documented deltas
  on the ServiceAccount manifest only.
- All repo-wide CI scripts (`build.sh`, `lint.sh`, `eval.sh`) pass.

---

## Out of scope (explicitly deferred)

- Migrating `service.yaml`, `ingress.yaml`, `deployment.yaml` or
  `config-map.yaml` to `common.*` helpers. These would require
  changing the non-canonical label scheme (see [Scope](#scope)) and
  therefore break `helm upgrade` on existing releases — contrary to
  the "minimal breaking" goal of the ticket. A follow-up ticket can
  address this under a major-version bump once a deprecation window
  is agreed; this is exactly the mechanism described in
  `charts/common/DEPRECATIONS.md` for the wrapper-removal rollout.
- Normalising the multi-deployment iteration pattern
  (`range .Values.deployment`) — same reason. This is a chart-specific
  value-shape and has no counterpart in the `common` helper surface.
- Touching `values.yaml`. No new keys are required for this migration.
- Regenerating `README.md` (the README is derived from `values.yaml`;
  no value changes, no README change).
