# `common` Library Chart — Proposal

This is the design sibling of `common-chart-audit.md` (Step 1 of
`IMPLEMENTATION_PLAN.md`). It summarises:

1. the proposed helper surface of the new `charts/common` library chart,
2. the mechanical plan for migrating consumer charts to it, and
3. the **explicit, unavoidable breaking changes** that the migration will
   introduce.

The guiding principle is "render-diff must be empty". Each consumer-chart
migration ships with a `helm template` before/after comparison; any
observable change that is not explicitly listed below must be treated as
a regression.

---

## Chart layout

```
charts/common/
├── Chart.yaml            # apiVersion v2, type: library, name: common, version: 0.1.0
├── values.yaml           # empty (library chart)
├── README.md             # helper catalog + usage snippets
├── DEPRECATIONS.md       # added in Step 11
└── templates/
    ├── _names.tpl
    ├── _labels.tpl
    ├── _serviceaccount.tpl
    ├── _secrets.tpl
    ├── _images.tpl
    ├── _service.tpl
    ├── _ingress.tpl
    ├── _route.tpl
    ├── _hpa.tpl
    └── _secret.tpl
```

`charts/common/tests/` carries a fixture consumer chart used by
`scripts/test-common.sh` to prove that each helper's rendered output
matches the current orion / keyrock bodies byte-for-byte.

## Helper surface

### Names (`_names.tpl`)

| Helper                   | Replaces                                             | Behaviour                                                                                                             |
| ------------------------ | ---------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| `common.names.name`      | `<chart>.name`                                       | `default .Chart.Name .Values.nameOverride \| trunc 63 \| trimSuffix "-"`                                              |
| `common.names.fullname`  | `<chart>.fullname`                                   | Honours `fullnameOverride`; else `Release.Name` if it already contains the chart name, else `Release.Name-<name>`. In Step 10 accepts an optional `component` argument. |
| `common.names.chart`     | `<chart>.chart`                                      | `Chart.Name-Chart.Version` (Helm + / replace + trunc 63).                                                              |
| `common.names.namespace` | raw `.Release.Namespace` references across templates | Honours an optional `.Values.namespaceOverride`.                                                                      |

### Labels (`_labels.tpl`)

| Helper                      | Replaces                                    | Body                                                                            |
| --------------------------- | ------------------------------------------- | ------------------------------------------------------------------------------- |
| `common.labels.standard`    | `<chart>.labels`                            | 5-label set (`app.kubernetes.io/name|instance|version|managed-by`, `helm.sh/chart`) — identical to orion. |
| `common.labels.matchLabels` | `<chart>.selectorLabels` / existing `matchLabels` fragments | `app.kubernetes.io/name` + `app.kubernetes.io/instance`.                       |

Both accept an optional `component` argument that adds
`app.kubernetes.io/component: <component>` — needed in Step 10 for
`scorpio-broker` / `business-api-ecosystem`. When the argument is
omitted, the rendered YAML is byte-identical to today's output.

### Service account (`_serviceaccount.tpl`)

| Helper                          | Replaces                     | Behaviour                                                                                   |
| ------------------------------- | ---------------------------- | ------------------------------------------------------------------------------------------- |
| `common.serviceAccount.name`    | `<chart>.serviceAccountName` | `create ? name ?? fullname : name ?? "default"` (identical to orion).                       |
| `common.serviceAccount.tpl`     | `templates/serviceaccount.yaml` | Renders the whole `ServiceAccount` YAML body gated on `.Values.serviceAccount.create`.   |

### Secrets (`_secrets.tpl`, `_secret.tpl`)

| Helper                  | Replaces                                             | Behaviour                                                                                                                                  |
| ----------------------- | ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `common.secrets.name`   | `orion.secretName`, `keyrock.secretName`, `keyrock.certSecretName`, all DB-style `<chart>.secretName` helpers | Accepts `(dict "context" $ "existingSecret" <val> "suffix" "-certs")`. Returns the tpl-expanded existing name or `<fullname>[+suffix]`.     |
| `common.secrets.key`    | `orion.secretKey`, `<chart>.passwordKey`             | Returns the configured key or a supplied default (`dbPassword`).                                                                            |
| `common.secret.tpl`     | per-chart `secret.yaml`                              | Renders the Opaque Secret body only when no existing secret is supplied.                                                                    |

### Images (`_images.tpl`)

