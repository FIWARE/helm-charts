# FIWARE helm-charts

## Overview
Monorepo of 25+ Helm charts for FIWARE Generic Enablers (Orion-LD, Keyrock, Scorpio,
Mintaka, VCVerifier, TM Forum API, etc.). Published to
https://fiware.github.io/helm-charts and indexed on Artifact Hub.

## Tech Stack
- Packaging: Helm 3 (`apiVersion: v2`)
- Templating: Go templates / Sprig (`.tpl`, `.yaml` under `templates/`)
- Validation: `helm lint`, `helm template | kubeconform -strict -ignore-missing-schemas`
- CI: GitHub Actions (Chart Test workflow)

## Project Structure
```
./
├── charts/                       # one directory per chart
│   ├── <chart>/
│   │   ├── Chart.yaml            # apiVersion v2, name, version, appVersion
│   │   ├── values.yaml
│   │   ├── values.schema.json    # optional, only orion today
│   │   ├── README.md             # usually generated from values
│   │   └── templates/
│   │       ├── _helpers.tpl      # <chart>.name / .fullname / .chart /
│   │       │                     #   .serviceAccountName / .labels / .secretName
│   │       ├── deployment.yaml   # or statefulset.yaml
│   │       ├── deployment-hpa.yaml
│   │       ├── service.yaml
│   │       ├── serviceaccount.yaml
│   │       ├── ingress.yaml
│   │       ├── route.yaml        # OpenShift Route
│   │       ├── secret.yaml
│   │       └── NOTES.txt
├── build.sh                      # helm dependency update across all charts
├── lint.sh                       # helm lint across all charts
└── eval.sh                       # helm template | kubeconform across all charts
```

Charts in the repo (as of 2026-09): api-umbrella, apollo, bae-activation-service,
business-api-ecosystem, canis-major, common (library), consent-facade, consent-manager,
consent-owner-resolver, contract-management, credentials-config-service, did-helper,
dsba-pdp, dss-validation-service, endpoint-auth-service, fdsc-dashboard, fdsc-edc,
iotagent-json, iotagent-ul, ishare-satellite, keyrock, mintaka, odrl-pap,
onboarding-portal, orion, scorpio-broker, scorpio-broker-aaio, tm-forum-api,
trusted-issuers-list, trusted-issuers-registry, vcverifier
(31 total, 30 application + 1 library).

## Build & Test
```bash
./build.sh                            # helm dependency update for every chart
./lint.sh                             # helm lint every chart (exits non-zero on failure)
./eval.sh                             # helm template | kubeconform -strict
helm lint charts/<chart>              # single-chart lint
helm template charts/<chart>          # render single chart to stdout
helm template charts/<chart> | kubeconform -strict -ignore-missing-schemas
```

## Key Conventions
- Helper names are namespaced by chart: `{{ include "<chart>.fullname" . }}`,
  `<chart>.name`, `<chart>.chart`, `<chart>.labels`, `<chart>.serviceAccountName`,
  `<chart>.secretName`.
- Names are capped with `| trunc 63 | trimSuffix "-"` (DNS 1123 label limit).
- `fullname` pattern: honours `.Values.fullnameOverride`; otherwise
  `printf "%s-%s" .Release.Name $name` unless the release name already contains the
  chart name.
- Standard labels emitted: `app.kubernetes.io/name`, `helm.sh/chart`,
  `app.kubernetes.io/instance`, `app.kubernetes.io/version` (if `.Chart.AppVersion`),
  `app.kubernetes.io/managed-by`.
- `namespace: {{ $.Release.Namespace | quote }}` is used explicitly on most resources.
- Ingress uses `networking.k8s.io/v1` (keyrock still branches on
  `semverCompare ">=1.14-0"`).
- OpenShift Route (`route.openshift.io/v1`) is rendered behind `.Values.route.enabled`.
- HPA uses `apiVersion: autoscaling/{{ .Values.autoscaling.apiVersion }}` gated by
  `.Values.autoscaling.enabled`.
