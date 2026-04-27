# Implementation Plan: Update chart onboarding-portal to use common chart

## Overview

Migrate `charts/onboarding-portal` to consume the FIWARE `common` library
chart (`charts/common`) — following the pattern already applied to
`orion`, `keyrock`, `mintaka` and `fdsc-dashboard` and documented in
`docs/common-chart.md`. The migration is mechanical:

1. declare the `common` dependency in `Chart.yaml`,
2. rewrite `templates/_helpers.tpl` so the existing `onboarding.*`
   helpers become thin wrappers over `common.*`,
3. replace the resource bodies that map cleanly to the library
   (`service.yaml`) with one-line `include` calls, and
4. document the bump in a `CHANGELOG.md`.

Templates that do **not** map to the library surface stay chart-local:

- `deployment.yaml` — bespoke env vars, configmap volume mount, PVC volume
  mount, liveness/readiness probes. No `common.deployment.tpl` exists.
- `configmap.yaml` — bespoke `application.yaml` rendered from
  `.Values.config`.
- `pvc.yaml` — bespoke PVC body.
- `ingress.yaml` — **must stay chart-local** because the
  `.Values.ingress.hosts[].paths` schema uses objects
  `{path, pathType}`, whereas `common.ingress.tpl` expects a list of
  strings and hard-codes `pathType: Prefix`. Migrating to the common
  helper would silently drop per-path `pathType` overrides, which is a
  breaking change to users. The ticket explicitly asks for a
  *minimally breaking* migration, so the ingress body is kept as-is —
  its `include "onboarding.fullname" .` and `include "onboarding.labels" .`
  references still resolve, because those helpers become wrappers over
  `common.*`.

The chart does not ship `serviceaccount.yaml`, `secret.yaml`,
`route.yaml` or `deployment-hpa.yaml`, so there is nothing else to fold
into the library on this pass.

### Render parity

The rendered YAML must match pre-migration output except for the
deltas documented under "Breaking changes" in `docs/common-chart.md`:

- `metadata.namespace: {{ .Release.Namespace }}` appears on the
  migrated `Service`. The `Deployment`, `ConfigMap`, `PVC` and
  `Ingress` bodies keep their current shape (no namespace field)
  because they are not migrated to `common.*` helpers in this pass.
- The leading blank line inside the labels block on the `Service`
  disappears (a side-effect of the legacy `{{ include
  "onboarding.labels" . | nindent 4 }}` pattern). Chart-local
  templates (Deployment / ConfigMap / PVC / Ingress) still carry the
  blank line.

No change to the selector labels on `Service` / `Deployment` — `helm
upgrade` of an existing release stays a safe operation.

## Steps

### Step 1: Declare `common` dependency in `Chart.yaml`

**Files:**

- `charts/onboarding-portal/Chart.yaml`

**Changes:**

1. Bump `version` from `1.2.6` → `1.3.0` (minor bump, new dependency +
   template surface change).
2. Add a top-level `dependencies:` block identical in shape to
   `charts/mintaka/Chart.yaml` and `charts/keyrock/Chart.yaml`:

   ```yaml
   # The `common` library chart ships every shared helper
   # (names, labels, service-account resolution, existing-secret
   # resolution, service/ingress/route/HPA/secret/serviceaccount
   # bodies). It is consumed via the published FIWARE helm repo so
   # publishing workflows do not need a separate repository entry —
   # Helm packages the library alongside onboarding-portal in the
   # resulting `onboarding-portal-<version>.tgz`. See
   # charts/common/README.md.
   dependencies:
     - name: common
       repository: "https://fiware.github.io/helm-charts"
       version: "0.0.1"
   ```

   Use the same `repository` + `version` values already hard-coded in
   `charts/mintaka/Chart.yaml` and `charts/keyrock/Chart.yaml`; do not
   use the `file://` form from the migration doc — every migrated chart
   in this repo uses the published-repo form, so this chart should too
   (keeps CI / `helm dependency update` behaviour uniform).

   The existing `Chart.yaml` is already `apiVersion: v2`, so no
   `apiVersion` bump is needed.

