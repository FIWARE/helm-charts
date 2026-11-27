# consent-facade changelog

## 0.1.0

Initial release of the consent-facade chart.

The consent-facade serves the contract-service API a consent-manager consumes -
bilateral contracts, catalog self-descriptions and participant self-descriptions -
projected from a provider's TM Forum APIs. It holds no data of its own: everything it
answers is derived from the agreements, offerings and organizations the TM Forum APIs
already hold.

- `Chart.yaml` — `apiVersion` v2, `kubeVersion: '>= 1.19-0'`, and the `common` library
  chart as a dependency.
- `templates/_helpers.tpl` — `facade.name` / `.fullname` / `.chart` /
  `.serviceAccountName` / `.labels` as thin wrappers around the matching
  `fiwareCommon.*` helper, plus `facade.selfUrl` and the two provider-registry secret
  helpers.
- `templates/service.yaml`, `serviceaccount.yaml`, `ingress.yaml`, `route.yaml`,
  `deployment-hpa.yaml`, `secret.yaml` — delegated to the `common` bodies.
- `templates/deployment.yaml` — the facade itself, with three optional pieces:
  - **`oid4vp`** — presents a verifiable credential to obtain an access token for an
    OID4VP-protected TM Forum API. The holder key is taken from a secret and, with
    `oid4vp.signingKey.convert`, converted from SEC1 to PKCS#8 by an init container
    (which is how a cert-manager EC key arrives). Credentials are projected from their
    own secrets into one folder. Token targets are passed as system properties via
    `JAVA_TOOL_OPTIONS`, because they are a list of objects and kubernetes rejects the
    bracketed property names in an env var name.
  - **`truststore`** — imports an additional CA into a copy of the JVM truststore, for
    a target whose certificate comes from a private CA. The JDK path is resolved at
    runtime rather than hardcoded, so a change of the image's base does not break it.
  - **`providerRegistry.persistent`** — keeps the providers in PostgreSQL instead of in
    memory and enables the `/providers` admin API.
