# Implementation Plan: Consent Manager - Reimplementation - Helm Chart

## Overview
Port the Helm chart from `wistefan/dsc-consent-manager` (`charts/consent-manager`) to this
repo as a new chart, `charts/dsc-consent-manager`. The chart is built on the `common` library
chart and follows FIWARE conventions. The existing `charts/consent-manager` (VisionsOfficial)
stays untouched. With default values the chart must pass `helm lint` and
`helm template | kubeconform`. Cleaning up the source repo is out of scope.

Source of truth for behaviour: `https://github.com/wistefan/dsc-consent-manager/tree/main/charts/consent-manager`
(`values.yaml`, `templates/{_helpers.tpl,deployment.yaml,service.yaml,configmap.yaml,
configmap-identity-providers.yaml,secret.yaml,servicemonitor.yaml,hpa.yaml,ingress.yaml,NOTES.txt}`,
`ci/{minimal,all-enabled}-values.yaml`). Clone it read-only into `/tmp`.

Ground rules for every step:
- Helper namespace is `dscConsentManager.*`. Do not use `consentManager.*`, which belongs to
  the existing chart.
- Shared helpers come from `common` as `fiwareCommon.*`. The reference shape is
  `charts/consent-manager/templates/`.
- `values.yaml` uses helm-docs `# --` comments. The `chart-version` job in `check.yml` keeps
  `README.md` current, but only for files git already tracks (`chart-pr.yml` stages with
  `git add --update`), so Step 2 generates the initial README once by hand.
- No magic numbers in templates. Ports, paths, mount dirs and key names come from values or
  from named helpers.

## Steps