| Helper                        | Replaces                                             | Behaviour                                                                                |
| ----------------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `common.images.image`         | inline `image:` expressions                          | `repository:tag`, tag falling back to `.Chart.AppVersion`.                                |
| `common.images.pullPolicy`    | inline pull-policy defaults                          | Defaults to `IfNotPresent`.                                                              |
| `common.images.pullSecrets`   | inline `imagePullSecrets:`                           | Renders the pull-secrets block if supplied.                                              |

### Resource bodies (`_service.tpl`, `_ingress.tpl`, `_route.tpl`, `_hpa.tpl`)

Each produces a full resource body from a `(dict "context" $ "values" …)`
argument, matching today's templates byte-for-byte. Consumer charts
replace their `service.yaml` / `ingress.yaml` / `route.yaml` /
`deployment-hpa.yaml` with a one-line `include` call. The `ingress`
helper always emits `networking.k8s.io/v1` (see Breaking Changes).

---

## Consumer-chart migration pattern

The migration of each chart (Steps 7–10) is mechanical:

1. Add `common` as a local `file://../common` dependency in `Chart.yaml`
   (bumping the chart's minor version).
2. Rewrite `templates/_helpers.tpl` so every existing `<chart>.*` helper
   becomes a thin wrapper over the corresponding `common.*` helper. This
   preserves compatibility for any external chart that references
   `include "<chart>.<helper>"`.
3. Replace per-chart `service.yaml` / `ingress.yaml` / `route.yaml` /
   `serviceaccount.yaml` / `secret.yaml` / `deployment-hpa.yaml` with a
   single `include "common.*.tpl"` line.
4. Leave chart-specific templates alone (Mongo deployments, Envoy sidecar,
   webhook injection, policy ConfigMaps, certificate CRs, init-data Jobs,
   per-component deployments not covered by the helpers).
5. Verify `diff <(helm template …@main) <(helm template …@branch)` is empty
   except for the breaking changes listed below.

Per-chart migration PRs add a `CHANGELOG.md` entry calling out the
dependency on `common` and the chart-version bump.

---

## Breaking changes (explicit)

The refactor aims for **zero** observable changes. The mechanical helper
substitution preserves the rendered YAML byte-for-byte in all but the
following cases:

1. **`keyrock` ingress `apiVersion`** — the `semverCompare ">=1.14-0"`
   branch in `charts/keyrock/templates/ingress.yaml` is removed. After
   migration the chart always emits `networking.k8s.io/v1`. This changes
   rendered output only on Kubernetes < 1.14, which is already below the
   version the repo assumes elsewhere (`orion` / `tm-forum-api` declare
   `kubeVersion: '>= 1.19-0'`, and `networking.k8s.io/v1` is GA since
   1.19). To be called out in `charts/keyrock/CHANGELOG.md` under Step 8.

2. **Legacy per-chart helpers become thin wrappers** — users who
   `include "orion.fullname"`, `include "keyrock.certSecretName"` etc.
   from their own umbrella charts continue to work throughout Steps 7–10
   (the wrappers remain). A future major release per chart will remove
   the wrappers; Step 11 adds `charts/common/DEPRECATIONS.md` to track
   this and announce the deprecation window. **No wrapper is removed in
   the initial rollout.**

No other observable change is expected. Each migration PR enforces this
with a committed `helm template` diff in its description. If a diff
uncovers an unlisted behavioural change, the chart is *not* migrated in
that PR and the plan is amended to either add the change to this list
(with justification) or to find a helper variant that preserves the
existing output.

---

## Non-goals of this proposal

- Rewriting Deployment / StatefulSet bodies into a shared template. The
  variation across charts (env vars, volume mounts, probes, init
  containers, sidecars) is too high to share at the YAML level — the
  shared helpers stop at `Service`, `Ingress`, `Route`, `HPA`,
  `ServiceAccount`, and (optional) `Secret`.
- Normalising value keys. Charts that spell `image.tag`, `image.pullPolicy`,
  `ingress.hosts[]` differently keep their own schema; the helpers read
  exactly what the chart currently reads.
- Changing chart prefixes (e.g. `tmforum.*`, `ccs.*`, `til.*`, `pap.*`,
  etc.). These remain as wrappers to preserve include paths. They will
  be considered for removal in the per-chart major bump tracked by the
  Step 11 deprecations doc.
- Renaming or consolidating Helm chart names. The 26 published chart
  names are not touched.