3. Leave every other field (`name`, `appVersion`, `type`, `description`,
   `icon`, `maintainers`, `keywords`, `sources`) untouched.

**Acceptance criteria:**

- `helm dependency update charts/onboarding-portal` resolves the
  `common` library chart and produces `charts/onboarding-portal/charts/common-0.0.1.tgz`
  (same artifact already produced for mintaka / keyrock).
- `helm lint charts/onboarding-portal` still passes.

### Step 2: Rewrite `templates/_helpers.tpl` as thin wrappers over `common.*`

**Files:**

- `charts/onboarding-portal/templates/_helpers.tpl`

**Changes:**

Replace the full body with wrappers — one `define` per existing helper
— mirroring `charts/mintaka/templates/_helpers.tpl`:

```gotemplate
{{/* vim: set filetype=mustache: */}}
{{/*
Onboarding-portal-specific helpers.

Every helper is now a thin wrapper around the matching `common.*` helper
from the `common` library chart (see charts/common/templates/*.tpl). The
wrappers exist so that external umbrella charts that already import
`include "onboarding.fullname" .` keep working.
*/}}

{{- define "onboarding.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{- define "onboarding.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "onboarding.chart" -}}
{{- include "common.names.chart" . -}}
{{- end -}}

{{- define "onboarding.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}

{{- define "onboarding.selectorLabels" -}}
{{- include "common.labels.matchLabels" . -}}
{{- end -}}
```

Notes:

- `onboarding.labels` is redefined to delegate directly to
  `common.labels.standard`. The legacy body was the "modern" variant
  (`labels` → `selectorLabels` delegation + `helm.sh/chart` +
  `app.kubernetes.io/version` + `managed-by`); the 5 emitted labels
  match `common.labels.standard` byte-for-byte.
- `onboarding.selectorLabels` is preserved as a wrapper over
  `common.labels.matchLabels` — the 2 emitted labels match exactly.
- No `onboarding.serviceAccountName` helper exists today and no
  `serviceaccount.yaml` is rendered, so no SA helper is added.

**Acceptance criteria:**

- `helm template charts/onboarding-portal` produces the same rendered
  YAML as on `main` for `deployment.yaml`, `configmap.yaml`, `pvc.yaml`
  and `ingress.yaml` — these keep using the chart-local wrappers, and
  the wrappers resolve to identical strings.
- Run the explicit diff to prove it:

  ```bash
  git worktree add /tmp/main-onboarding main
  helm template rel charts/onboarding-portal \
      --namespace onboarding \
      --set ingress.enabled=true \
      --set persistence.enabled=true \
      --set persistence.create=true \
      > /tmp/onboarding-branch.yaml
  helm template rel /tmp/main-onboarding/charts/onboarding-portal \
      --namespace onboarding \
      --set ingress.enabled=true \
      --set persistence.enabled=true \
      --set persistence.create=true \
      > /tmp/onboarding-main.yaml
  diff -u /tmp/onboarding-main.yaml /tmp/onboarding-branch.yaml
  ```

  Must print a byte-identical diff (empty) after Step 2 alone. Step 3
  introduces the expected deltas.

### Step 3: Migrate `templates/service.yaml` to `common.service.tpl`

**Files:**

- `charts/onboarding-portal/templates/service.yaml`

**Changes:**

Replace the full body with a one-line `include` call that mirrors the
shape used by `charts/mintaka/templates/service.yaml`:

```gotemplate
{{- include "common.service.tpl" (dict
      "context" $
      "service" .Values.service
      "ports"   (list (dict
                        "port"       .Values.service.port
                        "targetPort" "http"))) }}
```

Notes:

- `targetPort` is passed as the literal string `"http"` to match the
  existing `targetPort: http` (named-port reference to the container
  port). `common.service.tpl` accepts either int or string and emits
  the value verbatim.
