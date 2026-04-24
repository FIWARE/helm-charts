# Implementation Plan: Update chart vcverifier to use common chart

## Overview

Migrate `charts/vcverifier` to depend on the in-repo `charts/common` library
chart, following the established consumer-chart migration pattern documented in
`docs/common-chart.md` and already applied to `orion`, `keyrock`, `mintaka`
(and `fdsc-dashboard`). The vcverifier chart ships only the canonical
`orion`-style helper set (`vcverifier.name|fullname|chart|serviceAccountName|labels`)
so the work is mechanical: wrap each helper over its `common.*` equivalent,
replace the two structurally uniform resource templates (`service.yaml`,
`ingress.yaml`) with one-line `include` calls, leave chart-specific templates
(deployment, certificate, configmap(s), route) alone, and document the
migration. The route template is **intentionally kept chart-local** because it
carries chart-specific `cert-utils-operator` annotation handling and an
explicit `spec.port.targetPort` that `common.route.tpl` does not emit —
keeping it local satisfies the ticket's "update as minimal breaking as
possible" requirement.

## Steps

### Step 1: Declare the `common` library-chart dependency in `charts/vcverifier/Chart.yaml`

Goal: make the `common` library visible to vcverifier without touching any
template rendering yet. After this step the chart still renders byte-identical
output — only metadata changed.

Changes:

- Bump `apiVersion: v1` → `apiVersion: v2` (library dependencies require v2).
- Bump `version: 4.9.0` → `version: 4.10.0` (minor bump, consistent with the
  mintaka `0.4.2 → 0.4.3 → 0.6.0` and orion `1.6.6 → 1.6.8` migration bumps).
  Keep `appVersion` unchanged.
- Add `kubeVersion: '>= 1.19-0'` (matches orion / keyrock / mintaka /
  tm-forum-api and makes the minimum-version assumption explicit — the
  `common` helpers already assume >= 1.19 for `networking.k8s.io/v1`).
- Append the `common` dependency entry (copy the comment block + `dependencies:`
  stanza verbatim from `charts/mintaka/Chart.yaml`, just replacing the chart
  name in the comment):

  ```yaml
  dependencies:
    - name: common
      repository: "https://fiware.github.io/helm-charts"
      version: "0.0.1"
  ```

