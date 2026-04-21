# keyrock changelog

## 0.10.0

### Common library chart migration

The chart now depends on the local `common` library chart
(`charts/common`, introduced in ticket-9 steps 1–6). Every helper and
every resource template previously duplicated in this chart is now a
thin `include` of the matching `common.*` helper:

- `templates/_helpers.tpl` — `keyrock.name`, `keyrock.fullname`,
  `keyrock.chart`, `keyrock.serviceAccountName`, `keyrock.labels`,
  `keyrock.secretName`, `keyrock.certSecretName` now delegate to
  `common.names.*`, `common.serviceAccount.name`,
  `common.labels.standard`, `common.secrets.name`. The `<chart>.*`
  names are preserved so any external umbrella chart that imports them
  keeps working.
- `templates/service.yaml` → `common.service.tpl`
- `templates/ingress.yaml` → `common.ingress.tpl`
- `templates/statefulset-hpa.yaml` → `common.hpa.tpl`
- `templates/serviceaccount.yaml` → `common.serviceAccount.tpl`
- `templates/secret.yaml` → two calls to `common.secret.tpl` (the
  bespoke `randAlphaNum`-fallback for `adminPassword` and the
  two-Secrets-in-one-file layout are preserved around the helper
  calls).
- `templates/route.yaml` is intentionally **not** migrated — keyrock
  ships multiple Routes in a single file and `common.route.tpl`
  renders a single Route.

### Breaking changes

1. **Ingress `apiVersion`** — the `semverCompare ">=1.14-0"` branch
   in `templates/ingress.yaml` has been removed. The chart now always
   emits `networking.k8s.io/v1`, matching the chart's declared
   `kubeVersion: >= 1.19-0`. Kubernetes < 1.14 is effectively already
   out of scope, so in practice no supported environment is affected.

2. **Namespace on rendered manifests** — Service, Secret, HPA,
   ServiceAccount and Ingress now carry an explicit
   `metadata.namespace` field (taken from `.Release.Namespace`). This
   matches the convention used by every other FIWARE chart. It does
   not change where the resources are deployed; it only makes the
   namespace visible in the rendered manifest.

3. **`autoscaling.apiVersion` default** — a new `apiVersion` key has
   been added under `.Values.autoscaling` with a default of
   `"v2beta2"`, matching the value previously hard-coded in the
   legacy `statefulset-hpa.yaml` body. Users who already set
   `.Values.autoscaling.apiVersion` are unaffected; users on
   Kubernetes 1.26+ may wish to override it to `"v2"`.

### Non-breaking cosmetic changes to rendered output

- The blank leading line inside the labels block (a side-effect of
  the legacy `{{ include "keyrock.labels" . | nindent 4 }}` pattern)
  is gone — the common helper emits labels without a leading blank.
- Secret data keys are emitted in the order `common.secret.tpl`
  produces them (sorted by key). Base64 values are now emitted as a
  single-line `key: <base64>` scalar rather than a `|-` block
  scalar; both decode to identical bytes.
- HPA `metrics:` list items are indented by 4 spaces rather than 2.
  YAML-equivalent.

All of the above are cosmetic and do not alter the runtime behaviour
of any resource.

### Upgrade path

`helm upgrade` of an existing release should be a no-op for the
Service / StatefulSet selector pair (selector labels are unchanged),
and a standard field update for the Ingress / Secret / HPA /
ServiceAccount manifests. No data migration is required.
