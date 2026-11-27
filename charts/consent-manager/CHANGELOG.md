# consent-manager changelog

## 0.1.0

Initial release of the consent-manager chart.

The consent-manager ([VisionsOfficial/consent-manager](https://github.com/VisionsOfficial/consent-manager))
stores and serves consent records and ISO/IEC TS 27560 receipts. It derives its privacy
notices from the contract-service API a consent-facade serves, and keeps its data in a
MongoDB **replica set** (it uses transactions).

The image is [`quay.io/wi_stefan/consent-manager`](https://quay.io/repository/wi_stefan/consent-manager) -
a compiled, non-root, read-only-filesystem-safe build of the upstream application.

- `Chart.yaml` — `apiVersion` v2, `kubeVersion: '>= 1.19-0'`, and the `common` library
  chart as a dependency.
- `templates/_helpers.tpl` — `consentManager.name` / `.fullname` / `.chart` /
  `.serviceAccountName` / `.labels` as thin wrappers around the matching
  `fiwareCommon.*` helper, plus `consentManager.appEndpoint`,
  `consentManager.contractServiceUrl` and the secret-resolution helpers.
- `templates/service.yaml`, `serviceaccount.yaml`, `ingress.yaml`, `route.yaml`,
  `deployment-hpa.yaml`, `mongo-secret.yaml` — delegated to the `common` bodies.
- `templates/secret.yaml` — the session / JWT / OAuth secrets and the consent key. The
  three secrets are generated on first install and then **kept**: the template reads the
  live values back with `lookup`, so a redeploy does not invalidate existing sessions and
  issued tokens, and `helm.sh/resource-policy: keep` protects them from an uninstall. The
  consent key is never generated - the gateway in front injects that exact value, so it is
  a required value.
- `templates/deployment.yaml` — the application, with:
  - **MongoDB** either as a full `mongo.uri` or assembled from its parts, with the
    password referenced through `$(CM_MONGO_PASSWORD)` so it never appears in the pod spec.
  - **`externalIdp`** — verification of externally issued (OID4VP) tokens: trusted issuers,
    audience, algorithms, a configurable discovery path for a verifier that serves discovery
    per service, an optional forward proxy for reaching that verifier in-cluster, and an
    optional CA exported as `NODE_EXTRA_CA_CERTS`.
  - **`deployment.writablePaths`** — the paths the application writes to while the root
    filesystem is read-only, as `<volume name>: <path>`, because the log paths are part of
    the image layout.
  - Probes are **off by default**: the application serves no dedicated health endpoint, so
    a probe has to be pointed at a real api path.
