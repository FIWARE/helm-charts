# Implementation Plan: Create common helm-chart for FIWARE Helm-Charts

## Overview
Introduce a new library chart `charts/common` (analogous to `bitnami/common`) that
centralizes the duplicated helpers (names, labels, service-account resolution,
existing-secret resolution, image helpers, ingress/route/HPA/service/secret bodies)
currently copy-pasted across all 25 FIWARE charts. Migrate the existing charts to
consume it as a local dependency, preserving today's rendered output wherever possible
and explicitly calling out the few unavoidable breaking changes. Each individual
chart migration is a separate, independently-shippable step so the rollout can be
gradual.

## Steps

### Step 1: Audit & freeze the duplication baseline
**Goal.** Produce a machine-readable inventory of what is duplicated, so later steps
have a concrete target.

**Work.**
- Add `docs/common-chart-audit.md` that, for every chart in `charts/*`, lists:
  - the helpers defined in `templates/_helpers.tpl` (name, fullname, chart,
    serviceAccountName, labels, selectorLabels, secretName, certSecretName, image,
    …) and whether they are byte-identical to the canonical `orion` / `keyrock`
    versions;
  - which templates files exist (`service.yaml`, `ingress.yaml`, `route.yaml`,
    `serviceaccount.yaml`, `secret.yaml`, `deployment-hpa.yaml`, `NOTES.txt`);
  - per-chart deviations (e.g. keyrock's `semverCompare` branch in `ingress.yaml`,
    scorpio-broker's per-component naming scheme).
- Add a short `docs/common-chart-proposal.md` summarising the proposed helper surface
  and listing the explicit, unavoidable breaking changes (see "Breaking Changes" at
  the bottom of this plan).
- **Acceptance:** both docs committed; numbers line up with the 25 charts currently
  in `charts/`.
- **Files:** `docs/common-chart-audit.md`, `docs/common-chart-proposal.md`.

### Step 2: Scaffold the `common` library chart
**Goal.** Create an empty-but-valid library chart that can already be added as a
dependency without changing any rendered manifests.

**Work.**
- Create `charts/common/` with:
  - `Chart.yaml` (`apiVersion: v2`, `type: library`, `name: common`,
    `version: 0.1.0`, `kubeVersion: '>= 1.19-0'`, maintainers copied from existing
    charts).
  - `values.yaml` (empty, with a header comment noting library charts don't render
    values but may document defaults that consumers opt into via `_defaults.tpl`).
  - `README.md` describing the chart purpose, how to depend on it, and a table of
    helpers to be added in later steps.
  - `templates/.gitkeep`.
- Update root `README.md` with a short "common library chart" section pointing at
  `charts/common/README.md`.
- **Acceptance:** `helm lint charts/common` passes; `./lint.sh` still passes for
  every other chart (common itself is linted but produces no output).
- **Files:** `charts/common/Chart.yaml`, `charts/common/values.yaml`,
  `charts/common/README.md`, `charts/common/templates/.gitkeep`, `README.md`.

### Step 3: Implement name / chart / labels helpers in common
**Goal.** First batch of shared helpers — the ones every chart already has.

**Work.**
- Add `charts/common/templates/_names.tpl` defining:
  - `common.names.name` — replicates `<chart>.name`.
  - `common.names.fullname` — replicates `<chart>.fullname` including the
    `.Values.fullnameOverride` and "release contains chart name" branches.
  - `common.names.chart` — replicates `<chart>.chart` (`Chart.Name-Chart.Version`).
  - `common.names.namespace` — returns `.Release.Namespace`, honouring a
    `.Values.namespaceOverride` convention.
- Add `charts/common/templates/_labels.tpl` defining:
  - `common.labels.standard` — matches the current 5-label set
    (`app.kubernetes.io/name|instance|version|managed-by`, `helm.sh/chart`).
  - `common.labels.matchLabels` — `app.kubernetes.io/name` +
    `app.kubernetes.io/instance` (the existing selector pattern).
- Unit-verify by rendering a throwaway consumer chart under
  `charts/common/tests/` (git-ignored output) that includes each helper and checks
  the rendered string matches the old orion / keyrock helpers byte-for-byte.
- **Acceptance:** `helm lint charts/common` passes. Rendering `common.labels.standard`
  for a fake release produces the exact same YAML fragment that `orion.labels`
  currently produces.
- **Files:** `charts/common/templates/_names.tpl`,
  `charts/common/templates/_labels.tpl`, `charts/common/tests/` (fixture).

### Step 4: Implement serviceAccount, secret, and image helpers in common
**Goal.** Second batch of helpers needed before any chart can migrate.

**Work.**
- `charts/common/templates/_serviceaccount.tpl`:
  - `common.serviceAccount.name` — replicates `<chart>.serviceAccountName` semantics
    (`.Values.serviceAccount.create` → fullname, else `.Values.serviceAccount.name`,
    else `default`).
- `charts/common/templates/_secrets.tpl`:
  - `common.secrets.name` — takes `(dict "context" . "existingSecret" .Values.x
    "suffix" "-certs")` and returns either the `tpl`-expanded existing secret name
    or `fullname [+ suffix]`. Generalises `orion.secretName`, `keyrock.secretName`
    and `keyrock.certSecretName`.
  - `common.secrets.key` — mirrors `orion.secretKey` (returns the provided key or a
    default).
- `charts/common/templates/_images.tpl`:
  - `common.images.image` — renders `repository:tag` honouring `.Values.image.tag`
    falling back to `.Chart.AppVersion`.
  - `common.images.pullPolicy` — default `IfNotPresent`.
  - `common.images.pullSecrets` — renders `imagePullSecrets` block if provided.
- **Acceptance:** `helm lint charts/common` clean; fixture renders in
  `charts/common/tests/` prove parity with orion / keyrock helpers for matching
  inputs.
- **Files:** the three new `.tpl` files plus fixture updates.

### Step 5: Implement resource-body helpers in common (service, ingress, route, HPA, serviceaccount, secret)
**Goal.** Let consumer charts replace whole template files with a one-line
`include`.

**Work.**
- `charts/common/templates/_service.tpl` — `common.service.tpl` produces the full
  Service YAML (apiVersion, metadata with labels/annotations/namespace, spec with
  selector, ports, type) from a parameter dict.
- `charts/common/templates/_ingress.tpl` — `common.ingress.tpl` produces an
  `networking.k8s.io/v1` Ingress with the existing `tls` + `hosts[].paths[]` shape.
  Accepts `.ingress.className`.
- `charts/common/templates/_route.tpl` — `common.route.tpl` produces the
  `route.openshift.io/v1` Route gated on `.Values.route.enabled`.
- `charts/common/templates/_hpa.tpl` — `common.hpa.tpl` produces the HPA gated on
  `.Values.autoscaling.enabled`, using `.Values.autoscaling.apiVersion`,
  `.Values.autoscaling.metrics`.
- `charts/common/templates/_serviceaccount.tpl` (extend) — add
  `common.serviceAccount.tpl` that renders the whole SA object.
- `charts/common/templates/_secret.tpl` — render an Opaque Secret when a
  non-existing-secret password is provided.
- Every helper accepts a `dict` with at minimum `context: $` so the caller can pass
  scoped values (follows the bitnami pattern: `{{- include "common.service.tpl"
  (dict "context" $ "values" .Values.service) }}`).
- **Acceptance:** `helm lint charts/common` clean; fixture-rendered output of each
  helper matches the current orion/keyrock/mintaka template byte-for-byte when fed
  the same values (diff shows only whitespace differences that kubeconform
  tolerates).
- **Files:** six new `.tpl` files under `charts/common/templates/`, fixture updates,
  README updates documenting every helper.

### Step 6: Add test harness and CI wiring for `common`
**Goal.** Keep the library chart honest going forward.

**Work.**
- Under `charts/common/tests/` add a Helm chart fixture (`Chart.yaml` with
  `dependencies: - name: common`, sample `values.yaml`, template files that `include`
  each helper) used only for rendering parity tests.
- Add `scripts/test-common.sh` that:
  - runs `helm dependency update charts/common/tests`,
  - runs `helm template charts/common/tests` and compares the output against
    `charts/common/tests/expected/*.yaml` golden files,
  - exits non-zero on diff.
- Extend `lint.sh` so it skips `charts/common/tests` (which is a fixture, not a
  published chart) but still lints `charts/common`.
- Update `.github/workflows/chart-test.yml` (or equivalent) to invoke
  `scripts/test-common.sh`. If no workflow file exists in the branch yet, document
  the addition in `charts/common/README.md` and leave the script runnable locally.
- **Acceptance:** `./lint.sh` passes; `bash scripts/test-common.sh` passes.
- **Files:** `charts/common/tests/**`, `scripts/test-common.sh`, `lint.sh`, CI yaml
  if present.

### Step 7: Pilot migration — `orion`
**Goal.** First real consumer chart; smoke-tests the design.

**Work.**
- Add `dependencies:` entry in `charts/orion/Chart.yaml`:
  ```yaml
  dependencies:
    - name: common
      repository: "file://../common"
      version: "0.1.x"
  ```
- Bump `charts/orion/Chart.yaml` `version` (minor bump) and add a `CHANGELOG.md`
  entry under `charts/orion/`.
- In `charts/orion/templates/_helpers.tpl`, replace every body with a thin wrapper,
  e.g.
  ```
  {{- define "orion.fullname" -}}
  {{- include "common.names.fullname" . -}}
  {{- end -}}
  ```
  so any external charts that referenced `orion.*` still resolve. Keep the wrapper
  until a future major release.
- Replace `templates/service.yaml`, `ingress.yaml`, `route.yaml`, `serviceaccount.yaml`,
  `secret.yaml`, `deployment-hpa.yaml` with one-line `include` calls to the
  corresponding `common.*.tpl` helpers. Leave `deployment.yaml`, `deployment-mongo.yaml`,
  `service-mongo.yaml`, `initdata-cm.yaml`, `post-hook-initdata.yaml`, `NOTES.txt`
  and `test/` untouched in this step.
- Run `helm dependency update charts/orion` and check in the resulting
  `Chart.lock` + `charts/orion/charts/common-*.tgz` if the repo convention requires
  it (otherwise add both to `.gitignore`).
- **Acceptance:** `helm template charts/orion` before vs. after the migration
  differs only by whitespace (verified via `diff <(helm template …before) <(helm
  template …after)` committed as an artefact in the PR description).
  `./lint.sh` and `./eval.sh` pass.
- **Files:** `charts/orion/Chart.yaml`, `charts/orion/Chart.lock`,
  `charts/orion/templates/_helpers.tpl`, `charts/orion/templates/service.yaml`,
  `charts/orion/templates/ingress.yaml`, `charts/orion/templates/route.yaml`,
  `charts/orion/templates/serviceaccount.yaml`, `charts/orion/templates/secret.yaml`,
  `charts/orion/templates/deployment-hpa.yaml`, `charts/orion/CHANGELOG.md`,
  possibly `.gitignore`.

### Step 8: Pilot migration — `keyrock`
**Goal.** Prove the design on a chart with bespoke helpers
(`certSecretName`, ingress `semverCompare` branch, StatefulSet).

**Work.**
- Repeat the Step-7 procedure for `charts/keyrock`.
- Drop the `semverCompare ">=1.14-0"` branch in the ingress (always emit
  `networking.k8s.io/v1`). Document this under "Breaking Changes" in
  `charts/keyrock/CHANGELOG.md` (Kubernetes ≥ 1.19 is already the chart's
  `kubeVersion`, so effectively a no-op, but call it out).
- Extend `common.secrets.name` callers to cover `certSecret` via the `suffix`
  parameter.
- **Acceptance:** render-diff shows only the documented ingress-apiVersion change;
  `./lint.sh` and `./eval.sh` pass.
- **Files:** `charts/keyrock/Chart.yaml`, `charts/keyrock/Chart.lock`,
  `charts/keyrock/templates/_helpers.tpl`, `charts/keyrock/templates/ingress.yaml`,
  `charts/keyrock/templates/route.yaml`, `charts/keyrock/templates/service.yaml`,
  `charts/keyrock/templates/serviceaccount.yaml`, `charts/keyrock/templates/secret.yaml`,
  `charts/keyrock/templates/statefulset-hpa.yaml`, `charts/keyrock/CHANGELOG.md`.

### Step 9: Migration — `mintaka`
**Goal.** Third pilot migration — the first of the "simple" single-deployment
charts, exercising the orion/keyrock pattern on a chart without bespoke helpers
but with an HPA template.

**Work.**
- Add `dependencies:` entry in `charts/mintaka/Chart.yaml` pointing at
  `file://../common`, bump `apiVersion` v1→v2 (required to declare
  dependencies), bump `version` minor (0.4.2 → 0.6.0), add
  `kubeVersion: '>= 1.19-0'`.
- In `charts/mintaka/templates/_helpers.tpl`, replace every helper body with a
  thin wrapper over the matching `common.*` helper (same pattern as
  orion/keyrock).
- Replace `templates/service.yaml`, `ingress.yaml`, `route.yaml`,
  `serviceaccount.yaml`, `secret.yaml`, `deployment-hpa.yaml` with one-line
  `include` calls to the corresponding `common.*.tpl` helpers. Leave
  `deployment.yaml` and `NOTES.txt` untouched (they reference
  mintaka-specific env / probe config that has no counterpart in `common`).
- Add `autoscaling.apiVersion: "v2beta2"` to `values.yaml` so `common.hpa.tpl`
  reproduces the previous HPA apiVersion exactly. Document this as a
  non-behavioural "breaking change" in `charts/mintaka/CHANGELOG.md`.
- Add `charts/mintaka/.gitignore` excluding `Chart.lock` and the `charts/`
  sub-directory (matches orion / keyrock).
- **Acceptance:** `helm template charts/mintaka` before vs. after the migration
  differs only by whitespace + the documented version bump + the cosmetic labels-
  block whitespace change. `./lint.sh` and `./eval.sh` pass with every other
  chart, kubeconform is clean under default / existingSecret / full-values
  profiles.
- **Files:** `charts/mintaka/Chart.yaml`, `charts/mintaka/.gitignore`,
  `charts/mintaka/templates/_helpers.tpl`,
  `charts/mintaka/templates/service.yaml`,
  `charts/mintaka/templates/ingress.yaml`,
  `charts/mintaka/templates/route.yaml`,
  `charts/mintaka/templates/serviceaccount.yaml`,
  `charts/mintaka/templates/secret.yaml`,
  `charts/mintaka/templates/deployment-hpa.yaml`,
  `charts/mintaka/values.yaml`, `charts/mintaka/CHANGELOG.md`.

### Step 10: Batch migration A — `api-umbrella`, `apollo`, `bae-activation-service`, `business-api-ecosystem`, `canis-major`
**Goal.** Migrate the first batch of the remaining straightforward,
single-deployment charts using the pattern established by orion/keyrock/mintaka.

**Scope.** `api-umbrella`, `apollo`, `bae-activation-service`,
`business-api-ecosystem`, `canis-major`.

**Work per chart.**
- Same procedure as Step 9: add `common` dependency, wrap helpers, replace
  duplicated template bodies with `include` calls, bump `apiVersion`/`version`,
  add `kubeVersion`, add `autoscaling.apiVersion` to values (where an HPA
  template exists), add `.gitignore`, add `CHANGELOG.md`.
- For charts that render additional resources not covered by `common` (envoy
  configmap in tm-forum-api, certificates in vcverifier, configmaps in
  various), leave those templates unchanged.
- Each chart is a separate commit within this step's PR so reverts remain cheap.
- **Acceptance:** for every migrated chart, `helm template` output before vs.
  after differs only in whitespace (or in documented breaking changes listed in
  that chart's `CHANGELOG.md`); `./lint.sh` and `./eval.sh` pass.
- **Files:** `charts/<chart>/Chart.yaml`, `charts/<chart>/.gitignore`,
  `charts/<chart>/templates/_helpers.tpl`, plus the resource templates each
  chart actually had, `charts/<chart>/values.yaml`,
  `charts/<chart>/CHANGELOG.md`.

### Step 11: Batch migration B — `contract-management`, `credentials-config-service`, `did-helper`, `dsba-pdp`, `dss-validation-service`
**Goal.** Second batch, same pattern as Step 10.

**Scope.** `contract-management`, `credentials-config-service`, `did-helper`,
`dsba-pdp`, `dss-validation-service`.

**Work per chart.** Identical to Step 10.

**Acceptance.** Same as Step 10.

**Files.** Same shape as Step 10, scoped to the five charts listed above.

### Step 12: Batch migration C — `endpoint-auth-service`, `fdsc-edc`, `iotagent-json`, `iotagent-ul`, `ishare-satellite`
**Goal.** Third batch, same pattern as Step 10.

**Scope.** `endpoint-auth-service`, `fdsc-edc`, `iotagent-json`, `iotagent-ul`,
`ishare-satellite`.

**Work per chart.** Identical to Step 10.

**Acceptance.** Same as Step 10.

**Files.** Same shape as Step 10, scoped to the five charts listed above.

### Step 13: Batch migration D — `odrl-pap`, `onboarding-portal`, `tm-forum-api`, `trusted-issuers-list`, `trusted-issuers-registry`, `vcverifier`
**Goal.** Fourth and final batch of single-component charts, same pattern as
Step 10.

**Scope.** `odrl-pap`, `onboarding-portal`, `tm-forum-api`,
`trusted-issuers-list`, `trusted-issuers-registry`, `vcverifier`.

**Work per chart.** Identical to Step 10. `tm-forum-api` and `vcverifier` have
chart-specific extra templates (envoy configmap, certificates) — leave those
unchanged; only migrate the duplicated service/ingress/route/HPA/SA/secret
bodies.

**Acceptance.** Same as Step 10.

**Files.** Same shape as Step 10, scoped to the six charts listed above.

### Step 14: Migration — `scorpio-broker` and `scorpio-broker-aaio` (multi-component)
**Goal.** Handle the only charts that render many services per release; they need
helper variants that accept a component name.

**Work.**
- Extend `common.names.fullname` / `common.labels.standard` /
  `common.labels.matchLabels` to optionally accept a `componentName` in the dict
  (producing `<fullname>-<component>` / `app.kubernetes.io/component=<component>`).
  Do this additively — the single-component callers from Steps 7–9 continue to
  work unchanged.
- Add `common.deployment.tpl` only if it makes sense for scorpio's per-component
  deployments; otherwise keep deployments raw and share only the HPA / Service /
  labels via include.
- Migrate both scorpio charts as in Step 9.
- **Acceptance:** render-diff matches existing output; `./lint.sh` and `./eval.sh`
  pass. Helpers added here are also exercised by the `charts/common/tests/`
  fixture.
- **Files:** `charts/common/templates/_names.tpl`,
  `charts/common/templates/_labels.tpl`, `charts/common/tests/**`,
  `charts/scorpio-broker/**`, `charts/scorpio-broker-aaio/**`.

### Step 15: Remove legacy per-chart helper bodies (optional, deferred)
**Goal.** Document — but do not execute — the eventual cleanup where the
per-chart `<chart>.*` wrapper helpers are dropped. This is intentionally the LAST
step and is scheduled for a future major version bump of each chart.

**Work.**
- Add a `charts/common/DEPRECATIONS.md` listing every `<chart>.*` helper that is
  currently a thin wrapper around `common.*`, and the target major version in
  which it will be removed.
- Do not delete any wrapper in this step.
- **Acceptance:** doc is present; no chart behaviour changes.
- **Files:** `charts/common/DEPRECATIONS.md`.

### Step 16: Final verification and documentation sweep
**Goal.** Make sure the repo is coherent before hand-off.

**Work.**
- Run `./build.sh`, `./lint.sh`, `./eval.sh`, `bash scripts/test-common.sh` locally
  and paste results into the final PR description.
- Update the root `README.md` with a paragraph on the `common` library chart and a
  link to `charts/common/README.md`.
- Verify Chart.yaml `version` bumps are consistent and that every migrated chart's
  `CHANGELOG.md` lists any breaking change (there should be at most the ones
  listed below).
- **Acceptance:** All three scripts pass; `helm template` output of every chart is
  identical to `main` except for the documented breaking changes.
- **Files:** `README.md`, any final cleanup.

---

## Breaking Changes (explicit)

The goal is zero breaking changes. The refactor is mechanical so in almost every
chart `helm template` output is byte-identical after the migration. The only
unavoidable breaking changes, all confined to Step 8+:

1. **keyrock ingress apiVersion** — the `semverCompare ">=1.14-0"` branch in
   `charts/keyrock/templates/ingress.yaml` is removed; the chart now always emits
   `networking.k8s.io/v1`. Effective on Kubernetes < 1.14 only, which is already
   below the chart's declared `kubeVersion`.

2. **Legacy per-chart helpers become wrappers** — users who `include` `orion.*` /
   `keyrock.*` / etc. from their own umbrella charts continue to work, but the
   implementation moves to `common.*`. Scheduled for removal in the next major
   release per-chart (Step 11 tracks this), so users have a deprecation window.

No other observable changes to rendered manifests are expected; each migration PR
enforces this with a `helm template` diff.
