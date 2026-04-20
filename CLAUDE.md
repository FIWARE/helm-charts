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

Charts in the repo (as of 2026-04): api-umbrella, apollo, bae-activation-service,
business-api-ecosystem, canis-major, contract-management, credentials-config-service,
did-helper, dsba-pdp, dss-validation-service, endpoint-auth-service, fdsc-edc,
iotagent-json, iotagent-ul, ishare-satellite, keyrock, mintaka, odrl-pap,
onboarding-portal, orion, scorpio-broker, scorpio-broker-aaio, tm-forum-api,
trusted-issuers-list, trusted-issuers-registry, vcverifier.

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

## Important Files
- `charts/orion/templates/_helpers.tpl` — canonical helper pattern
- `charts/keyrock/templates/_helpers.tpl` — includes `existingSecret` + `certSecret`
  helpers
- `charts/scorpio-broker/templates/` — multi-service chart with per-component
  deployments/services/HPAs (good test case for helpers that take a component name)
- `build.sh`, `lint.sh`, `eval.sh` — CI entry points, must keep passing after refactor
- `.github/workflows/` (upstream) — Chart Test workflow runs `helm lint` and
  `kubeconform` on PRs
