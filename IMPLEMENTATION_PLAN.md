# Implementation Plan: Update chart did-helper to use common chart

## Overview

Migrate `charts/did-helper` onto the existing `charts/common` library chart,
following the documented consumer-chart migration pattern in
`docs/common-chart.md`. The goal is to eliminate the duplicated
`name / fullname / chart / labels / selectorLabels` helpers and the `service.yaml`
body in favour of thin wrappers over the canonical `common.*` helpers, while
preserving `did-helper`'s public surface (value keys, `did-helper.*` include
paths, rendered manifests) so existing releases upgrade as a no-op. The
`ingress.yaml`, `deployment.yaml` and `configmap.yaml` bodies stay chart-local
because the values schema (ingress paths-as-objects) and the bespoke env-var /
keystore plumbing fall outside the common helper surface.

## Steps

### Step 1: Wire the `common` dependency and migrate `_helpers.tpl` to wrappers

**Files**

- `charts/did-helper/Chart.yaml`
- `charts/did-helper/templates/_helpers.tpl`
- `charts/did-helper/.gitignore` (new — mirrors mintaka/keyrock/orion)

**Chart.yaml changes**

- Keep `apiVersion: v2` (`did-helper` is already on v2, so no version bump is
  needed for the library-dependency requirement).
- Add the `common` dependency block, matching the documented pattern. Prefer
  the same `repository: "file://../common"` form used by `fdsc-dashboard` (the
  reference "fully delegated" migration) so `helm dependency update` resolves
  from the working tree without a remote repo entry:

  ```yaml
  # The `common` library chart ships every shared helper
  # (names, labels, service-account resolution, existing-secret
  # resolution, service/ingress/route/HPA/secret/serviceaccount
  # bodies). It is consumed via a local `file://` dependency so
  # publishing workflows do not need a separate repository entry —
  # Helm packages the library alongside did-helper in the resulting
  # `did-helper-<version>.tgz`. See charts/common/README.md.
  dependencies:
    - name: common
      repository: "file://../common"
      version: "0.0.1"
  ```

- Bump `version: 0.1.16 → 0.1.17` (patch bump — no breaking changes to the
  public surface or values schema).

**`_helpers.tpl` rewrite**

Every existing helper becomes a one-line `include` over the matching
`common.*` helper, preserving the `did-helper.*` include paths for umbrella
charts. Keep the doc comments at the top explaining the wrapper rationale
(copy the mintaka wording and adapt). Specifically:

- `did-helper.name` → `include "common.names.name" .`
- `did-helper.fullname` → `include "common.names.fullname" .`
- `did-helper.chart` → `include "common.names.chart" .`
- `did-helper.labels` → `include "common.labels.standard" .`
- `did-helper.selectorLabels` → `include "common.labels.matchLabels" .`

No new `did-helper.serviceAccountName` / `did-helper.secretName` helpers are
introduced (the chart does not ship a ServiceAccount or Secret today;
introducing them would be out-of-scope scope creep).

**`.gitignore`**

Add a `.gitignore` in `charts/did-helper/` that excludes `Chart.lock` and the
`charts/` sub-directory (the resolved `common-<version>.tgz` is pulled in by
`helm dependency update` on install / publish and does not belong in git).
Mirror the file already present under `charts/mintaka/.gitignore` verbatim.

**Acceptance criteria**

- `helm dependency update charts/did-helper` resolves without error and
  produces a `charts/did-helper/charts/common-0.0.1.tgz` (not committed).
- `helm lint charts/did-helper` passes.
- `helm template charts/did-helper` renders without error and produces
  manifests whose rendered YAML agrees with the pre-migration output modulo
  (a) the blank leading line inside label blocks (expected cosmetic delta,
  see `docs/common-chart.md#cosmetic-non-breaking-deltas`) and (b) label-key
  ordering inside the label map (YAML-equivalent).

### Step 2: Replace `service.yaml` with `common.service.tpl` and verify render parity

**Files**

- `charts/did-helper/templates/service.yaml`

**`service.yaml` rewrite**

Collapse the entire body to a single `include` call over `common.service.tpl`,
passing `.Values.service` and a single `ports` entry that pins
`targetPort: "http"` (the legacy body hard-codes `targetPort: http`; keep it to
preserve render parity with the pre-migration manifest):

```yaml
{{- include "common.service.tpl" (dict
      "context" $
      "service" .Values.service
      "ports"   (list (dict
                        "port"       .Values.service.port
                        "targetPort" "http"))) }}
```

**`ingress.yaml`, `deployment.yaml`, `configmap.yaml` — intentionally left alone**