- Add a top-level `.gitignore` scoped to this chart
  (`charts/vcverifier/.gitignore`) excluding:

  ```
  Chart.lock
  charts/
  ```

  These are produced by `helm dependency update` and should not be checked in
  (same pattern as `charts/mintaka/.gitignore` from that chart's migration PR).

Acceptance:

- `./build.sh` succeeds and creates `charts/vcverifier/Chart.lock` +
  `charts/vcverifier/charts/common-*.tgz` (both gitignored).
- `helm lint charts/vcverifier` passes.
- `helm template charts/vcverifier` produces the same output as on `main`
  (no templates reference `common.*` yet, so the dependency is a no-op).

Files changed: `charts/vcverifier/Chart.yaml`, `charts/vcverifier/.gitignore`.

### Step 2: Rewrite `charts/vcverifier/templates/_helpers.tpl` as thin wrappers over `common.*`

Goal: fold each `vcverifier.*` helper into a single-line delegation to the
matching `common.*` helper, preserving the public include path
(`include "vcverifier.<helper>"`) so any external umbrella chart that
references these helpers keeps working. This is the same pattern applied to
`mintaka/templates/_helpers.tpl`.

Rewrites (body-only — keep the `{{/* ... */}}` comment preamble, update it to
describe delegation):

| Helper                         | Body after rewrite                                       |
| ------------------------------ | -------------------------------------------------------- |
| `vcverifier.name`              | `{{ include "common.names.name" . }}`                    |
| `vcverifier.fullname`          | `{{ include "common.names.fullname" . }}`                |
| `vcverifier.chart`             | `{{ include "common.names.chart" . }}`                   |
| `vcverifier.serviceAccountName`| `{{ include "common.serviceAccount.name" . }}`           |
| `vcverifier.labels`            | `{{ include "common.labels.standard" . }}`               |

Acceptance:

- `./lint.sh` passes.
- `diff <(git show main:charts/vcverifier/templates/... | helm template -)
        <(helm template charts/vcverifier)` on every remaining template body
  (deployment, certificate, configmap, configmap-templates, service, ingress,
  route) yields an empty diff. The wrappers produce byte-identical
  `name` / `fullname` / `chart` / `serviceAccountName` / `labels` output as
  the legacy bodies, by construction (see `charts/common/templates/_names.tpl`
  and `_labels.tpl`).

Files changed: `charts/vcverifier/templates/_helpers.tpl`.

### Step 3: Replace `charts/vcverifier/templates/service.yaml` with a `common.service.tpl` include

Goal: delete the inlined Service body and render it via the shared helper.

New body (single `include` expression, matching the mintaka pattern but
passing `targetPort: "backend"` — the vcverifier Service targets the named
container port `backend` in the Deployment, not the service port number):

```yaml
{{- include "common.service.tpl" (dict
      "context" $
      "service" .Values.service
      "ports"   (list (dict
                        "port"       .Values.service.port
                        "targetPort" "backend"
                        "name"       "http"))) }}
```

Acceptance:

- `helm template charts/vcverifier` renders a Service with the same `name`,
  `namespace`, `labels`, `type`, port (3000), `targetPort: backend`, protocol
  `TCP`, port name `http`, and `app.kubernetes.io/name` +
  `app.kubernetes.io/instance` selector as the legacy template.
- `diff <(helm template @main charts/vcverifier | yq 'select(.kind=="Service")')
        <(helm template @branch charts/vcverifier | yq 'select(.kind=="Service")')`
  differs only in:
  - the order of the keys inside the `ports[0]` map (`port|targetPort|protocol|name`
    rather than the legacy `name|port|targetPort|protocol`) — YAML-equivalent;
  - the blank leading line inside the `labels:` block (a cosmetic artefact of
    the legacy `include ... | nindent 4` pattern), already called out in the
    `common`-chart breaking-changes notes;
  - the `selector:` now emits `app.kubernetes.io/name` +
    `app.kubernetes.io/instance` via `common.labels.matchLabels` — the set of
    keys is unchanged, only the helper producing them changed. No new key is
    added when no `component` argument is passed.
- `./eval.sh` passes (the rendered manifest still validates against the
  kubeconform Service schema).

Files changed: `charts/vcverifier/templates/service.yaml`.

### Step 4: Replace `charts/vcverifier/templates/ingress.yaml` with a `common.ingress.tpl` include

Goal: delete the inlined Ingress body and render it via the shared helper.

New body:

```yaml
{{- include "common.ingress.tpl" (dict
      "context"     $
      "ingress"     .Values.ingress
      "servicePort" .Values.service.port) }}
```

The legacy template and `common.ingress.tpl` both:

- gate rendering on `.Values.ingress.enabled`;
- emit `networking.k8s.io/v1`;
- honour the same sub-keys (`className`, `annotations`, `tls[]`, `hosts[]` with
  nested `paths[]`);
- use `{{ include "<chart>.fullname" . }}` as both the metadata name and the
  backend service name.

So rendered output is byte-identical except for the same cosmetic
labels-blank-line delta already documented.

Acceptance:

- With `ingress.enabled: false` (the default), the template renders nothing
  (same as before).
- With `ingress.enabled: true` and a host list, the rendered Ingress matches
  the legacy body modulo the cosmetic delta.
- `./lint.sh` and `./eval.sh` pass.

Files changed: `charts/vcverifier/templates/ingress.yaml`.

### Step 5: Leave chart-specific templates untouched, document the decision

Goal: capture *why* the remaining five templates stay chart-local. No file
changes other than comment additions where useful. The step exists so the
CHANGELOG and this plan can reference a single explicit list of "not
migrated" files.

Templates kept chart-local and the reason for each:

| Template                                       | Reason not migrated                                                                                                                                                                                                                                                                     |
| ---------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `templates/deployment.yaml`                    | Chart-specific container / env / probe / volume body (CA-bundle init container, signing-cert / client-cert volumes, templates ConfigMap mount, static volume). Matches the "Deployment stays chart-local" non-goal in `docs/common-chart.md`.                                           |
| `templates/route.yaml`                         | Chart-specific features not supported by `common.route.tpl`: (a) the `cert-utils-operator.redhat-cop.io/certs-from-secret` annotation rendered when `.Values.route.certificate` is set; (b) the explicit `spec.port.targetPort: {{ .Values.service.port }}`. Migrating would change the rendered manifest, violating the ticket's "minimal breaking" requirement. |
| `templates/certificate.yaml`                   | `cert-manager.io/v1` Certificate CR — not part of the `common` helper surface (same category as `charts/keyrock/templates/certificate.yaml` and `charts/ishare-satellite/templates/certificate.yaml`, both of which stayed chart-local).                                                |
| `templates/configmap.yaml`                     | Chart-specific server configuration ConfigMap (`server.yaml` payload) — not part of the `common` helper surface.                                                                                                                                                                        |
| `templates/configmap-templates.yaml`           | Chart-specific `<fullname>-template` ConfigMap gating on `.Values.templates` — not part of the `common` helper surface.                                                                                                                                                                 |

Vcverifier has no `serviceaccount.yaml` (`.Values.serviceAccount.create`
defaults to `false` and the chart never shipped one — confirmed in the
appendix of `docs/common-chart.md`), no `secret.yaml`, and no HPA, so there
are no additional `common.*` includes to wire up.

Acceptance: no file-content changes in this step beyond a short header
comment inside each of the five files pointing readers to the CHANGELOG.

Files changed: none strictly required; optional comment headers on the five
chart-local templates above.

### Step 6: Add `charts/vcverifier/CHANGELOG.md` and verify render parity

Goal: document the migration in the same style as
`charts/mintaka/CHANGELOG.md`, and pin the render-diff evidence.

Create `charts/vcverifier/CHANGELOG.md` with a `## 4.10.0` section that covers:

- The new `common` dependency (link to `charts/common/README.md` and
  `docs/common-chart.md`).
- The Chart.yaml changes (apiVersion, version bump, kubeVersion).
- The helper-file rewrite (wrappers over `common.*`).
- The two migrated resource templates (`service.yaml`, `ingress.yaml`) and
  the five that stayed chart-local (matching the table in Step 5).
- The cosmetic render-diff deltas inherited from the `common` helpers
  (labels blank-line, field-order of Service `ports[0]` keys) — mirror the
  "Non-breaking cosmetic changes to rendered output" section of
  `charts/mintaka/CHANGELOG.md`.
- A short "Upgrade path" paragraph noting that `helm upgrade` of an existing
  release is a no-op for selector labels and a standard field update for the
  Service / Ingress bodies.

Render-parity verification to paste into the PR description:

```bash
# Before
git checkout main -- charts/vcverifier
helm dependency update charts/vcverifier || true
helm template --namespace ns --release-name rel charts/vcverifier > /tmp/before.yaml

# After
git checkout ticket-24/work -- charts/vcverifier
helm dependency update charts/vcverifier
helm template --namespace ns --release-name rel charts/vcverifier > /tmp/after.yaml

diff -u /tmp/before.yaml /tmp/after.yaml
```

Repeat with `--set ingress.enabled=true --set ingress.hosts[0].host=h --set ingress.hosts[0].paths[0]=/`
and with `--set route.enabled=true` (`route.yaml` is unchanged so its diff must
be empty even with `route.certificate` set). The only non-empty output must
be the documented cosmetic deltas.

Acceptance:

- `./build.sh`, `./lint.sh`, `./eval.sh` all exit 0.
- `helm template charts/vcverifier` diff against `main` is empty except for
  the listed cosmetic deltas.
- `charts/vcverifier/CHANGELOG.md` exists, version header matches
  `Chart.yaml#version`.

Files changed: `charts/vcverifier/CHANGELOG.md` (new).