### Step 1: Scaffold the chart with common-backed resources and the Deployment
Create `charts/dsc-consent-manager/` containing:
- `Chart.yaml`:
  - `apiVersion: v2`, `name: dsc-consent-manager`, `version: 0.1.0`, `appVersion: "0.0.1"`
    (the source's only release; git tag and `quay.io/seamware/dsc-consent-manager` tag),
    `kubeVersion: '>= 1.19-0'`. The bump script keeps the version of a chart absent on `main`.
  - Description, FIWARE `icon`, and `keywords` (FIWARE, consent-manager, Consent, DSBA).
  - `home`/`sources: [https://github.com/wistefan/dsc-consent-manager]`, maintainer `wistefan`.
  - `dependencies: [{name: common, repository: "https://fiware.github.io/helm-charts", version: "0.1.2"}]`.
- `.helmignore`: copy one from an existing chart.
- `templates/_helpers.tpl`:
  - Thin wrappers `dscConsentManager.{name,fullname,chart,labels,selectorLabels,serviceAccountName,secretName}`
    over `fiwareCommon.*`. `secretName` resolves `secrets.existingSecret` through
    `fiwareCommon.secrets.name`.
  - Chart-local helpers ported from the source: `managementServiceName` (`<fullname>-management`),
    `signingKeysSecretName`, `identityProvidersConfigMapName`, `identityProvidersDir`,
    `identityProvidersFile`, `signingKeysDir`.
  - One short `{{/* */}}` line per define.
- `values.yaml`, restructured to the FIWARE layout:
  - Root keys: `nameOverride`, `fullnameOverride`, `imagePullSecrets`;
    `serviceAccount.{create: false, annotations, name}`.
  - `deployment.*`: `replicaCount`, `image.{repository: quay.io/seamware/dsc-consent-manager, tag: "", pullPolicy}`,
    `podAnnotations`, `podLabels`, `resources`, `containerPorts.{http,management}`, `probes.*`,
    `podSecurityContext`, `securityContext`, `tmp.sizeLimit`, plus `nodeSelector`, `affinity`,
    `tolerations`, `priorityClassName: ""` and `topologySpreadConstraints: []`, using the
    snippet in AGENTS.md.
  - `service.{type, port}`, `managementService.port`.
  - `ingress.*`, shaped as `fiwareCommon.ingress.tpl` expects (see
    `charts/consent-manager/values.yaml`).
  - `route.{enabled: false, ...}`.
  - `autoscaling.{enabled: false, apiVersion: v2, minReplicas, maxReplicas, metrics: [cpu 75%]}`.
    The source's `targetCPUUtilizationPercentage` maps to the `metrics` list that
    `fiwareCommon.hpa.tpl` takes. Port the source's min>max guard as a `fail` in `deployment-hpa.yaml`.
  - Placeholders for `config`, `identityProviders`, `secrets`, `signingKeys`, `serviceMonitor`.
    Copy them from the source with their comments converted to `# --`. Step 2 wires them.
    Do not copy the source's header comment ("These defaults do not install on their own...")
    or its stale `quay.io/fiware/consent-manager` repository; Step 2 writes a new header.
- Single-include templates: `service.yaml` (API Service on `service.port` → `http` via
  `fiwareCommon.service.tpl`), `ingress.yaml`, `route.yaml`, `serviceaccount.yaml`,
  `deployment-hpa.yaml`.
- `templates/service-management.yaml`: a small inline `v1/Service`, not
  `fiwareCommon.service.tpl`. Common 0.1.2 reads `nameOverride` but never applies it
  (`metadata.name` is always `fiwareCommon.names.fullname`), so the include would emit a second
  Service named `<fullname>`. Passing `component: management` does not work either: it adds
  `app.kubernetes.io/component` to the selector, which then matches no pods.
  - `name: {{ include "dscConsentManager.managementServiceName" . }}`, namespace and
    `dscConsentManager.labels` as on the other resources.
  - `type: ClusterIP`, one port named `management` on `managementService.port` →
    `targetPort: management`.
  - `selector: dscConsentManager.selectorLabels`.
  - The common bug (it already gives scorpio-broker duplicate Service names) is out of scope;
    track it separately.
- `templates/deployment.yaml`, ported from the source:
  - Image and pull secrets via `fiwareCommon.images.*`. `replicas` is omitted when
    `autoscaling.enabled`.
  - The two container ports, probes on the management port, the security contexts, and the
    `/tmp` emptyDir.
  - The signing-keys Secret volume, non-optional as in the source. The chart never creates
    this Secret: a missing one keeps the pod in ContainerCreating with a clear
    `secret not found` event, rather than starting the app with a dangling
    `RECEIPTS_SIGNING_KEY_FILE` path.
  - `envFrom` the ConfigMap and the Secret. Both point at resources that Step 2 adds;
    template the names via the helpers now.
  - The identity-providers ConfigMap volume, its volumeMount and the `MICRONAUT_CONFIG_FILES`
    env var, all behind `{{- if .Values.identityProviders.additional }}`, the same guard as
    the ConfigMap in Step 2 (the source does the same). Unguarded, a default install mounts a
    ConfigMap that is never rendered and the pod stays in ContainerCreating.
  - `serviceAccountName`.
  - Scheduling block in the canonical `{{- with .Values.deployment.X }}` form (AGENTS.md,
    "Pod Scheduling Fields").
- `templates/NOTES.txt`, adapted from the source. Keep its step 1, the
  `kubectl create secret generic <signingKeysSecretName> --from-file=...` instruction.

Acceptance: `helm dependency update charts/dsc-consent-manager && helm lint charts/dsc-consent-manager`
passes. `helm template` renders Deployment, both Services, and (when enabled) Ingress, Route,
HPA and ServiceAccount. kubeconform checks each document on its own, so also check that
`helm template t charts/dsc-consent-manager | yq 'select(.kind=="Service") | .metadata.name'`
prints two distinct names, `t-dsc-consent-manager` and `t-dsc-consent-manager-management`.
The default render has no `identity-providers` volume, volumeMount or `MICRONAUT_CONFIG_FILES`
env var (`helm template t charts/dsc-consent-manager | grep -c -e identity-providers -e MICRONAUT_CONFIG_FILES`
prints `0`). Steps 1 and 2 can land on the work branch one after the other; the
chart is validated as a whole in Step 2. If the Deployment references to the ConfigMap/Secret
break `kubeconform` before Step 2, that is acceptable because kubeconform does not resolve
references.

### Step 2: Port ConfigMaps, Secret and ServiceMonitor; make defaults render
Add to `charts/dsc-consent-manager/templates/`:
- `configmap.yaml`: ported from the source, with these changes:
  - Remove the hard `required` checks on `config.database.url` and
    `identityProviders.primary.{issuer,discoveryUrl,audience}`.
  - `values.yaml` gets working placeholder defaults instead, documented as
    must-override-for-production: `jdbc:postgresql://postgres:5432/consent_manager`, and
    `https://idp.example.org/realms/consent-manager` plus its well-known URL and audience
    `consent-manager`.
  - Keep every other `fail` guard (extraEnv deny-lists, primary roleMapping, SMTP
    `fromAddress` when `smtp.host` is set). Those only trigger on non-default input.
- `configmap-identity-providers.yaml`: rendered only when `identityProviders.additional` is
  non-empty. Keep its `required`/`fail` checks, which only apply to user-supplied entries. Keep
  the `checksum/*` pod annotations in the Deployment so config changes roll the pods. The
  ConfigMap's guard must stay identical to the Deployment's volume guard from Step 1.
- `secret.yaml`: rendered unless `secrets.existingSecret` is set.
  - Remove the `required` on `dbUser`/`dbPassword`; default them to `consent_manager`/empty.
  - `logPseudonymKey`/`erasureVerificationSecret` must never rotate (rotation breaks log
    correlation and outstanding erasure verifications). Take the configured value when set.
    Only as a fallback, reuse the value from the live Secret via `lookup`, else generate one,
    and annotate the Secret `helm.sh/resource-policy: keep`
    (`charts/consent-manager/templates/secret.yaml` shows the pattern).
  - `lookup` returns nothing under `helm template`, `--dry-run`, Argo CD and Flux, so the
    fallback rotates on every render there. Say so in a `# --` warning on both keys: GitOps
    users must set them or use `secrets.existingSecret`. NOTES.txt prints the same warning
    when the fallback was used.
  - Compute the Deployment's `checksum/secret` from `.Values.secrets`, not from the rendered
    Secret, so generated fallback values do not roll the pods on every render.
  - SMTP keys are emitted only when set.
- `servicemonitor.yaml` (`monitoring.coreos.com/v1`): behind `serviceMonitor.enabled`, scraping
  `/prometheus` on the management Service.
- Must-override notice: the placeholder defaults let the chart install, but the pod
  crash-loops against `idp.example.org` and `postgres:5432` until they are replaced; this is
  intended, so defaults pass lint and kubeconform. Replace the `values.yaml` header with a
  notice listing what production installs must set (`identityProviders.primary.*`,
  `config.database.url`, `secrets.*` or `secrets.existingSecret`, the signing-key Secret).
  NOTES.txt prints the same notice while any placeholder is still in use.
- `charts/dsc-consent-manager/ci/all-enabled-values.yaml`: enables ingress, route, HPA,
  ServiceMonitor, serviceAccount and one additional IdP. Add an existingSecret variant as well,
  for manual validation.
- `README.md`: run `jnorwood/helm-docs:v1.14.2` once on the chart (same image as
  `check.yml`) and commit the result, so the `chart-version` job tracks it from then on.
- AGENTS.md:
  - Add `dsc-consent-manager` to the chart list (32 total, 31 application + 1 library) and
    note the `dscConsentManager.*` helper prefix under Key Conventions.
  - Update "Pod Scheduling Fields": 46 workload templates across 31 charts, 34 of them in 30
    charts carrying a scheduling block; the `deployment.*` prefix count goes from 21 to 22.
  - In the `common` helper list under Key Conventions, mark `service.tpl`'s `nameOverride` as
    accepted but not applied in 0.1.2, so later charts do not rely on it.
- Optional: add `dsc-consent-manager` to the matrix in `.github/workflows/check-chart-updates.yml`.
  Its `sources[0]` must point at the upstream GitHub repo that publishes releases.

Acceptance:
- `helm lint charts/dsc-consent-manager` and
  `helm template charts/dsc-consent-manager | kubeconform -strict -ignore-missing-schemas`
  pass with defaults.
- The same passes with `-f ci/all-enabled-values.yaml` and with
  `--set secrets.existingSecret=foo` (no Secret rendered, `envFrom` points at `foo`).
- `./lint.sh` and `./eval.sh` stay green.
- Two consecutive `helm template` runs with defaults produce the same `checksum/secret`.
- Rendered Service names are unique, with defaults and with `-f ci/all-enabled-values.yaml`
  (same `yq` check as Step 1).
- With defaults, neither the identity-providers ConfigMap nor its volume renders. With
  `-f ci/all-enabled-values.yaml`, the volume's `configMap.name` equals the rendered
  ConfigMap's `metadata.name`.
- `git ls-files charts/dsc-consent-manager/README.md` lists the file.
- `git diff main -- charts/consent-manager` is empty.
