# Implementation Plan: Update chart odrl-pap to use common chart

## Overview
Migrate `charts/odrl-pap` so every helper and resource template previously
duplicated in the chart delegates to the shared `common` library chart
(`charts/common`), following the playbook already applied to `orion`,
`keyrock`, and `mintaka` (see `docs/common-chart.md` §"Consumer-chart
migration pattern"). Only the five structurally-uniform templates
(`service.yaml`, `ingress.yaml`, `serviceaccount.yaml`, `secret.yaml`,
`deployment-hpa.yaml`) plus the six `pap.*` helpers move to `common.*`.
Chart-specific bodies — `deployment.yaml`, `route.yaml` (which carries a
`-pap` suffix, a hard-coded `path: /issuer`, and a
`cert-upaps-operator.redhat-cop.io/certs-from-secret` annotation bound
to `route.certificate`), `route-certificate.yaml`, `mapping-cm.yaml`,
and `rego-cm.yaml` — stay chart-local. The migration must be as
non-breaking as possible: `helm diff main..branch` must be empty except
for the four documented deltas (explicit `metadata.namespace`,
`autoscaling.apiVersion` key default, ServiceAccount resource name
honouring `.Values.serviceAccount.name`, cosmetic whitespace / secret-
key ordering).

## Steps

### Step 1: Add the `common` dependency and bump `charts/odrl-pap/Chart.yaml`

**Goal.** Wire up the library dependency so subsequent steps can
`include "common.*"` — this is a pre-requisite for any other change.

**Files touched.**
- `charts/odrl-pap/Chart.yaml`
- `charts/odrl-pap/.gitignore` (new)

**Changes.**
1. In `Chart.yaml`:
   - Bump `apiVersion: v1` → `apiVersion: v2` (required because library
     dependencies are only supported on v2).
   - Bump `version: 2.9.1` → `version: 2.10.0` (minor bump — no value-
     schema breakage, only the documented cosmetic deltas).
   - Add `kubeVersion: '>= 1.19-0'` to match `orion`, `keyrock`,
     `mintaka` and reflect the `networking.k8s.io/v1` Ingress emitted by
     `common.ingress.tpl`.
   - Append a `dependencies:` block declaring the `common` library,
     using the same repository URL pattern as the three previously-
     migrated charts:
     ```yaml
     dependencies:
       - name: common
         repository: "https://fiware.github.io/helm-charts"
         version: "0.0.1"
     ```
   - Add the same block-comment header used by mintaka/orion/keyrock
     explaining the rationale for the dependency.
2. Create `charts/odrl-pap/.gitignore` excluding the resolved `Chart.lock`
   and the `charts/` sub-directory (the `common-<version>.tgz` pulled
   in by `helm dependency update` does not belong in git — matches the
   mintaka convention).

**Acceptance criteria.**
- `helm dependency update charts/odrl-pap` resolves successfully and
  produces a `Chart.lock` plus `charts/common-0.0.1.tgz` under
  `charts/odrl-pap/`.
- `./build.sh` still exits 0 on the full repo.
- `helm lint charts/odrl-pap` still exits 0 with the un-modified
  templates (the old `pap.*` helpers are still in place at this point).
- No rendered-manifest change yet — this step only adds metadata.

### Step 2: Rewrite `charts/odrl-pap/templates/_helpers.tpl` as thin wrappers over `common.*`

**Goal.** Replace every body in `_helpers.tpl` with a single-line
`include` of the corresponding `common.*` helper, preserving the
`pap.*` include paths so any downstream umbrella chart that references
`include "pap.fullname" .` (or similar) keeps working.

**Files touched.**
- `charts/odrl-pap/templates/_helpers.tpl`

**Changes.** Rewrite the file so each helper becomes a wrapper:

| Existing `pap.*` helper       | Replacement body                                                                                                                                     |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `pap.name`                    | `{{- include "common.names.name" . -}}`                                                                                                              |
| `pap.fullname`                | `{{- include "common.names.fullname" . -}}`                                                                                                          |
| `pap.chart`                   | `{{- include "common.names.chart" . -}}`                                                                                                             |
| `pap.serviceAccountName`      | `{{- include "common.serviceAccount.name" . -}}`                                                                                                     |
| `pap.labels`                  | `{{- include "common.labels.standard" . -}}`                                                                                                         |
| `pap.secretName`              | `{{- include "common.secrets.name" (dict "context" $ "existingSecret" .Values.database.existingSecret) -}}`                                         |
| `pap.passwordKey`             | `{{- include "common.secrets.key" (dict "context" $ "existingSecret" .Values.database.existingSecret "defaultKey" "password") -}}`                  |

Keep the mustache comment header and per-helper doc-comments, using the
same wording pattern as `charts/mintaka/templates/_helpers.tpl`.

**Notes.**
- odrl-pap uses `.Values.database.existingSecret.enabled` (the DB-
  flavoured form). `common.secrets.name` supports this shape natively:
  when `existingSecret` is a map without a `.name` entry — which is the
  case when `enabled: false` — it falls back to `<fullname>`; when
  `enabled: true`, the `.name` entry is `tpl`-expanded and returned.
  This preserves the byte-for-byte output of the legacy
  `pap.secretName` body.
- `common.secrets.key` already defaults-back to the supplied
  `defaultKey` ("password") when the `existingSecret` map has no `.key`
  entry — same semantics as the legacy `pap.passwordKey`.
- `pap.serviceAccountName` emits leading whitespace in the legacy body
  (indent 4 inside `{{ default … }}`). `common.serviceAccount.name`
  trims surrounding whitespace — the only consumer is
  `deployment.yaml` where the include is placed inline, so the result
  is whitespace-equivalent.

**Acceptance criteria.**
- `helm lint charts/odrl-pap` passes.
- `helm template charts/odrl-pap` renders the same manifests as it did
  in step 1 (no visible behavioural change yet because templates still
  reference `pap.*`, which now delegate).
- `diff <(helm template charts/odrl-pap <@main>) <(helm template charts/odrl-pap <@branch>)`
  is empty (except for whitespace inside the serviceAccountName
  include, which is swallowed by the YAML parser in every consuming
  position).

### Step 3: Replace standard resource templates with `common.*.tpl` includes, and add the `autoscaling.apiVersion` default

**Goal.** Collapse the five structurally-uniform template files to one-
line `include` calls. Keep every chart-specific template unchanged.

**Files touched.**
- `charts/odrl-pap/templates/service.yaml`
- `charts/odrl-pap/templates/ingress.yaml`
- `charts/odrl-pap/templates/serviceaccount.yaml`
- `charts/odrl-pap/templates/secret.yaml`
- `charts/odrl-pap/templates/deployment-hpa.yaml`
- `charts/odrl-pap/values.yaml`

**Files explicitly left chart-local.**
- `charts/odrl-pap/templates/deployment.yaml` — bespoke container spec
  (env, probes, volume mounts, PATHS_MAPPING / PATHS_REGO flags,
  datasource secret references).
- `charts/odrl-pap/templates/route.yaml` — three chart-specific
  deviations from `common.route.tpl` make it un-migratable without
  breaking render parity:
  1. `metadata.name` is `{{ include "pap.fullname" . }}-pap` (common
     emits plain `<fullname>`).
  2. `spec.path: /issuer` is hard-coded (common has no `path` field).
  3. A `cert-upaps-operator.redhat-cop.io/certs-from-secret:
     <fullname>-tls-sec` annotation is rendered when
     `.Values.route.certificate` is set (common has no certificate
     integration).
- `charts/odrl-pap/templates/route-certificate.yaml` — bespoke cert-
  manager `Certificate` (kept per-chart, as with
  apollo / canis-major / tm-forum-api /
  credentials-config-service / trusted-issuers-registry per
  `docs/common-chart.md` appendix).
- `charts/odrl-pap/templates/mapping-cm.yaml` — chart-specific
  mapping ConfigMap.
- `charts/odrl-pap/templates/rego-cm.yaml` — chart-specific Rego
  ConfigMap.

**Changes.**

1. `service.yaml` →
   ```yaml
   {{- include "common.service.tpl" (dict
         "context" $
         "service" .Values.service
         "ports"   (list (dict
                           "port"       .Values.service.port
                           "targetPort" .Values.deployment.port))) }}
   ```

2. `ingress.yaml` →
   ```yaml
   {{- include "common.ingress.tpl" (dict
         "context"     $
         "ingress"     .Values.ingress
         "servicePort" .Values.service.port) }}
   ```

3. `serviceaccount.yaml` →
   ```yaml
   {{- include "common.serviceAccount.tpl" (dict "context" $) }}
   ```

4. `secret.yaml` →
   ```yaml
   {{- include "common.secret.tpl" (dict
         "context"        $
         "existingSecret" .Values.database.existingSecret
         "data"           (dict "password" .Values.database.password)) }}
   ```

5. `deployment-hpa.yaml` →
   ```yaml
   {{- include "common.hpa.tpl" (dict
         "context"     $
         "autoscaling" .Values.autoscaling) }}
   ```

6. `values.yaml` — add a new `apiVersion: "v2beta2"` key under
   `.Values.autoscaling` so the HPA continues to render
   `apiVersion: autoscaling/v2beta2` by default (the legacy body
   hard-coded it). Matches the mintaka migration's Breaking-change #1.
   Place it immediately after `enabled: false`, with a comment:
   ```yaml
   # -- HPA apiVersion (e.g. v2beta2 for k8s <1.26, v2 for 1.26+)
   apiVersion: "v2beta2"
   ```

**Acceptance criteria.**
- `helm lint charts/odrl-pap` passes.
- `helm template charts/odrl-pap` still renders Service, Ingress
  (when enabled), ServiceAccount (when create: true), Secret (when not
  using an existingSecret), and HPA (when enabled).
- `./lint.sh` and `./eval.sh` still exit 0 on the full repo.

### Step 4: Render-parity verification and `CHANGELOG.md`

**Goal.** Prove the migration is non-breaking (modulo the four
documented deltas) and leave a human-readable migration note in the
chart.

**Files touched.**
- `charts/odrl-pap/CHANGELOG.md` (new)

**Verification.**
1. `diff <(git show main:charts/odrl-pap/... | helm template .) <(helm template charts/odrl-pap)`
   rendered from this branch. Run the diff at least with:
   - default values (`helm template charts/odrl-pap`),
   - `--set ingress.enabled=true --set ingress.hosts[0].host=pap.example.org --set 'ingress.hosts[0].paths={/}'`,
   - `--set route.enabled=true --set route.host=pap.example.org`,
   - `--set autoscaling.enabled=true`,
   - `--set database.existingSecret.enabled=true --set database.existingSecret.name=my-db-secret --set database.existingSecret.key=db-password`,
   - `--set serviceAccount.create=true --set serviceAccount.name=custom-sa`.
2. Every diff hunk must fall into one of:
   - explicit `metadata.namespace: "default"` now present (was implicit),
   - cosmetic whitespace inside the labels block (leading blank line
     gone in helper-emitted manifests, still present in the chart-local
     `deployment.yaml` / `route.yaml` / `route-certificate.yaml` /
     `mapping-cm.yaml` / `rego-cm.yaml`),
   - Secret `data` entries emitted as single-line `key: <base64>`
     scalars rather than block scalars (both decode to identical
     bytes),
   - HPA `metrics:` list items indented by 4 spaces rather than 2
     (YAML-equivalent),
   - ServiceAccount resource `metadata.name` now honours
     `.Values.serviceAccount.name` when supplied (previously hard-coded
     to `<fullname>`; see mintaka CHANGELOG Breaking-change #2).

**`charts/odrl-pap/CHANGELOG.md` contents.** Follow the structure used
by `charts/mintaka/CHANGELOG.md`:

- Heading: `# odrl-pap changelog`.
- `## 2.10.0` section covering:
  - _Common library chart migration_ — list every helper and template
    that now delegates (`_helpers.tpl`, `service.yaml`, `ingress.yaml`,
    `serviceaccount.yaml`, `secret.yaml`, `deployment-hpa.yaml`).
  - _Templates intentionally not migrated_ — `deployment.yaml`,
    `route.yaml` (with the three-reason explanation from Step 3),
    `route-certificate.yaml`, `mapping-cm.yaml`, `rego-cm.yaml`.
  - _Chart.yaml bumps_ — `apiVersion` v1→v2, `version` 2.9.1→2.10.0,
    new `kubeVersion`, `common` dependency entry.
  - _Breaking changes_ — (1) new `autoscaling.apiVersion: "v2beta2"`
    value key; (2) ServiceAccount resource name now honours
    `.Values.serviceAccount.name`.
  - _Non-breaking cosmetic changes_ — leading-blank-line removal,
    single-line base64 scalars, HPA metrics indent.
  - _Upgrade path_ — `helm upgrade` is a no-op for the Service /
    Deployment selector pair; a standard field update elsewhere; no
    data migration required.

**Acceptance criteria.**
- `./build.sh`, `./lint.sh`, and `./eval.sh` all exit 0.
- `helm template charts/odrl-pap` diff against the `main` branch
  matches only the documented deltas.
- `CHANGELOG.md` exists and cross-references `docs/common-chart.md` and
  the preceding `orion` / `keyrock` / `mintaka` CHANGELOGs.