- Secrets: `<chart>.secretName` returns `.Values.*.existingSecret` if provided,
  otherwise falls back to `<chart>.fullname`.
- ServiceAccount created only when `.Values.serviceAccount.create` is true.
- `Chart.yaml` annotation `charts.openshift.io/name` is used where charts ship an
  OpenShift route.

## Pod Scheduling Fields
- Scheduling fields live in each workload template's podSpec, never in the `common` library
  chart: `docs/common-chart.md` lists "Rewriting Deployment / StatefulSet bodies into a
  shared template" as an explicit non-goal (variation across env vars, volume mounts,
  probes, init containers and sidecars is too high to share at the YAML level).
- Coverage: 45 workload templates (Deployment/StatefulSet/DaemonSet) across 30 charts. 33 of
  them, in 29 charts, carry a scheduling block; the other 12 carry none.
- Fields in those 33: `nodeSelector`, `affinity`, `tolerations`, plus `priorityClassName` and
  `topologySpreadConstraints` (see In-flight section below).
- Always gate with `{{- with }}`, never a bare `if` plus interpolation. An unset value (`""`,
  `[]`, `{}`) then renders nothing, which preserves the repo's guiding rule that the
  render-diff against the previous chart version is empty for existing releases.
- The value prefix is whatever the chart already uses for `nodeSelector`. Do not normalise
  it: "Normalising value keys" is a declared non-goal in `docs/common-chart.md`.
  - `deployment.*` — 21 charts (majority)
  - root `.Values.*` — `did-helper`, `onboarding-portal`, `scorpio-broker-aaio`
  - `statefulset.*` — `keyrock`
  - `configService.*` / `ishare.*` / `sidecarInjector.*` — `endpoint-auth-service`
  - `bizEcosystemChargingBackend.deployment.*` / `bizEcosystemLogicProxy.statefulset.*` —
    `business-api-ecosystem`
  - `defaultConfig.*`, overridable per entry of `apis[]` — `tm-forum-api`
  - `deployment.<name>.*`, a map ranged over — `fdsc-edc`
- Canonical block (30 of the 33 templates), e.g. `charts/vcverifier/templates/deployment.yaml`:
```gotemplate
      {{- with .Values.deployment.priorityClassName }}
      priorityClassName: {{ . }}
      {{- end }}
      {{- with .Values.deployment.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```
- Two charts deviate and must keep their local style:
  - `tm-forum-api` — podSpec sits inside a `range`, so it uses `$` and doubles the guard:
    `{{- if $.Values.defaultConfig.X }}` wrapping `{{- with $.Values.defaultConfig.X }}`.
    `deployment.yaml` additionally supports a per-API override, `{{- if .X }}` /
    `{{- else if $.Values.defaultConfig.X }}`.
  - `fdsc-edc/templates/deployment.yaml` — ranges `.Values.deployment` as a map and reads
    `$cfg.deployment.*`, not `.Values.*`.
- Templates with no scheduling block at all, out of scope unless deliberately extended:
  - `scorpio-broker` — all 10 component deployments. Its `README.md` documents
    `<component>.nodeSelector` but no template renders it: documented-vs-implemented gap.
  - `orion/templates/deployment-mongo.yaml`
  - `tm-forum-api/templates/envoy.yaml` — `values.yaml` declares
    `apiProxy.nodeSelector` / `.tolerations` / `.affinity` (L239-245) and the template
    ignores all three. Pre-existing bug, track separately.
  - The 5 Jobs (`vcverifier`, `credentials-config-service`, `trusted-issuers-list`,
    `keyrock`, `orion`).
- `topologySpreadConstraints` is GA since k8s 1.19 and charts declare either
  `kubeVersion: '>= 1.19-0'` (14 charts) or nothing, so it needs no version gate.

