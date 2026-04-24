# Implementation Plan: Update chart scorpio-broker to use common chart

## Overview

Wire the multi-component `charts/scorpio-broker` chart up to the in-repo
`charts/common` library chart, following the migration pattern documented
in `docs/common-chart.md` and already applied to `orion`, `keyrock` and
`mintaka`. Because `scorpio-broker` is a 10-component chart that has no
single Deployment / Ingress / Route / Secret / ServiceAccount, the
migration surface is narrower than the prior single-component charts: it
covers the 7 helper families (names, labels, chart, selectorLabels,
serviceAccountName, plus per-component variants), the 10 component
Services, the 2 extra NodePort Services, and the 10 component HPAs. The
Deployment bodies stay chart-local (out of scope for `common.*`). The
migration is executed in five sequential PRs so each step produces a
reviewable render-parity diff and a working chart.

The steering principle from `docs/common-chart.md` is **"render-diff
must be empty"** except for the accepted breaking changes listed in that
document (explicit `metadata.namespace`, `autoscaling.apiVersion` as a
value, ServiceAccount name honours `.Values.serviceAccount.name`), plus
the accepted cosmetic whitespace differences. Each step must be verified
by rendering `helm template charts/scorpio-broker` against `main` and
the step branch and confirming the diff is within those bounds.

### Inputs the implementer can assume are stable

- `charts/common` exposes `common.names.{name,fullname,chart,namespace}`,
  `common.labels.{standard,matchLabels}`,
  `common.serviceAccount.{name,tpl}`, `common.service.tpl`,
  `common.hpa.tpl`. Helpers accept either the root context or a
  `(dict "context" $ "component" "<name>")` dict.
- Prior reference migrations: `charts/orion`, `charts/keyrock`,
  `charts/mintaka` (each ships a `CHANGELOG.md` documenting the bump).
