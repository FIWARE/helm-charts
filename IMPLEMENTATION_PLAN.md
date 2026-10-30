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
- `values.yaml` uses helm-docs `# --` comments. Do not run helm-docs and do not create
  `README.md` by hand; the `chart-version` job in `check.yml` generates it.
- No magic numbers in templates. Ports, paths, mount dirs and key names come from values or
  from named helpers.

## Steps

### Step 1: Scaffold the chart with common-backed resources and the Deployment
Create `charts/dsc-consent-manager/` containing:
- `Chart.yaml`:
  - `apiVersion: v2`, `name: dsc-consent-manager`, `version: 0.1.0`, `appVersion: "0.1.0"`
    (the source's released tag), `kubeVersion: '>= 1.19-0'`.
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
    Copy them verbatim from the source with their comments converted to `# --`. Step 2 wires them.
- Single-include templates: `service.yaml` (API service on `service.port` → `http`, plus the
  always-ClusterIP management Service via `fiwareCommon.service.tpl` with `nameOverride`
  and port name `management`), `ingress.yaml`, `route.yaml`, `serviceaccount.yaml`,
  `deployment-hpa.yaml`.
- `templates/deployment.yaml`, ported from the source:
  - Image and pull secrets via `fiwareCommon.images.*`. `replicas` is omitted when
    `autoscaling.enabled`.
  - The two container ports, probes on the management port, the security contexts, and the
    `/tmp` emptyDir.
  - The signing-keys Secret volume, marked `optional: true` so pods are not stuck when the
    Secret is absent; see Step 2.
  - `envFrom` the ConfigMap and the Secret, and the identity-providers volume. Both point at
    resources that Step 2 adds; template the names via the helpers now.
  - `serviceAccountName`.
  - Scheduling block in the canonical `{{- with .Values.deployment.X }}` form (AGENTS.md,
    "Pod Scheduling Fields").
- `templates/NOTES.txt`, adapted from the source.

Acceptance: `helm dependency update charts/dsc-consent-manager && helm lint charts/dsc-consent-manager`
passes. `helm template` renders Deployment, both Services, and (when enabled) Ingress, Route,
HPA and ServiceAccount. Steps 1 and 2 can land on the work branch one after the other; the
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
  the `checksum/*` pod annotations in the Deployment so config changes roll the pods.
- `secret.yaml`: rendered unless `secrets.existingSecret` is set.
  - Remove the `required` on `dbUser`/`dbPassword`; default them to `consent_manager`/empty.
  - For `logPseudonymKey`/`erasureVerificationSecret` (never rotate), generate a random value
    on first install and keep it on upgrade via `lookup` plus the
    `helm.sh/resource-policy: keep` annotation. `charts/consent-manager/templates/secret.yaml`
    shows the pattern.
  - SMTP keys are emitted only when set.
- `servicemonitor.yaml` (`monitoring.coreos.com/v1`): behind `serviceMonitor.enabled`, scraping
  `/prometheus` on the management Service.
- `charts/dsc-consent-manager/ci/all-enabled-values.yaml`: enables ingress, route, HPA,
  ServiceMonitor, serviceAccount and one additional IdP. Add an existingSecret variant as well,
  for manual validation.
- AGENTS.md: add `dsc-consent-manager` to the chart list (32 total) and note the
  `dscConsentManager.*` helper prefix under Key Conventions.
- Optional: add `dsc-consent-manager` to the matrix in `.github/workflows/check-chart-updates.yml`.
  Its `sources[0]` must point at the upstream GitHub repo that publishes releases.

Acceptance:
- `helm lint charts/dsc-consent-manager` and
  `helm template charts/dsc-consent-manager | kubeconform -strict -ignore-missing-schemas`
  pass with defaults.
- The same passes with `-f ci/all-enabled-values.yaml` and with
  `--set secrets.existingSecret=foo` (no Secret rendered, `envFrom` points at `foo`).
- `./lint.sh` and `./eval.sh` stay green.
- `git diff main -- charts/consent-manager` is empty.