- `protocol` and `name` are omitted — `common.service.tpl` defaults
  them to `TCP` and `http`, matching the current body.
- The selector uses `common.labels.matchLabels`, which emits the same
  2 labels (`app.kubernetes.io/name`, `app.kubernetes.io/instance`) as
  the existing `include "onboarding.selectorLabels" .` call.
- The labels block uses `common.labels.standard`, which emits the same
  5 labels as the existing `include "onboarding.labels" .` call.

Leave `templates/ingress.yaml`, `templates/deployment.yaml`,
`templates/configmap.yaml` and `templates/pvc.yaml` untouched. These
already reference `include "onboarding.fullname" .` and
`include "onboarding.labels" .`, which now resolve to the common
helpers transparently.

**Acceptance criteria:**

- Render diff between `main` and the branch (same command as Step 2)
  shows only the deltas documented under "Breaking changes" in
  `docs/common-chart.md`, i.e.:

  - `kind: Service` gains a `metadata.namespace: "<namespace>"` line.
  - The blank leading line inside `metadata.labels:` on the `Service`
    disappears.

  No other diff. In particular:

  - `Deployment`, `ConfigMap`, `PVC`, `Ingress` are byte-identical.
  - Selector labels on `Service` and `Deployment` are unchanged.

- `helm lint charts/onboarding-portal` passes.
- `helm template charts/onboarding-portal | kubeconform -strict -ignore-missing-schemas`
  passes.

### Step 4: Add `CHANGELOG.md` and run repo-wide validation

**Files:**

- `charts/onboarding-portal/CHANGELOG.md` (new)

**Changes:**

Create a new `CHANGELOG.md` modelled on
`charts/mintaka/CHANGELOG.md`, describing:

- `Chart.yaml` — `version 1.2.6` → `1.3.0`, new `common` dependency.
- `templates/_helpers.tpl` — `onboarding.name`, `onboarding.fullname`,
  `onboarding.chart`, `onboarding.labels`, `onboarding.selectorLabels`
  now delegate to `common.names.*` / `common.labels.*`. The
  `onboarding.*` prefix is preserved so any external umbrella chart
  that imports these helpers keeps working.
- `templates/service.yaml` — now a one-line `common.service.tpl` call.
- `templates/ingress.yaml`, `deployment.yaml`, `configmap.yaml`,
  `pvc.yaml` — **intentionally not migrated**; the ingress schema
  `{path, pathType}` is incompatible with `common.ingress.tpl`'s
  string-form paths (see Overview), and the other three bodies are
  chart-specific (no matching `common.*` helper exists).

Under *Breaking changes*, list:

- Explicit `metadata.namespace` on the rendered `Service`.
- No other behavioural change — Service selector labels,
  `Deployment`, `Ingress`, `ConfigMap`, `PVC` are byte-identical.

Under *Non-breaking cosmetic changes*:

- The leading blank line inside the labels block on the `Service`
  disappears.

Under *Upgrade path*:

- `helm upgrade` of an existing release is a no-op for the
  Service/Deployment selector pair, and a standard field update for
  the `Service` (adds `metadata.namespace`, drops one leading blank
  line). No data migration required.

**Acceptance criteria:**

- `./build.sh` (runs `helm dependency update` across every chart)
  succeeds.
- `./lint.sh` succeeds.
- `./eval.sh` succeeds (runs `helm template | kubeconform` per chart).
- Render-parity diff from Step 3 is documented in the PR body.

## Rollout / PR structure

The four steps above are mergeable as a single PR (pattern used for
`mintaka` and `fdsc-dashboard`) or as two PRs — Steps 1+2 (dependency
wiring, no rendered-YAML change) and Steps 3+4 (service migration +
CHANGELOG + repo-wide validation). The per-step acceptance criteria are
written so either structure works; the bootstrap will land each step
sequentially onto `ticket-21/work`.
