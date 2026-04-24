# Implementation Plan: Update chart scorpio-broker-aaio to use common chart

## Overview
Migrate `charts/scorpio-broker-aaio` onto the in-repo `common` library chart
(`charts/common`) following the pattern documented in `docs/common-chart.md`
and already applied to `orion`, `keyrock`, `mintaka` and `fdsc-dashboard`.
Every helper in `templates/_helpers.tpl` becomes a thin wrapper over the
corresponding `common.*` helper, and the five boilerplate resource templates
(`service.yaml`, `ingress.yaml`, `hpa.yaml`, `secret.yaml`,
`serviceaccount.yaml`) are replaced by one-line `include "common.*.tpl"`
calls. The chart-local `deployment.yaml` is intentionally **not** migrated
— per the documented non-goal, Deployment bodies remain chart-local. The
migration must keep the rendered manifests byte-identical to the current
output except for the small set of deviations explicitly listed under
"Breaking changes" in `docs/common-chart.md`.

## Steps

### Step 1: Declare the `common` dependency and rewrite `_helpers.tpl` as thin wrappers

**Goal.** Make `charts/scorpio-broker-aaio` pull in the `common` library chart
and replace every helper body in `templates/_helpers.tpl` with a delegating
wrapper over the matching `common.*` helper, preserving the existing
`scorpioBroker-aaio.*` include paths so external umbrella charts keep
working.

**Files affected.**

- `charts/scorpio-broker-aaio/Chart.yaml`
  - Add a `dependencies:` block with `name: common`,
    `repository: "file://../common"`, `version: "0.0.2"` (matching the
    current `charts/common/Chart.yaml` version). Use the `file://../common`
    form consistent with the other migrated charts — Helm packages the
    library alongside the consumer chart in the resulting `.tgz`.
  - Leave the chart `version` (`0.4.12`) and `apiVersion` (`v2`) unchanged
    in this step; the version bump is done in Step 3 together with the
    CHANGELOG entry.

- `charts/scorpio-broker-aaio/templates/_helpers.tpl`
  - `scorpioBroker-aaio.name`     → `include "common.names.name" .`
  - `scorpioBroker-aaio.fullname` → `include "common.names.fullname" .`
  - `scorpioBroker-aaio.chart`    → `include "common.names.chart" .`
  - `scorpioBroker-aaio.labels`   → `include "common.labels.standard" .`
  - `scorpioBroker-aaio.selectorLabels` →
    `include "common.labels.matchLabels" .` (the chart is one of the four
    that carries an explicit `selectorLabels` helper — keep the wrapper so
    `deployment.yaml` continues to resolve).
  - `scorpioBroker-aaio.serviceAccountName` →
    `include "common.serviceAccount.name" .`.
  - `scorpioBroker-aaio.secretName` →
    `include "common.secrets.name" (dict "context" $ "existingSecret"
    .Values.db.existingSecret)`. The existing-secret shape used by this
    chart is the DB-flavoured map with an `enabled` bool plus `name` /
    `key`, matching the documented `common.secrets.name` contract
    (falls back to `<fullname>` when no user-supplied name is present).
  - `scorpioBroker-aaio.passwordKey` →
    `include "common.secrets.key" (dict "context" $ "existingSecret"
    .Values.db.existingSecret "default" "password")`. The default must stay
    `password` (not `dbPassword`) so the current `data.password` key in the
    generated Secret continues to resolve — `deployment.yaml` reads
    `DBPASS` / `POSTGRES_PASSWORD` via this key.

**Acceptance criteria.**

- `helm dependency update charts/scorpio-broker-aaio` succeeds and resolves
  `common-0.0.2.tgz` from the local `file://../common` path.
- `helm lint charts/scorpio-broker-aaio` passes.
- `diff <(helm template charts/scorpio-broker-aaio @main) <(helm template
  charts/scorpio-broker-aaio @branch)` is **empty** — Step 1 touches only
  helpers, so the rendered YAML must be byte-identical to the pre-migration
  baseline.

### Step 2: Replace the boilerplate resource templates with `common.*.tpl` includes

**Goal.** Delegate Service, Ingress, HPA, Secret and ServiceAccount
rendering to the library chart. `deployment.yaml` stays chart-local.

**Files affected.**

- `charts/scorpio-broker-aaio/templates/service.yaml` → one-line
  ```
  {{- include "common.service.tpl" (dict
        "context" $
        "service" .Values.service
        "ports"   (list (dict
                          "port"       .Values.service.port
                          "targetPort" 9090
                          "protocol"   "TCP"
                          "name"       "9090"))) }}
  ```
  (preserves the current single-port Service: `port 9090` → `targetPort
  9090`, protocol TCP, port name `"9090"`).

- `charts/scorpio-broker-aaio/templates/ingress.yaml` → one-line
  ```
  {{- include "common.ingress.tpl" (dict
        "context"     $
        "ingress"     .Values.ingress
        "servicePort" .Values.service.port) }}
  ```

- `charts/scorpio-broker-aaio/templates/hpa.yaml` → one-line
  ```
  {{- include "common.hpa.tpl" (dict
        "context"     $
        "autoscaling" .Values.autoscaling) }}
  ```