- `docs/common-chart.md` — authoritative documentation; the
  [Breaking changes](../docs/common-chart.md#breaking-changes) list is
  the upper bound of what render-diff may contain.
- `build.sh`, `lint.sh`, `eval.sh` are the CI entry points and must keep
  passing.

### Out of scope (keeps the migration minimal)

- The 10 per-component Deployment bodies
  (`<component>-deployment.yaml` + `history-manager-development.yaml`)
  — `docs/common-chart.md` explicitly lists Deployments as a non-goal
  of the library. They keep using chart-local references to
  `<component>.fullname` / `<component>.labels` /
  `<component>.matchLabels`, which become thin wrappers over
  `common.*`.
- Introducing a `templates/serviceaccount.yaml` for scorpio-broker.
  The chart ships no top-level ServiceAccount today (per-component
  `serviceAccount.enabled/name` values pass through to each Deployment's
  pod spec). Adding one is a separate feature and outside the
  minimal-breaking scope of this ticket.
- Normalising the per-component values-schema of `hpa:` to something
  more homogeneous than what Step 4 requires. The restructure in
  Step 4 is exactly what `common.hpa.tpl` needs — not a broader clean-up.

### Accepted breaking changes (to be enumerated in the CHANGELOG)

These mirror the deltas called out in `docs/common-chart.md` for prior
migrations, plus one scorpio-specific item:

1. **Explicit `metadata.namespace`** on Service and HPA manifests.
   Cosmetic — no behavioural change.
2. **`autoscaling.apiVersion` surfaced as a value.** The legacy
   per-component `<component>-hpa.yaml` templates hard-coded
   `autoscaling/v1` with `spec.targetCPUUtilizationPercentage`.
   `common.hpa.tpl` emits `autoscaling/{{ default "v2"
   $autoscaling.apiVersion }}` with a `spec.metrics:` list. Users on
   Kubernetes < 1.23 (which removed `autoscaling/v2beta2`) can keep the
   old behaviour by setting `apiVersion: v2beta1` / `v2beta2` on each
   component's `hpa:` block; the Step 4 values restructure adds the
   key with a default that matches the rest of the fleet.
3. **Per-component `hpa:` values block restructured** from
   `{enabled, minReplicas, maxReplicas, targetCPUUtilizationPercentage}`
   to `{enabled, minReplicas, maxReplicas, apiVersion, metrics}` —
   necessary to call `common.hpa.tpl`. Defaults reproduce the rendered
   v1 HPA's 80% CPU target as a v2 `Resource`/`cpu`/`Utilization` metric.
   This is the only values-schema break; it is flagged in the
   CHANGELOG with a before/after example for users who set
   `targetCPUUtilizationPercentage` explicitly.
4. **Selector and label schema aligned with the rest of FIWARE.**
   The legacy scorpio label set (`app`, `release`, `component`,
   `chart`, `heritage`) is replaced with the canonical
   `app.kubernetes.io/{name,instance,component,version,managed-by}` +
   `helm.sh/chart` set emitted by `common.labels.standard` /
   `common.labels.matchLabels`. The per-component
   `app.kubernetes.io/component: <component>` line is added via the
   helpers' `component` argument. Because Deployment `spec.selector` is
   immutable, **in-place `helm upgrade` of a pre-migration release is
   not supported** — operators must uninstall / re-install, or pin the
   pre-migration chart version. This is the largest behavioural break
   and must be the headline of the scorpio-broker CHANGELOG entry.

### Chart version bump

Bump `charts/scorpio-broker/Chart.yaml` `version: 0.2.0` → `0.3.0`
(minor bump signalling the added dependency and the breaking deltas).
`appVersion` stays at `2.1.0` — the scorpio image tags are unchanged.

---

## Steps

### Step 1: Declare the `common` dependency and wire `_helpers.tpl` through it

**Scope:** `charts/scorpio-broker/Chart.yaml`,
`charts/scorpio-broker/templates/_helpers.tpl`,
`charts/scorpio-broker/.helmignore` (if needed),
`charts/scorpio-broker/.gitignore` (new).

**Work:**

1. `Chart.yaml`:
   - Bump `version: 0.2.0` → `0.3.0`.
   - Add a `dependencies:` entry pointing at the local library chart:
     ```yaml
     dependencies:
       - name: common
         repository: "file://../common"
         version: "0.0.2"
     ```
   - Mirror the commentary block already present in
     `charts/mintaka/Chart.yaml` / `charts/orion/Chart.yaml` explaining
     why the dependency is declared `file://`.

2. `templates/_helpers.tpl` — full rewrite. Replace every existing
   helper body with a thin `include` of the matching `common.*` helper.
   Preserve the `scorpio-broker-dist.*` namespace and the per-component
   helper names so external umbrella charts that import
   `scorpio-broker-dist.fullname` / `eureka.fullname` /
   `atContextServer.labels` / etc. keep working. Concretely:

   - **Chart-wide helpers (root context, no component):**
     - `scorpio-broker-dist.name` → `include "common.names.name" .`
     - `scorpio-broker-dist.fullname` → `include "common.names.fullname" .`
     - `scorpio-broker-dist.chart` → `include "common.names.chart" .`
     - `scorpio-broker-dist.selectorLabels` →
       `include "common.labels.matchLabels" .`
     - `scorpio-broker-dist.serviceAccountName` →
       `include "common.serviceAccount.name" .` (NB: the legacy helper
       reads `.Values.serviceAccount.{create,name}` which don't exist
       at the top level of `values.yaml` — step 5 confirms render
       parity; if the legacy helper is unreferenced by any template
       the delegate can simply match orion's body).

   - **Per-component helpers — each takes the root context but passes
     `{"context": $, "component": .Values.<component>.name}` to the
     common helpers.** For each of `atContextServer`, `configServer`,
     `entityManager`, `gateway`, `eureka`, `historyManager`,
     `queryManager`, `registryManager`, `registrySubscriptionManager`,
     `subscriptionManager`:
     - `<component>.fullname` →
       `include "common.names.fullname" (dict "context" . "component" .Values.<component>.name)`.
     - `<component>.labels` →
       `include "common.labels.standard" (dict "context" . "component" .Values.<component>.name)`.
     - `<component>.matchLabels` →
       `include "common.labels.matchLabels" (dict "context" . "component" .Values.<component>.name)`.

   - **Shared label fragments** — the legacy
     `scorpio-broker-dist.common.matchLabels` /
     `scorpio-broker-dist.common.metaLabels` helpers are removed
     because their output is now subsumed into
     `common.labels.matchLabels` / `common.labels.standard`. Any
     template that referenced them directly is updated in later steps.

3. `.gitignore`: add `Chart.lock` and `charts/` (the resolved
   `common-0.0.2.tgz` lives there after `helm dependency update` and is
   not committed). Match `charts/mintaka/.gitignore` exactly.

**Acceptance:**

- `helm dependency update charts/scorpio-broker` produces a
  `Chart.lock` and a `charts/common-0.0.2.tgz` without errors.
- `helm lint charts/scorpio-broker` is clean.
- `helm template charts/scorpio-broker` renders. The render-diff vs.
  `main` is **non-empty** in this step (labels switch to the
  canonical schema) and must be exactly the delta enumerated above —
  no other differences. Commit the diff output to the PR body for
  reviewer cross-check.
- `./lint.sh` and `./eval.sh` both exit 0.

---

### Step 2: Migrate the ten component ClusterIP Services to `common.service.tpl`

**Scope:** `charts/scorpio-broker/templates/atcontext-server-service.yaml`,
`config-server-service.yaml`, `entity-manager-service.yaml`,
`eureka-service.yaml`, `gateway-service.yaml`,
`history-manager-service.yaml`, `query-manager-service.yaml`,
`registration-manager-service.yaml`,
`registration-subscription-manager-service.yaml`,
`subscription-manager-service.yaml`; plus additions to
`charts/scorpio-broker/values.yaml`.

**Work:**

1. `values.yaml`: each component currently lacks a `service:` block (only
   `eureka` and `gateway` have one today, and both are NodePort). Add a
   ClusterIP-shaped `service:` block per component, with a `port` that
   matches the port hard-coded in the legacy Service body:
   - `atContextServer.service`: `{ type: ClusterIP, port: 27015 }`
   - `configServer.service`: `{ type: ClusterIP, port: 8888 }`
   - `entityManager.service`: `{ type: ClusterIP, port: 1025 }`
   - `gateway.service`: already present; keep its NodePort shape but
     note Step 3 handles the NodePort variant — the ClusterIP
     `gateway-service.yaml` migration uses the same values block with
     `type: ClusterIP` overridden inline via the dict passed to
     `common.service.tpl` (or introduce a `gateway.clusterIpService`
     sub-block — implementer chooses the cleaner variant).
   - `eureka.service`: same — Step 3 owns the NodePort; the ClusterIP
     variant overrides `type` inline.
   - `historyManager.service`: `{ type: ClusterIP, port: 1040 }`
   - `queryManager.service`: `{ type: ClusterIP, port: 1026 }`
   - `registryManager.service`: `{ type: ClusterIP, port: 1030 }`
   - `registrySubscriptionManager.service`: `{ type: ClusterIP, port:
     <existing hard-coded port — verify from the legacy template> }`
   - `subscriptionManager.service`: `{ type: ClusterIP, port: <existing
     hard-coded port — verify from the legacy template> }`

2. Each component Service template becomes a single-line include:
   ```yaml
   {{- if .Values.<component>.enabled }}
   {{- include "common.service.tpl" (dict
         "context" $
         "component" .Values.<component>.name
         "service" .Values.<component>.service
         "ports" (list (dict
                         "port"       .Values.<component>.service.port
                         "name"       (quote .Values.<component>.service.port)))) }}
   {{- end }}
   ```
   The `name` field quotes the port number to reproduce the legacy
   `- name: "27015"` string-typed port names (common defaults `name` to
   `"http"` otherwise — which would be a second breaking change
   unless overridden).

3. Preserve the `{{- if .Values.<component>.enabled }}` guard on every
   service.

**Acceptance:**

- Render-diff of each migrated service vs. `main` shows only the
  `docs/common-chart.md` breaking/cosmetic deltas (explicit namespace,
  label schema aligned in Step 1, whitespace).
- `./lint.sh` + `./eval.sh` exit 0.
- Each component's Deployment still matches its Service selector
  (Deployments pick up the new label schema via their chart-local
  `<component>.matchLabels` include, which is now a `common.*` wrapper
  courtesy of Step 1).

---

### Step 3: Migrate the two NodePort Services (`eureka-node-port.yaml`, `scorpio-gateway-node-port-svc.yaml`)

**Scope:** `charts/scorpio-broker/templates/eureka-node-port.yaml`,
`charts/scorpio-broker/templates/scorpio-gateway-node-port-svc.yaml`,
`charts/scorpio-broker/values.yaml` (document the `service.nodePort`
field that already exists).

**Rationale:** `common.service.tpl`'s port schema today supports
`{port, targetPort, protocol, name}` but does **not** expose
`nodePort`. Adding `nodePort` to `common.service.tpl` is an optional
enhancement for the implementer to consider — if added, both NodePort
templates collapse to one-line includes like Step 2. If not added, the
templates stay chart-local but switch every helper reference to the
new common-backed wrappers.

**Work — path A (if `common.service.tpl` is extended with a per-port
`nodePort` field):**

1. Extend `charts/common/templates/_service.tpl` to render
   `nodePort: <value>` when present on a port map, preserving the
   `nodePort: null` fallback when `service.type == "ClusterIP"` (used
   by both scorpio NodePort templates).
2. Update the port-name documentation block to mention the new
   `nodePort` field.
3. Rewrite `eureka-node-port.yaml` and `scorpio-gateway-node-port-svc.yaml`
   as one-line `common.service.tpl` includes (see Step 2 shape, plus
   `"nodePort"` inside the port dict).
4. NB: `scorpio-gateway-node-port-svc.yaml` hard-codes
   `metadata.name: scorpio-gateway-service` (no include) — the common
   helper would emit `<release-name>-scorpio-broker-gateway` instead.
   Preserve the legacy name by adding a `nameOverride` to the `dict`
   **if** common's service helper is extended to accept one, else
   emit chart-local. Either way, document the decision in the CHANGELOG.

**Work — path B (keep the NodePort templates chart-local, minimal
churn):**

1. Update `eureka-node-port.yaml` and `scorpio-gateway-node-port-svc.yaml`
   to use the new `common.*`-backed wrappers (via `<component>.fullname`
   / `<component>.labels` / `<component>.matchLabels`, which now
   include a `component` arg). No other structural change.
2. Drop the explicit `namespace: {{ .Release.Namespace }}` line from
   `eureka-service.yaml` in Step 2 *only if* common renders it
   identically — otherwise keep it and note the difference.

**Acceptance (either path):**

- Render-diff shows no NodePort-behaviour change; the only deltas are
  the label schema (from Step 1) and explicit-namespace on legacy
  chart-local templates.
- `kubectl apply --dry-run=server` against a test cluster (or `helm
  template | kubeconform`) accepts both services.
- `./lint.sh` + `./eval.sh` pass.

Mark the path decision in the PR description so the reviewer can
verify the trade-off was considered.

---

### Step 4: Migrate the ten component HPAs to `common.hpa.tpl`

**Scope:** `charts/scorpio-broker/templates/atcontext-server-hpa.yaml`,
`config-server-hpa.yaml`, `entity-manager-hpa.yaml`,
`eureka-server-hpa.yaml`, `gateway-server-hpa.yaml`,
`history-manager-hpa.yaml`, `query-manager-hpa.yaml`,
`registration-manager-hpa.yaml`,
`registration-subscription-manager-hpa.yaml`,
`subscription-manager-hpa.yaml`; and
`charts/scorpio-broker/values.yaml`.

**Work:**

1. `values.yaml` — for each of the 10 components, replace the legacy
   `hpa:` block:
   ```yaml
   hpa:
     enabled: true
     minReplicas: 1
     maxReplicas: 5
     targetCPUUtilizationPercentage: 80
   ```
   with the `common.hpa.tpl`-compatible shape:
   ```yaml
   autoscaling:
     enabled: true
     apiVersion: v2beta2    # matches the value used by orion / mintaka
     minReplicas: 1
     maxReplicas: 5
     metrics:
       - type: Resource
         resource:
           name: cpu
           target:
             type: Utilization
             averageUtilization: 80
   ```
   Keep `hpa:` alongside `autoscaling:` for one release as a
   soft-deprecation (optional, documented in the CHANGELOG). Decision
   is left to the implementer — prior migrations just renamed.

2. Each HPA template becomes one line:
   ```yaml
   {{- if .Values.<component>.enabled }}
   {{- include "common.hpa.tpl" (dict
         "context"     $
         "component"   .Values.<component>.name
         "autoscaling" .Values.<component>.autoscaling) }}
   {{- end }}
   ```
   Preserve the outer `{{- if .Values.<component>.enabled }}` guard;
   `common.hpa.tpl` owns the inner `autoscaling.enabled` guard.

3. Legacy template file names are kept (`<component>-hpa.yaml`) so
   reviewers can `git diff` per file. The `-hpa` suffix formerly
   appended to the HPA resource name (`name: {{ ... }}-hpa`) is
   **dropped** — `common.hpa.tpl` emits `<fullname>` unsuffixed.
   Called out in the CHANGELOG.

**Acceptance:**

- Render-diff per HPA shows: `apiVersion: autoscaling/v1` →
  `autoscaling/v2beta2`, `targetCPUUtilizationPercentage: 80` →
  `metrics: [...]`, `metadata.name: <fullname>-hpa` → `<fullname>`,
  plus explicit `metadata.namespace` and the label-schema change from
  Step 1. No other deltas.
- `./lint.sh` + `./eval.sh` pass.
- The HPA `scaleTargetRef.name` still matches the Deployment
  `metadata.name` per component.

---

### Step 5: CHANGELOG, render-parity verification, final lint / eval

**Scope:** `charts/scorpio-broker/CHANGELOG.md` (new),
`charts/scorpio-broker/README.md` (if auto-regenerated from values),
`build.sh` / `lint.sh` / `eval.sh` output checks.

**Work:**

1. Create `charts/scorpio-broker/CHANGELOG.md` with a single `0.3.0`
   entry. Match the structure used by
   `charts/mintaka/CHANGELOG.md` / `charts/keyrock/CHANGELOG.md`:
   - **Common library chart migration** — list every file touched and
     which `common.*` helper replaced each one (helpers.tpl rewrite,
     10 services, 2 node-port services, 10 HPAs). Cross-reference
     Steps 1–4 of this plan.
   - **Breaking changes** — the four items from the Overview of this
     plan:
     - Selector / label schema aligned with FIWARE canonical set →
       in-place `helm upgrade` from `0.2.0` unsupported, re-install
       required.
     - Per-component `hpa:` values block renamed to `autoscaling:`
       with the v2 `metrics:` list shape. Include a before/after YAML
       snippet.
     - Explicit `metadata.namespace` on Service / HPA manifests.
     - HPA resource name drops the `-hpa` suffix.
   - **Non-breaking cosmetic changes** — the whitespace / HPA
     indentation deltas documented in `docs/common-chart.md`.
   - **Upgrade path** — explicit one-paragraph operator guidance for
     the selector break (uninstall, reinstall; or pin `0.2.0`).

2. If the repo uses `helm-docs` to regenerate per-chart READMEs, run
   it and commit the result. The monorepo presently checks in
   auto-generated READMEs (see `charts/orion/README.md`); keep them in
   sync or note that the auto-regen step is pending.

3. Render-parity gate:
   - `git worktree add /tmp/scorpio-main main`
   - `helm template /tmp/scorpio-main/charts/scorpio-broker > /tmp/a.yaml`
   - `helm template charts/scorpio-broker > /tmp/b.yaml`
   - `diff -u /tmp/a.yaml /tmp/b.yaml` — paste the diff into the Step 5
     PR body. Every hunk must correspond to a bullet under the
     "Breaking changes" or "Non-breaking cosmetic changes" section of
     the CHANGELOG. The reviewer treats any unclassified hunk as a
     blocking comment.

4. Full-repo checks:
   - `./build.sh` — `helm dependency update` for every chart. No
     regressions.
   - `./lint.sh` — every chart lints clean.
   - `./eval.sh` — every chart renders + passes `kubeconform -strict
     -ignore-missing-schemas`.

**Acceptance:**

- `./build.sh`, `./lint.sh`, `./eval.sh` all exit 0 on the full repo.
- The render-parity diff is fully explained by the CHANGELOG.
- `charts/scorpio-broker/CHANGELOG.md` covers the full ticket scope
  and mirrors the tone / structure of `charts/mintaka/CHANGELOG.md`.

---

## Testing matrix

Each step's PR must include:

1. `helm lint charts/scorpio-broker` — clean.
2. `helm template charts/scorpio-broker` — renders without error.
3. `helm template charts/scorpio-broker | kubeconform -strict
   -ignore-missing-schemas` — no schema errors.
4. Render-diff vs. `main` (text or attached) — every hunk explained.

Step 5 additionally gates on `./build.sh` / `./lint.sh` / `./eval.sh`
across the whole monorepo, confirming no other chart was collaterally
broken by the shared `common` library being resolved against a
fresh `helm dependency update`.
