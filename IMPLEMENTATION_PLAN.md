# Implementation Plan: Update chart trusted-issuers-list to use common chart

## Overview
Migrate `charts/trusted-issuers-list` to depend on the in-repo `charts/common`
library chart, replacing every duplicated helper body and the mechanical
resource templates (ServiceAccount, Secret, HPA) with `include "common.*"`
calls. Chart-specific templates that do not map cleanly onto the current
`common.*` helper surface — the `til.serviceName`-based Service, the two
per-endpoint Ingresses (`-til` / `-tir` with hard-coded paths `/issuer` and
`/v4/issuers`), the two per-endpoint OpenShift Routes and their
cert-manager `Certificate` resources, the `initdata` ConfigMap/Job and
`til-configmap.yaml` — stay chart-local, but their helper calls are
rewritten to go through the preserved `til.*` wrappers which in turn
delegate to `common.*`. The migration follows
`docs/common-chart.md` and the reference migrations for `orion`,
`keyrock` and `mintaka`. Render parity with `main` must hold modulo the
documented breaking deltas (`apiVersion` v1→v2, explicit
`metadata.namespace`, `autoscaling.apiVersion` key,
`serviceAccount.name` honoured on the SA resource).

## Steps

### Step 1: Declare `common` dependency and rewrite `_helpers.tpl` as thin wrappers

**Files:**
- `charts/trusted-issuers-list/Chart.yaml`
- `charts/trusted-issuers-list/templates/_helpers.tpl`
- `charts/trusted-issuers-list/.gitignore` (new — mirrors
  `charts/mintaka/.gitignore`)

**Work:**