## CI/CD Workflows
- `.github/workflows/deploy.yml` — publishes charts to GitHub Pages via
  `helm/chart-releaser-action@v1.5.0` on push to `main`
- `.github/workflows/check.yml` — PR checks: lint, eval (kubeconform), common-tests,
  label check, version bump, helm-docs generation
- `.github/workflows/check-labels.yml` — enforces `major`/`minor`/`patch` label on PRs
- `.github/workflows/check-chart-updates.yml` — weekly cron checking upstream releases
- `.github/actions/bump-chart-version/` — composite action for semver bumping
- Helm version pinned in CI: `4.0.4` (env var `HELM_VERSION` in `check.yml`)

## Important Files
- `charts/orion/templates/_helpers.tpl` — canonical helper pattern
- `charts/keyrock/templates/_helpers.tpl` — includes `existingSecret` + `certSecret`
  helpers
- `charts/scorpio-broker/templates/` — multi-service chart with per-component
  deployments/services/HPAs (good test case for helpers that take a component name)
- `charts/common/` — library chart (`type: library`) used as dependency by all charts
- `build.sh`, `lint.sh`, `eval.sh` — CI entry points, must keep passing after changes
- `.github/workflows/deploy.yml` — GitHub Pages chart publishing (must not be modified
  when adding OCI publishing)
- `.github/workflows/check.yml` — PR validation workflow

## In-flight: scheduling fields PR
> Temporary section. Delete once the PR below is merged and released.

Adding `priorityClassName` and `topologySpreadConstraints` to the 33 workload templates that
already carry a scheduling block. Driver: FIWARE charts expose neither field, so downstream
deployments that define PriorityClasses cannot attach them and every pod stays at
`priority: 0`. Single PR, semver label `minor` (purely additive; render-diff empty when the
values are unset).

Per chart: add both keys next to the existing `nodeSelector` in `values.yaml`, using the
helm-docs `# --` comment style of its neighbours, and insert the rendered fields next to the
`nodeSelector` block in each workload template. Then bump `version` in `Chart.yaml` —
`chart-releaser` only publishes charts whose version changed.

```yaml
  # -- priority class to be assigned to the pods
  # ref: https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/
  priorityClassName: ""
  # -- topology spread constraints template
  # ref: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/
  topologySpreadConstraints: []
```

Charts to touch (29; template count in brackets where not 1):
- [ ] api-umbrella
- [ ] apollo
- [ ] bae-activation-service
- [ ] business-api-ecosystem [2]
- [ ] canis-major
- [ ] consent-facade
- [ ] consent-manager
- [ ] consent-owner-resolver
- [ ] contract-management
- [ ] credentials-config-service
- [ ] did-helper
- [ ] dsba-pdp
- [ ] dss-validation-service
- [ ] endpoint-auth-service [3]
- [ ] fdsc-dashboard
- [ ] fdsc-edc (family C, `$cfg`)
- [ ] iotagent-json
- [ ] iotagent-ul
- [ ] ishare-satellite
- [ ] keyrock
- [ ] mintaka
- [ ] odrl-pap
- [ ] onboarding-portal
- [ ] orion (also declare both keys in `values.schema.json`)
- [ ] scorpio-broker-aaio
- [ ] tm-forum-api [2] (family B, doubled guard)
- [ ] trusted-issuers-list
- [ ] trusted-issuers-registry
- [ ] vcverifier

Checks before opening:
- [ ] Render-diff empty per chart with values unset: `helm template` before vs after
- [ ] Renders when set: `helm template charts/vcverifier --set deployment.priorityClassName=x`
      (`tm-forum-api` needs `--set defaultConfig.priorityClassName=x --set allInOne.enabled=true`)
- [ ] `./lint.sh` and `./eval.sh` pass
- [ ] Do NOT hand-edit `README.md` — CI regenerates them with helm-docs v1.14.2
- [ ] Warn the maintainer: this releases ~29 charts at once, no precedent in the repo