- `ingress.yaml`: `.Values.ingress.hosts[].paths` uses the
  object-form (`{ path: "/", pathType: ImplementationSpecific }`) whereas
  `common.ingress.tpl` expects a string-list and hard-codes
  `pathType: Prefix`. Migrating would require a breaking values-schema change,
  so the file stays chart-local. It continues to reference
  `did-helper.fullname` / `did-helper.labels`, which resolve through the new
  wrappers.
- `deployment.yaml`: contains did-helper-specific env-var plumbing
  (`config.server` / `config.generateKey` / `config.provideKeystore`
  ConfigMapKeyRef blocks and the optional `keystore-volume` secret mount)
  that has no counterpart in the common helper surface — kept chart-local
  per the documented non-goals (`docs/common-chart.md#non-goals`).
- `configmap.yaml`: did-helper-specific ConfigMap renderer for
  `generateKey` vs. `provideKeystore`; kept chart-local.

**Render-parity verification**

Produce a pre/post render diff and attach it to the PR description:

```bash
# Pre-migration baseline, from the tip of main
git worktree add /tmp/did-helper-pre main
helm dependency update /tmp/did-helper-pre/charts/did-helper 2>/dev/null || true
helm template did-test /tmp/did-helper-pre/charts/did-helper > /tmp/pre.yaml

# Post-migration, from the step branch
helm dependency update charts/did-helper
helm template did-test charts/did-helper > /tmp/post.yaml

diff /tmp/pre.yaml /tmp/post.yaml
```

Also exercise the non-default paths that the migration touches, so any
surprise in the dict-form helpers shows up in the diff:

- `--set ingress.enabled=true` — confirms the chart-local `ingress.yaml`
  still renders correctly against the wrapped helpers.
- `--set fullnameOverride=custom-name` — exercises
  `common.names.fullname` override.
- `--set nameOverride=did` — exercises `common.names.name` override.
- `--set config.provideKeystore.enabled=true
   --set config.provideKeystore.keystoreSecretName=ks
   --set config.provideKeystore.keystoreSecretKey=k` — renders the
  provide-keystore branch of `deployment.yaml`.

The diff must be empty except for the documented cosmetic deltas
(blank-line-in-labels and label-key ordering).

**Acceptance criteria**

- `./lint.sh` and `./eval.sh` both pass cleanly.
- The render-parity diff across the value overrides above is empty apart
  from the documented cosmetic deltas, and the diff (or a summary of it)
  is included in the PR description.

### Step 3: Add `CHANGELOG.md` entry

**Files**

- `charts/did-helper/CHANGELOG.md` (new)

**Content**

Create a new `CHANGELOG.md` for the chart (did-helper does not currently ship
one). Follow the structure established by `charts/mintaka/CHANGELOG.md`:

- A `## 0.1.17` heading matching the bumped chart version.
- A `### Common library chart migration` section listing the concrete
  wiring changes:
  - `Chart.yaml` — added `dependencies: common (file://../common, 0.0.1)`;
    bumped `version` to `0.1.17`; no `apiVersion` bump (already v2).
  - `templates/_helpers.tpl` — `did-helper.name`, `.fullname`, `.chart`,
    `.labels`, `.selectorLabels` delegate to the corresponding `common.*`
    helpers.
  - `templates/service.yaml` replaced by a one-line `common.service.tpl`
    call (single-port block, `targetPort: "http"` preserved).
  - `templates/ingress.yaml`, `templates/deployment.yaml` and
    `templates/configmap.yaml` are intentionally **not** migrated
    (chart-specific schema / env-var plumbing; call out the ingress
    values-schema mismatch explicitly so future readers understand why).
  - `.gitignore` added to keep `Chart.lock` + resolved `charts/*.tgz` out
    of the repo.
- A `### Breaking changes` section. Expected to read **"None for existing
  releases"** — the migration produces byte-identical manifests for every
  resource covered by the helper surface, and the ingress/deployment/
  configmap bodies are unchanged. No new keys are introduced in
  `values.yaml`.
- A `### Non-breaking cosmetic changes to rendered output` section listing
  the expected deltas surfaced by the render-parity diff from Step 2
  (blank leading line inside label blocks on the rewritten `service.yaml`;
  `configmap.yaml`, `deployment.yaml` and `ingress.yaml` keep the legacy
  blank line because they are chart-local).
- An `### Upgrade path` note confirming `helm upgrade` is a no-op: the
  Service selector labels (`name + instance`) are unchanged, and no other
  resource fields whose mutation would force a recreate are touched.

**Acceptance criteria**

- `charts/did-helper/CHANGELOG.md` exists and documents the above.
- The file is committed alongside the Step 2 changes (or as a Step 3 PR
  against the work branch, as dictated by the overall work-branch flow).
- `helm lint charts/did-helper` still passes after the file is added
  (CHANGELOG.md is outside `templates/` so it should have no effect, but
  verify).