1. Bump `Chart.yaml`:
   - `apiVersion: v1` → `apiVersion: v2` (required to declare a library
     dependency; matches mintaka's migration).
   - Bump `version` (minor bump; concrete value set in Step 3 alongside
     the CHANGELOG entry).
   - Add a `dependencies:` block with a single local entry pointing at
     the in-repo library chart (use the `file://../common` form, matching
     `charts/fdsc-dashboard/Chart.yaml`, so publishing does not require a
     separate repository entry — `helm dependency update` resolves it
     against the sibling directory):
     ```yaml
     dependencies:
       - name: common
         repository: "file://../common"
         version: "0.0.1"
     ```
   - Keep every other existing field (`name`, `appVersion`, `description`,
     `icon`, `keywords`, `sources`, `maintainers`) verbatim.

2. Rewrite `templates/_helpers.tpl`. Preserve **every existing `til.*`
   include path** — external umbrella charts that call
   `include "til.fullname" .` must continue to resolve. The rewrite
   converts the seven canonical helpers into one-line delegations and
   leaves the two chart-specific helpers intact:

   | Helper                        | New body                                                      |
   | ----------------------------- | ------------------------------------------------------------- |
   | `til.name`                    | `include "common.names.name" .`                               |
   | `til.fullname`                | `include "common.names.fullname" .`                           |
   | `til.chart`                   | `include "common.names.chart" .`                              |
   | `til.serviceAccountName`      | `include "common.serviceAccount.name" .`                      |
   | `til.labels`                  | `include "common.labels.standard" .`                          |
   | `til.secretName`              | wrapper over `common.secrets.name` — see below                |
   | `til.passwordKey`             | wrapper over `common.secrets.key` — see below                 |
   | `til.serviceName`             | **unchanged** (chart-specific; reads `service.serviceNameOverride`) |
   | `til.app.config`              | **unchanged** (chart-specific micronaut/datasource renderer)  |

3. The two secret helpers gate their delegation on
   `.Values.database.existingSecret.enabled` so that a release with
   `enabled: false` but a populated `name` / `key` still falls through to
   `<fullname>` and `password` — byte-for-byte match with today's
   `secret.yaml` and deployment env wiring:

   ```gotemplate
   {{- define "til.secretName" -}}
   {{- $existing := "" -}}
   {{- if .Values.database.existingSecret.enabled -}}
   {{-   $existing = .Values.database.existingSecret -}}
   {{- end -}}
   {{- include "common.secrets.name"
         (dict "context" . "existingSecret" $existing) -}}
   {{- end -}}

   {{- define "til.passwordKey" -}}
   {{- $existing := "" -}}
   {{- if .Values.database.existingSecret.enabled -}}
   {{-   $existing = .Values.database.existingSecret -}}
   {{- end -}}
   {{- include "common.secrets.key"
         (dict "context" . "existingSecret" $existing "defaultKey" "password") -}}
   {{- end -}}
   ```

4. Add `.gitignore` mirroring `charts/mintaka/.gitignore` — ignore
   `Chart.lock` and the `charts/` subdirectory (the `common-<version>.tgz`
   pulled in by `helm dependency update` must not be committed).

**Acceptance criteria:**

- `helm dependency update charts/trusted-issuers-list` resolves the
  `common` library without error (run via `./build.sh` to confirm the
  repo-level script still succeeds).
- `helm lint charts/trusted-issuers-list` is clean.
- `helm template charts/trusted-issuers-list` renders the same set of
  resources as `main` — the templates still call the `til.*` helpers, so
  render output is unchanged at this step.
- `diff <(git show main:charts/trusted-issuers-list/...) <(helm template …)` is
  empty (modulo any whitespace-only label-block differences that the
  common `labels` helper introduces — these are documented cosmetic
  deltas already cross-referenced in `docs/common-chart.md`; none of
  them apply at this step because the resource templates still inline
  the helper calls).

### Step 2: Replace the standard mechanical resource templates with `common.*` includes

**Files:**
- `charts/trusted-issuers-list/templates/serviceaccount.yaml`
- `charts/trusted-issuers-list/templates/secret.yaml`
- `charts/trusted-issuers-list/templates/deployment-hpa.yaml`
- `charts/trusted-issuers-list/values.yaml`

**Work:**

1. Replace `serviceaccount.yaml` with a single include:
   ```gotemplate
   {{- include "common.serviceAccount.tpl" (dict "context" $) }}
   ```

2. Replace `secret.yaml` with a single include that passes the
   enabled-gated `existingSecret`, plus the chart's secret body
   (`password` key, b64-encoded from `.Values.database.password`):
   ```gotemplate
   {{- include "common.secret.tpl" (dict
         "context"        $
         "existingSecret" (ternary .Values.database.existingSecret ""
                            .Values.database.existingSecret.enabled)
         "data"           (dict "password" .Values.database.password)) }}
   ```
   (The exact call signature must match what `common.secret.tpl` in
   `charts/common/templates/_secret.tpl` expects — the step implementer
   must `grep` that helper first and adjust the `dict` keys to the
   helper's documented contract. The `common.secret.tpl` helper renders
   nothing when an existing secret is supplied, mirroring today's
   `{{- if not .Values.database.existingSecret.enabled -}}` guard.)

3. Replace `deployment-hpa.yaml` with a single include:
   ```gotemplate
   {{- include "common.hpa.tpl" (dict
         "context"     $
         "autoscaling" .Values.autoscaling) }}
   ```

4. Add `apiVersion: v2beta2` under `.Values.autoscaling` in
   `values.yaml` so the rendered HPA keeps emitting
   `autoscaling/v2beta2` (the default inside `common.hpa.tpl` is
   `v2` — without this line the migration would silently change the
   HPA apiVersion, which is a runtime-visible break on older clusters):
   ```yaml
   autoscaling:
     # -- HorizontalPodAutoscaler apiVersion. Defaults to v2beta2 to
     # -- preserve byte-for-byte parity with the legacy template;
     # -- set to "v2" on Kubernetes 1.26+.
     apiVersion: v2beta2
     enabled: false
     minReplicas: 1
     …
   ```

5. **Do NOT migrate** any of the following — they either do not map onto
   the current `common.*` surface or would lose chart-specific
   behaviour, and the ticket asks to keep the migration minimally
   breaking:

   | Template                         | Reason it stays chart-local                                                                                                         |
   | -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
   | `service.yaml`                   | `common.service.tpl` uses `common.names.fullname` for the Service name; this chart honours `.Values.service.serviceNameOverride` via `til.serviceName`. |
   | `ingress-til.yaml`               | `common.ingress.tpl` hard-codes `name: <fullname>`; this chart needs `<fullname>-til`, hard-coded `path: /issuer`, and expects `hosts[]` entries without a `paths` list. |
   | `ingress-tir.yaml`               | Same as above, with `path: /v4/issuers`.                                                                                            |
   | `route-til.yaml` / `route-tir.yaml` | `common.route.tpl` hard-codes `name: <fullname>` and `to.name: <fullname>`; this chart needs `<fullname>-til` / `<fullname>-tir`, a custom `path:`, and `to.name: {{ include "til.serviceName" . }}`, plus the `cert-utils-operator.redhat-cop.io/certs-from-secret` annotation. |
   | `route-til-certificate.yaml` / `route-tir-certificate.yaml` | cert-manager `Certificate` CR — no `common` helper exists.                                                   |
   | `deployment.yaml`                | High-variance body (env vars, probes, configmap volume, configmap checksum) — explicit non-goal in `docs/common-chart.md`. References `til.*` helpers which are already wrappers after Step 1. |
   | `til-configmap.yaml`             | Renders `til.app.config`, chart-specific.                                                                                           |
   | `initdata-cm.yaml`, `post-hook-initdata.yaml` | Chart-specific post-install Job + ConfigMap.                                                                                       |

**Acceptance criteria:**

- `./lint.sh` passes for the whole repo.
- `helm template charts/trusted-issuers-list` renders all three
  migrated manifests with the documented breaking deltas only:
  explicit `metadata.namespace`, `autoscaling.apiVersion: v2beta2` still
  emitted (because of the new default), `ServiceAccount` `metadata.name`
  honours `.Values.serviceAccount.name` when set. No other diff.
- `helm template … | kubeconform -strict -ignore-missing-schemas`
  validates clean (the `cert-manager` Certificate and OpenShift Route
  CRDs stay behind `-ignore-missing-schemas`, as today).

### Step 3: CHANGELOG, version bump and render-parity verification

**Files:**
- `charts/trusted-issuers-list/CHANGELOG.md` (new — mirrors
  `charts/mintaka/CHANGELOG.md`)
- `charts/trusted-issuers-list/Chart.yaml` (set the final `version:`)
- `charts/trusted-issuers-list/README.md` (regenerated from
  `values.yaml` via `helm-docs`, if the repo uses the standard tool —
  the step implementer confirms by running the same command used for
  the mintaka migration)

**Work:**

1. Add `CHANGELOG.md` at the chart root following the
   `charts/mintaka/CHANGELOG.md` structure:
   - Heading with the new chart version.
   - **Common library chart migration** section listing
     `Chart.yaml` apiVersion / version / dependency bumps, the
     `_helpers.tpl` rewrite, and the per-template migrations
     (`serviceaccount.yaml` → `common.serviceAccount.tpl`,
     `secret.yaml` → `common.secret.tpl`,
     `deployment-hpa.yaml` → `common.hpa.tpl`).
   - Explicitly list the templates that were **not** migrated and the
     reason — users reading the CHANGELOG must be able to tell where
     the `common` surface stops for this chart (Service, Ingresses,
     Routes, Route certificates, `deployment.yaml`, `til-configmap.yaml`,
     `initdata-cm.yaml`, `post-hook-initdata.yaml`).
   - **Breaking changes** section cross-referencing
     `docs/common-chart.md#breaking-changes`:
       - Explicit `metadata.namespace` on Secret / HPA / ServiceAccount.
       - `autoscaling.apiVersion` surfaced as a values key (default
         `v2beta2` keeps byte-for-byte parity).
       - `ServiceAccount` resource `metadata.name` now honours
         `.Values.serviceAccount.name`.
   - **Non-breaking cosmetic deltas** — blank-line-in-labels and
     base64 scalar rendering, same wording as the mintaka CHANGELOG.
   - **Upgrade path** — `helm upgrade` is a no-op for the
     Service / Deployment selector pair and a standard field update for
     the Secret / HPA / ServiceAccount.

2. Set the final `version:` in `Chart.yaml` (follow the mintaka
   precedent: minor bump for a dependency/helper migration, e.g.
   `0.16.2` → `0.18.0`).

3. Regenerate `README.md` from `values.yaml` (the new
   `autoscaling.apiVersion` key must appear in the values table).

4. Render-parity verification — capture before/after manifests and
   diff them:
   ```bash
   git show main:charts/trusted-issuers-list/...  # baseline
   helm template charts/trusted-issuers-list > /tmp/after.yaml
   # for each of: default values, ingress.til.enabled=true,
   # ingress.tir.enabled=true, route.til.enabled=true,
   # route.tir.enabled=true, autoscaling.enabled=true,
   # database.persistence=true, database.existingSecret.enabled=true.
   diff -u /tmp/before.yaml /tmp/after.yaml
   ```
   The diff must be empty except for the documented breaking deltas
   above.

5. Run the repo-wide CI entry points:
   - `./build.sh` — `helm dependency update` for every chart.
   - `./lint.sh` — `helm lint` for every chart.
   - `./eval.sh` — `helm template | kubeconform -strict
     -ignore-missing-schemas` for every chart.
   All three must exit 0.

**Acceptance criteria:**

- `CHANGELOG.md` is present, follows the mintaka structure, and covers
  every breaking delta that the render-diff surfaces.
- `Chart.yaml` carries the final bumped version.
- `README.md` is regenerated and lists `autoscaling.apiVersion` in the
  values table.
- `./build.sh`, `./lint.sh`, `./eval.sh` all pass.
- Render-parity diffs against `main` only surface the deltas the
  CHANGELOG documents.
