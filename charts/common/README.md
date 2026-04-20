# FIWARE `common` library chart

A [Helm library chart](https://helm.sh/docs/topics/library_charts/) that
centralises the template helpers duplicated across every FIWARE Helm
chart (names, labels, service account, secret, image, and resource
bodies). It is modelled after
[`bitnami/common`](https://github.com/bitnami/charts/tree/main/bitnami/common).

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

### Planned in later steps

| Area               | File              | Step | Status  |
| ------------------ | ----------------- | ---- | ------- |
| Names              | `_names.tpl`      | 3    | **this step** |
| Labels             | `_labels.tpl`     | 3    | **this step** |
| Service account    | `_serviceaccount.tpl` | 4    | pending |
| Secrets (helpers)  | `_secrets.tpl`    | 4    | pending |
| Images             | `_images.tpl`     | 4    | pending |
| Service body       | `_service.tpl`    | 5    | pending |
| Ingress body       | `_ingress.tpl`    | 5    | pending |
| Route body         | `_route.tpl`      | 5    | pending |
| HPA body           | `_hpa.tpl`        | 5    | pending |
| Secret body        | `_secret.tpl`     | 5    | pending |

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
