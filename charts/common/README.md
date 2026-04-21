# FIWARE `common` library chart

A [Helm library chart](https://helm.sh/docs/topics/library_charts/) that
centralises the template helpers duplicated across every FIWARE Helm
chart (names, labels, service account, secret, image, and resource
bodies).

Library charts render nothing on their own. Consumer charts depend on
`common` locally and `include` its `common.*` helpers in place of the
boilerplate previously copied into every chart's `_helpers.tpl` and
resource templates.

See [`docs/common-chart-proposal.md`](../../docs/common-chart-proposal.md)
for the full design and the list of explicit (minimal) breaking changes
that the migration will introduce, and
[`docs/common-chart-audit.md`](../../docs/common-chart-audit.md) for the
pre-migration duplication baseline.

## Dependency snippet

Consumer charts depend on `common` via a `file://` path so the library is
shipped together with the repository:

```yaml
# charts/<chart>/Chart.yaml
dependencies:
  - name: common
    repository: "file://../common"
    version: "0.1.x"
```

After editing `Chart.yaml`, run `helm dependency update charts/<chart>`
to refresh `Chart.lock` and pull the library into
`charts/<chart>/charts/`.

## Helper surface

The helpers are added across Steps 3–5 of
[`IMPLEMENTATION_PLAN.md`](../../IMPLEMENTATION_PLAN.md). The table
below mirrors the proposal and is updated as each batch lands.

### Names (`templates/_names.tpl`)

| Helper                   | Replaces                                             | Behaviour                                                                                                                                              |
| ------------------------ | ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `common.names.name`      | `<chart>.name`                                       | `default .Chart.Name .Values.nameOverride \| trunc 63 \| trimSuffix "-"`                                                                               |
| `common.names.fullname`  | `<chart>.fullname`                                   | Honours `.Values.fullnameOverride`; otherwise `.Release.Name` when it already contains the chart name, else `<release>-<name>` truncated to 63 chars. |
| `common.names.chart`     | `<chart>.chart`                                      | `Chart.Name-Chart.Version` with `+` replaced by `_`, truncated to 63 chars.                                                                             |
| `common.names.namespace` | raw `.Release.Namespace` references across templates | `.Release.Namespace`, overridable via `.Values.namespaceOverride`.                                                                                     |

### Labels (`templates/_labels.tpl`)

| Helper                      | Replaces                                                        | Body                                                                                                                                        |
| --------------------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `common.labels.standard`    | `<chart>.labels`                                                | 5-label set: `app.kubernetes.io/name`, `helm.sh/chart`, `app.kubernetes.io/instance`, optional `app.kubernetes.io/version`, `app.kubernetes.io/managed-by`. |
| `common.labels.matchLabels` | `<chart>.selectorLabels` (or inlined `matchLabels:` fragments)  | `app.kubernetes.io/name` + `app.kubernetes.io/instance`.                                                                                     |

Both label helpers accept an optional dict with a `component` key that
adds `app.kubernetes.io/component: <component>` — used by the
multi-component scorpio-broker chart in Step 10.

### Service account (`templates/_serviceaccount.tpl`)

| Helper                       | Replaces                  | Behaviour                                                                                                                                                                                             |
| ---------------------------- | ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `common.serviceAccount.name` | `<chart>.serviceAccountName` | When `.Values.serviceAccount.create` is `true`, returns `.Values.serviceAccount.name` if set, otherwise `common.names.fullname`. When `create` is `false`, returns `.Values.serviceAccount.name` or `default`. |

Accepts either the root context (`.`) or a dict
`(dict "context" $ "component" "<component>")` — the component form adds
a `-<component>` suffix to the default name for multi-component charts
(Step 10).

### Secrets (`templates/_secrets.tpl`)

| Helper               | Replaces                                                                                        | Behaviour                                                                                                                                                                                                                                                              |
| -------------------- | ----------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `common.secrets.name` | `keyrock.secretName`, `keyrock.certSecretName`, `orion.secretName`, other per-chart equivalents | Returns the `tpl`-expanded user-supplied secret name when `existingSecret` is set (accepts a bare string *or* a map with `.name`); otherwise falls back to `<fullname><suffix>`. Takes an optional `suffix` (e.g. `-certs`) and an optional `component`. |
| `common.secrets.key`  | `orion.secretKey` and similar                                                                   | Returns the `tpl`-expanded `.key` field of a map-shaped `existingSecret` when set, otherwise the caller-supplied `defaultKey`.                                                                                                                                         |

Both helpers always take a dict, because there is no single
`.Values.existingSecret` in every chart — the caller has to pass the
specific values path it wants.

### Images (`templates/_images.tpl`)

| Helper                     | Replaces                                                     | Behaviour                                                                                                                                              |
| -------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `common.images.image`       | inlined `"{{ .repository }}:{{ .tag \| default .Chart.AppVersion }}"` | Returns `<repository>:<tag>` with `.Chart.AppVersion` fallback when `tag` is empty.                                                                    |
| `common.images.pullPolicy`  | inlined `{{ default "IfNotPresent" .pullPolicy }}`           | Returns the pull policy with the Kubernetes default `IfNotPresent` fallback.                                                                           |
| `common.images.pullSecrets` | per-chart `imagePullSecrets` fragments                        | Renders the `imagePullSecrets:` block when a non-empty list is provided. Accepts both bare strings and `{name: ...}` maps; normalises to canonical form; renders nothing when empty. |

### Planned in later steps

| Area               | File              | Step | Status         |
| ------------------ | ----------------- | ---- | -------------- |
| Names              | `_names.tpl`      | 3    | done           |
| Labels             | `_labels.tpl`     | 3    | done           |
| Service account    | `_serviceaccount.tpl` | 4 | **this step**  |
| Secrets (helpers)  | `_secrets.tpl`    | 4    | **this step**  |
| Images             | `_images.tpl`     | 4    | **this step**  |
| Service body       | `_service.tpl`    | 5    | pending        |
| Ingress body       | `_ingress.tpl`    | 5    | pending        |
| Route body         | `_route.tpl`      | 5    | pending        |
| HPA body           | `_hpa.tpl`        | 5    | pending        |
| Secret body        | `_secret.tpl`     | 5    | pending        |

## Testing

The `charts/common/tests/` directory holds a fixture consumer chart used
to verify that the rendered output of each helper matches the current
orion / keyrock bodies byte-for-byte. `scripts/test-common.sh` (added in
Step 6) drives the comparison.

For a one-off sanity check:

```console
helm lint charts/common
helm dependency update charts/common/tests
helm template charts/common/tests
```

## Versioning

`common` follows semver. Helper additions are minor bumps, behavioural
changes to an existing helper are major bumps. Consumer charts pin with
a caret (`0.1.x`) so additive changes flow in automatically while a
major change forces a deliberate migration.

## Publishing

`common` is **not** published to the public `fiware` Helm repository. It
is consumed only via `file://../common` from other charts in this
monorepo. Releases of dependent charts embed a tarball of the library in
their `charts/` directory, so end users install exactly one chart.