- `charts/scorpio-broker-aaio/templates/secret.yaml` → one-line
  ```
  {{- include "common.secret.tpl" (dict
        "context"        $
        "existingSecret" .Values.db.existingSecret
        "data"           (dict "password" .Values.db.password)) }}
  ```
  The `data` map key is `password` (not `dbPassword`) so
  `deployment.yaml`'s `secretKeyRef.key: {{ include
  "scorpioBroker-aaio.passwordKey" . }}` keeps resolving to an existing
  entry when no `existingSecret` is configured.

- `charts/scorpio-broker-aaio/templates/serviceaccount.yaml` → one-line
  ```
  {{- include "common.serviceAccount.tpl" (dict "context" $) }}
  ```

- `charts/scorpio-broker-aaio/values.yaml` — extend the `autoscaling`
  block to expose the schema the shared HPA helper expects:
  - Add `apiVersion: "v2beta2"` (matches the value currently hard-coded in
    the legacy `hpa.yaml` as `autoscaling/v2beta1` — note: the common
    helper default is `v2beta2`; we keep `v2beta2` consistent with the
    other migrated charts, so this is a deliberate one-API-version-ahead
    bump rather than byte-identical parity. Documented in Step 3's
    CHANGELOG as a breaking delta.).
  - Replace the pair of `targetCPUUtilizationPercentage: 80` /
    `targetMemoryUtilizationPercentage` keys with a `metrics: []` list
    (the shape consumed by `common.hpa.tpl`). Include a commented-out
    example matching the previous CPU-80% behaviour so existing users
    know how to port their overrides. Remove the old keys — this is a
    breaking change for anyone who set them in their own
    `values.override.yaml` and is called out in the CHANGELOG.

- `charts/scorpio-broker-aaio/templates/deployment.yaml` — **not
  modified**. The Deployment already references
  `scorpioBroker-aaio.fullname`, `scorpioBroker-aaio.labels`,
  `scorpioBroker-aaio.selectorLabels`, `scorpioBroker-aaio.serviceAccountName`,
  `scorpioBroker-aaio.secretName` and `scorpioBroker-aaio.passwordKey`,
  all of which are now wrappers around the matching `common.*` helpers.

**Acceptance criteria.**

- `helm lint charts/scorpio-broker-aaio` passes.
- `helm template charts/scorpio-broker-aaio | kubeconform -strict
  -ignore-missing-schemas` passes.
- `diff <(helm template charts/scorpio-broker-aaio @main) <(helm template
  charts/scorpio-broker-aaio @branch)` shows **only** the documented
  breaking / cosmetic deltas:
  1. Explicit `metadata.namespace: "<Release.Namespace>"` on the five
     migrated resources (previously present in this chart's templates
     anyway, so should actually be a no-op — confirm during review).
  2. `HorizontalPodAutoscaler.apiVersion` changes from
     `autoscaling/v2beta1` to `autoscaling/v2beta2` (and the HPA `metrics:`
     list changes shape from the inline
     `targetAverageUtilization`-style entries to the value-driven
     `.Values.autoscaling.metrics` list — default `metrics: []`, so no
     metrics are emitted unless the user sets them).
  3. `ServiceAccount.metadata.name` now honours `.Values.serviceAccount.name`
     when set (previously ignored — bug fix).
  4. Cosmetic label / indentation deltas enumerated in
     `docs/common-chart.md` §"Cosmetic (non-breaking) deltas".
- Running `./lint.sh` at repo root still exits 0.

### Step 3: Bump chart version, add CHANGELOG.md and verify render parity

**Goal.** Record the migration, bump the chart version, and commit the
render-parity evidence so reviewers can confirm the diff matches the
documented deltas.

**Files affected.**

- `charts/scorpio-broker-aaio/Chart.yaml`
  - Bump `version: 0.4.12` → `0.5.0` (minor bump — new `common` dependency
    and breaking-but-documented changes to the `autoscaling` value shape
    and the ServiceAccount name resolution justify a minor rev rather
    than a patch, mirroring the mintaka migration).
  - Leave `appVersion: "2.1.0"` unchanged — the packaged Scorpio Broker
    AAIO binary is not touched.

- `charts/scorpio-broker-aaio/CHANGELOG.md` (new file) — model on
  `charts/mintaka/CHANGELOG.md`. Include:
  - A `## 0.5.0` section titled "Common library chart migration" that
    lists every file touched in Steps 1 and 2.
  - A "Breaking changes" subsection calling out:
    1. `autoscaling.apiVersion` now surfaces as a value (default
       `"v2beta2"`; users on Kubernetes 1.26+ may override to `"v2"`).
    2. `autoscaling.targetCPUUtilizationPercentage` /
       `autoscaling.targetMemoryUtilizationPercentage` removed; users who
       customised them must port to `autoscaling.metrics: []` (example
       in the CHANGELOG).
    3. Explicit `metadata.namespace` on the migrated resources (no-op
       for runtime, visible in rendered YAML).
    4. `ServiceAccount` resource name now honours
       `.Values.serviceAccount.name`.
  - A "Non-breaking cosmetic changes" subsection listing the label /
    indentation / base64 scalar deltas enumerated in
    `docs/common-chart.md`.
  - An "Upgrade path" paragraph explaining that `helm upgrade` of an
    existing release is a no-op for the Service / Deployment selector
    pair and a field update for the remaining resources.

- `docs/common-chart.md` — under "Charts migrated so far", append a new
  bullet: `- \`scorpio-broker-aaio\` — see
  \`charts/scorpio-broker-aaio/CHANGELOG.md\`.`

**Acceptance criteria.**

- `./build.sh` (which runs `helm dependency update` across all charts)
  completes without errors — confirms the new `file://../common`
  dependency resolves.
- `./lint.sh` exits 0.
- `./eval.sh` (renders every chart and runs kubeconform) exits 0.
- The PR body includes the captured
  `diff <(helm template charts/scorpio-broker-aaio @main) <(helm template
  charts/scorpio-broker-aaio @branch)` output so reviewers can confirm it
  matches the CHANGELOG's breaking-changes list.
- `charts/scorpio-broker-aaio/CHANGELOG.md` version heading matches the
  new `Chart.yaml` version (`0.5.0`).
