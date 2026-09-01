# consent-owner-resolver changelog

## 0.1.0

Initial release of the consent-owner-resolver chart.

The consent-owner-resolver answers, for a piece of data a provider is about to release,
who owns it and which data resource a consent decision applies to. A consent
enforcement point calls it with the response body and gets back the claims to check, so
the gate is bound to the data rather than to whoever requested it.

- `Chart.yaml` — `apiVersion` v2, `kubeVersion: '>= 1.19-0'`, and the `common` library
  chart as a dependency.
- `templates/_helpers.tpl` — `resolver.name` / `.fullname` / `.chart` /
  `.serviceAccountName` / `.labels` as thin wrappers around the matching
  `fiwareCommon.*` helper, plus `resolver.config` (assembles the configuration
  document) and the two auth-secret helpers.
- `templates/service.yaml`, `serviceaccount.yaml`, `deployment-hpa.yaml`,
  `secret.yaml` — delegated to the `common` bodies.
- `templates/configmap.yaml` — the resolver's `config.json`, assembled from `defaults`,
  `contractService` and `rules`, or taken verbatim from `config` for a shape the chart
  does not model.
- `templates/deployment.yaml` — the resolver. The pod carries a
  `checksum/config` annotation so a changed rule set actually reaches the running pods:
  the rules decide every access decision, and a ConfigMap change alone does not restart
  a Deployment.
- `templates/networkpolicy.yaml` — restricts who may call `/resolve`. With no client
  declared it admits **nothing** rather than everything, which is what an empty `from`
  would mean.
