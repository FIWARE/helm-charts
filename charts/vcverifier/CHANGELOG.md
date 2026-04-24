# vcverifier changelog

## 4.10.0

### Common library chart migration

The chart now depends on the local `common` library chart
(`charts/common`, introduced in ticket-9 steps 1–6, see
`charts/common/README.md` and `docs/common-chart.md`). Every helper and
every structurally uniform resource template previously duplicated in
this chart is now a thin `include` of the matching `common.*` helper:

- `Chart.yaml` — bumped `apiVersion` v1→v2 (required to declare the
  `common` dependency), `version` 4.9.0→4.10.0. Added
  `kubeVersion: '>= 1.19-0'` (matching orion / keyrock / mintaka) and
  the `common` entry under `dependencies`.
- `templates/_helpers.tpl` — `vcverifier.name`, `vcverifier.fullname`,
  `vcverifier.chart`, `vcverifier.serviceAccountName` and
  `vcverifier.labels` now delegate to `common.names.*`,
  `common.serviceAccount.name` and `common.labels.standard`. The
  `vcverifier.*` names are preserved so any external umbrella chart
  that imports them keeps working (a future major release will drop
  the wrappers per `charts/common/DEPRECATIONS.md`, scheduled in
  Step 11 of the ticket-9 plan).
- `templates/service.yaml` → `common.service.tpl`.
- `templates/ingress.yaml` → `common.ingress.tpl`.

The following five templates were **intentionally kept chart-local**
because they carry chart-specific bodies with no counterpart in the
`common` helper surface. Migrating any of them would either require
extending `common` or would produce a breaking render-diff, which
violates the ticket's "update as minimal breaking as possible"
requirement:

| Template                             | Reason for staying chart-local                                                                                                                                                                                                                                         |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `templates/deployment.yaml`          | Chart-specific container / env / probe / volume body (CA-bundle init container, signing-cert and client-cert volumes, templates ConfigMap mount, static volume). Matches the "Deployment stays chart-local" non-goal in `docs/common-chart.md`.                         |
| `templates/route.yaml`               | Emits the `cert-utils-operator.redhat-cop.io/certs-from-secret` annotation when `.Values.route.certificate` is set and carries an explicit `spec.port.targetPort: {{ .Values.service.port }}`; neither is produced by `common.route.tpl`, so migrating would change the rendered manifest. |
| `templates/certificate.yaml`         | `cert-manager.io/v1` Certificate CR — not part of the common helper surface (same category as `keyrock` and `ishare-satellite`, which also stayed chart-local).                                                                                                        |
| `templates/configmap.yaml`           | Chart-specific verifier configuration ConfigMap (`server.yaml` payload).                                                                                                                                                                                              |
| `templates/configmap-templates.yaml` | Chart-specific `<fullname>-template` ConfigMap gating on `.Values.templates`.                                                                                                                                                                                          |

Vcverifier has no `serviceaccount.yaml`, no `secret.yaml`, and no HPA
template, so there are no further `common.*` includes to wire up.

### Non-breaking cosmetic changes to rendered output

These diffs are the full extent of the rendered-manifest changes
between 4.9.0 and 4.10.0 (aside from the expected `helm.sh/chart`
version-label bump, which applies to every labelled resource):

- `Service.spec.ports[0]` field order is now
  `port, targetPort, protocol, name` instead of
  `name, port, targetPort, protocol`. YAML-equivalent — Kubernetes
  parses both into the same `ServicePort` object.

No change to selector labels, no change to the Deployment, no change
to the Route body, no change to the Certificate body, no change to
either ConfigMap.

### Upgrade path

`helm upgrade` of an existing release is a no-op for selector labels
(all `app.kubernetes.io/name` and `app.kubernetes.io/instance` pairs
are identical pre- and post-migration) and a standard field update
for the `Service` and `Ingress` manifest bodies. No data migration is
required.

### Render-parity verification

The migration was validated with three `helm template` renders
against `main`:

```bash
# Before (main)
helm template --namespace ns --release-name rel \
  <main-checkout>/charts/vcverifier > /tmp/before.yaml

# After (this branch)
helm dependency update charts/vcverifier
helm template --namespace ns --release-name rel \
  charts/vcverifier > /tmp/after.yaml

diff -u /tmp/before.yaml /tmp/after.yaml
```

Repeated with
`--set ingress.enabled=true --set ingress.hosts[0].host=h --set ingress.hosts[0].paths[0]=/`
and with `--set route.enabled=true`. The resulting diffs contain
only the documented cosmetic deltas (`helm.sh/chart` bump and
Service `ports[0]` key order); the Ingress body, Route body,
Certificate body, and both ConfigMap bodies are byte-for-byte
identical.
