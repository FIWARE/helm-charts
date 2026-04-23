# Implementation Plan: Helm-Chart for the fdsc-dashboard

## Overview
Create a new Helm chart `charts/fdsc-dashboard/` that packages
[`wistefan/fdsc-dashboard`](https://github.com/wistefan/fdsc-dashboard)
(a Vue 3 / nginx-served SPA, image `quay.io/seamware/fdsc-dashboard`) for
deployment on Kubernetes and OpenShift. The chart follows the FIWARE
monorepo conventions (Chart.yaml apiVersion v2, version / appVersion,
icon, keywords, sources, maintainers), consumes the in-repo `common`
library chart for the standard Service / Ingress / Route / HPA /
ServiceAccount / Secret bodies, and exposes all of the upstream
application's configuration options via `values.yaml` — the runtime
`AUTH_CONFIG_JSON` OIDC providers blob (rendered into a Secret), the
build-time `VITE_*` API URLs surfaced via `additionalEnvVars` for users
who build their own image, plus every standard FIWARE knob (replicas,
probes, resources, nodeSelector, tolerations, affinity, imagePullSecrets,
autoscaling, ingress, route). After the chart is rendered successfully
by `./lint.sh` and `./eval.sh`, the root `README.md` is updated to list
the new chart alongside the others.

## Steps

### Step 1: Chart skeleton — `Chart.yaml`, `values.yaml`, empty `templates/` dir

Create `charts/fdsc-dashboard/` with:

- **`Chart.yaml`** — `apiVersion: v2` (required for library dependencies),
  `name: fdsc-dashboard`, `version: 0.1.0`, `appVersion: 0.1.0` (pinned
  to the current upstream release; to be bumped per appVersion sync
  PRs), `description`, `icon: https://fiware.github.io/catalogue/img/fiware.png`,
  keywords (`fiware`, `data-space-connector`, `dataspace`, `dashboard`,
  `ui`), `sources` pointing at
  `https://github.com/wistefan/fdsc-dashboard`, `maintainers`
  (`wistefan`, mirroring `charts/fdsc-edc/Chart.yaml`), and the `common`
  library dependency:

  ```yaml
  dependencies:
    - name: common
      repository: "file://../common"
      version: "0.0.1"
  ```

- **`values.yaml`** — complete configuration surface:
  - `nameOverride`, `fullnameOverride` (standard).
  - `service` block: `type: ClusterIP`, `port: 8080`, `annotations: {}`
    (the container listens on 80; the service exposes 8080 and targets
    the container port via `.Values.port`).
  - `serviceAccount` block: `create: false`, optional `name` — matches
    the migrated-chart convention.
  - `deployment` block: `replicaCount: 1`, `revisionHistoryLimit: 3`,
    `updateStrategy` (RollingUpdate, maxSurge 1, maxUnavailable 0),
    `image` (`repository: quay.io/seamware/fdsc-dashboard`, `tag`
    commented out so it falls back to `.Chart.AppVersion`,
    `pullPolicy: IfNotPresent`), `imagePullSecrets: []`,
    `additionalLabels: {}`, `additionalAnnotations: {}`, `resources` (kept
    commented — standard FIWARE pattern), `nodeSelector: {}`,
    `tolerations: []`, `affinity: {}`, `livenessProbe` / `readinessProbe`
    using TCP probes against the http port (no `/health` endpoint
    upstream — the nginx container serves static assets), `args: []`,
    `command: []`, `additionalVolumeMounts: []`, `additionalVolumes: []`.
  - `port: 80` — container port (nginx default).
  - `auth` block for the runtime `AUTH_CONFIG_JSON` env var:
    - `existingSecret: ""` — name of a pre-existing Secret with an
      `AUTH_CONFIG_JSON` key; when set, overrides the rendered Secret.
    - `secretKey: AUTH_CONFIG_JSON` — the key inside the Secret to
      mount into the env var.
    - `config:` — raw OIDC providers config (default `{"providers":[]}`),
      used to populate the rendered Secret when `existingSecret` is
      empty. This mirrors the upstream default (auth disabled).
  - `apiUrls` block — **documented as build-time** (VITE_* vars are
    baked into the bundle). The keys exist in values so that users with
    custom-built images can surface them via `additionalEnvVars`; the
    field's comment explains the build-time nature so ops-level users
    are not misled. Keys: `til`, `tir`, `ccs`, `odrl`, `authToken`.
  - `additionalEnvVars: []` — standard FIWARE escape hatch.
  - `autoscaling` block (enabled, `apiVersion: "v2beta2"`, minReplicas,
    maxReplicas, metrics) — matches the body `common.hpa.tpl` expects.
  - `ingress` block (enabled, annotations, hosts, tls) — matches the
    body `common.ingress.tpl` expects.
  - `route` block (enabled, annotations, host, tls) — matches the body
    `common.route.tpl` expects.
  - Every public key carries a `# --` helm-docs-style comment so the
    generated README is self-documenting.

- **Empty `templates/` directory** (files added in Step 2). The step is
  complete when `helm dependency update charts/fdsc-dashboard` succeeds
  (no template rendering yet).

**Files created**
- `charts/fdsc-dashboard/Chart.yaml`
- `charts/fdsc-dashboard/values.yaml`
- `charts/fdsc-dashboard/templates/.gitkeep` (placeholder, removed in
  Step 2)

**Acceptance criteria**
- `helm dependency update charts/fdsc-dashboard` succeeds and creates
  `charts/fdsc-dashboard/charts/common-0.0.1.tgz` plus
  `charts/fdsc-dashboard/Chart.lock`.
- `helm lint charts/fdsc-dashboard` reports only the "chart contains no
  templates" info (acceptable until Step 2).
- `./build.sh` still exits zero for every chart in the repo.
- Running `helm show values charts/fdsc-dashboard` surfaces every
  configuration key the upstream app accepts.

---

### Step 2: Templates — `_helpers.tpl`, `deployment.yaml`, `secret.yaml`, plus `common.*` one-liners and `NOTES.txt`

Add the full `templates/` set. The bulk of the work is the chart-specific
`deployment.yaml` and the runtime `Secret` holding `AUTH_CONFIG_JSON`;
everything else is a single-line `include` of a `common.*.tpl` helper.

- **`templates/_helpers.tpl`** — mirrors
  `charts/mintaka/templates/_helpers.tpl`: five thin wrappers delegating
  to `common.*` (`fdsc-dashboard.name` →  `common.names.name`,
  `fdsc-dashboard.fullname` → `common.names.fullname`,
  `fdsc-dashboard.chart` → `common.names.chart`,
  `fdsc-dashboard.serviceAccountName` → `common.serviceAccount.name`,
  `fdsc-dashboard.labels` → `common.labels.standard`), plus one chart-
  specific helper `fdsc-dashboard.authSecretName` that delegates to
  `common.secrets.name` with the `auth.existingSecret` lookup — matches
  the keyrock / canis-major pattern.

- **`templates/deployment.yaml`** (chart-specific, cannot be delegated
  to `common` — see `docs/common-chart.md` non-goals):
  - `apps/v1/Deployment` named `{{ include "fdsc-dashboard.fullname" . }}`
    with explicit `metadata.namespace: {{ $.Release.Namespace | quote }}`.
  - Standard selector / template labels via `fdsc-dashboard.labels` and
    `fdsc-dashboard.name`.
  - `replicas` emitted only when `.Values.autoscaling.enabled` is false
    (matches mintaka's pattern so HPA can take over).
  - `revisionHistoryLimit`, `strategy` from `.Values.deployment`.
  - `serviceAccountName: {{ include "fdsc-dashboard.serviceAccountName" . }}`.
  - `imagePullSecrets` block, honouring `.Values.deployment.imagePullSecrets`.
  - Single container `fdsc-dashboard`:
    - `image: "{{ .Values.deployment.image.repository }}:{{ .Values.deployment.image.tag | default .Chart.AppVersion }}"`,
      `imagePullPolicy: {{ .Values.deployment.image.pullPolicy }}`.
    - `ports: - name: http, containerPort: {{ .Values.port }}, protocol: TCP`.
    - `livenessProbe` / `readinessProbe` — `tcpSocket` against port
      `http` (upstream ships no dedicated health endpoint).
    - `env:` block — `AUTH_CONFIG_JSON` via
      `valueFrom.secretKeyRef.{name: {{ include "fdsc-dashboard.authSecretName" . }}, key: {{ .Values.auth.secretKey }}}`,
      followed by the `.Values.additionalEnvVars` passthrough (`toYaml | nindent 12`).
    - `resources: {{ toYaml .Values.deployment.resources | nindent 12 }}`.
    - `volumeMounts` block honouring `.Values.deployment.additionalVolumeMounts`.
  - `volumes` block honouring `.Values.deployment.additionalVolumes`.
  - `nodeSelector` / `affinity` / `tolerations` blocks, each guarded
    with `{{- with … }}`.

- **`templates/secret.yaml`** — renders an `Opaque` Secret named
  `{{ include "fdsc-dashboard.authSecretName" . }}` with a single data
  entry keyed by `.Values.auth.secretKey` whose value is
  `.Values.auth.config | toJson | b64enc` (so users supply native YAML
  and get valid JSON inside the Secret). The template is wrapped in
  `{{- if not .Values.auth.existingSecret }}` — when an existing Secret
  is supplied, no Secret resource is rendered. This reuses the common
  `secret.tpl` helper where it fits; falls back to a local body if the
  library helper's data-shape does not line up.

- **`templates/service.yaml`** — one-liner delegation to
  `common.service.tpl` (see `charts/mintaka/templates/service.yaml`),
  passing `service: .Values.service`, `ports: [{ port: .Values.service.port, targetPort: .Values.port }]`.

- **`templates/serviceaccount.yaml`** — one-liner delegation to
  `common.serviceaccount.tpl`.

- **`templates/ingress.yaml`** — one-liner delegation to
  `common.ingress.tpl`, passing `ingress: .Values.ingress`,
  `servicePort: .Values.service.port`.

- **`templates/route.yaml`** — one-liner delegation to `common.route.tpl`,
  passing `route: .Values.route`, `servicePort: .Values.service.port`.

- **`templates/deployment-hpa.yaml`** — one-liner delegation to
  `common.hpa.tpl`, targeting the deployment name and consuming
  `.Values.autoscaling`.

- **`templates/NOTES.txt`** — short post-install message with the
  service DNS and (if ingress enabled) the first host URL, mirroring
  `charts/mintaka/templates/NOTES.txt`.

**Files created**
- `charts/fdsc-dashboard/templates/_helpers.tpl`
- `charts/fdsc-dashboard/templates/deployment.yaml`
- `charts/fdsc-dashboard/templates/secret.yaml`
- `charts/fdsc-dashboard/templates/service.yaml`
- `charts/fdsc-dashboard/templates/serviceaccount.yaml`
- `charts/fdsc-dashboard/templates/ingress.yaml`
- `charts/fdsc-dashboard/templates/route.yaml`
- `charts/fdsc-dashboard/templates/deployment-hpa.yaml`
- `charts/fdsc-dashboard/templates/NOTES.txt`

**Acceptance criteria**
- `helm lint charts/fdsc-dashboard` exits zero with no warnings.
- `helm template charts/fdsc-dashboard` renders every enabled resource
  (Deployment, Service, Secret, ServiceAccount) without errors with the
  defaults in `values.yaml`.
- `helm template charts/fdsc-dashboard --set ingress.enabled=true --set ingress.hosts[0].host=dashboard.example.org --set 'ingress.hosts[0].paths[0]=/' --set route.enabled=true --set autoscaling.enabled=true --set serviceAccount.create=true`
  additionally renders Ingress, Route, HPA and ServiceAccount resources.
- `helm template charts/fdsc-dashboard --set auth.existingSecret=my-preexisting-secret`
  suppresses the chart-rendered Secret and the Deployment's env var
  references the external secret.
- The rendered Deployment's `AUTH_CONFIG_JSON` env var resolves to the
  JSON from `.Values.auth.config` via the Secret.

---

### Step 3: README + kubeconform validation + root README index update

Finalise the chart and wire it into the repo-level validation.

- **`charts/fdsc-dashboard/README.md`** — short, human-readable
  description of the chart (what it installs, quick-start `helm install`
  invocation, link to upstream). The bulk of the document is a
  values table; generate the initial draft via
  `helm-docs charts/fdsc-dashboard` if `helm-docs` is available in the
  container, otherwise hand-author the table following the format used
  by `charts/mintaka/README.md`. The table must document every key in
  `values.yaml` — especially calling out that the `apiUrls.*` values are
  **build-time** and therefore only useful in combination with a
  custom-built image (and surfaced via `additionalEnvVars` if ever
  rebuilt to read them at runtime).

- **Root `README.md`** — add `fdsc-dashboard` to the alphabetised chart
  list (matching the style used for `fdsc-edc`, which sits immediately
  before it alphabetically).

- **Validation** — run the repo-level scripts to confirm the new chart
  does not regress the monorepo:
  - `./build.sh` — `helm dependency update` for every chart, including
    the new one.
  - `./lint.sh` — `helm lint` for every chart; must exit zero.
  - `./eval.sh` — `helm template | kubeconform -strict
    -ignore-missing-schemas` for every chart (rendering the chart with
    defaults plus an ingress / route / HPA enabled override); must exit
    zero.
  - Install `kubeconform` via `curl … | tar xz …` if it is not already
    on `$PATH` in the container.

- **Fixture coverage (optional but preferred)** — add a `tests/` dir
  under `charts/fdsc-dashboard/` with a couple of `kubeconform` fixture
  overrides (default values, ingress+route+HPA+custom-secret) to catch
  template regressions. Only add this if the chart's rendering surface
  is non-trivial enough to warrant it; otherwise rely on `./eval.sh`.

**Files created / modified**
- `charts/fdsc-dashboard/README.md` (new).
- `README.md` (root) — one-line addition to the chart index.
- Optional: `charts/fdsc-dashboard/tests/*.yaml`.

**Acceptance criteria**
- `./build.sh && ./lint.sh && ./eval.sh` all exit zero on a clean
  checkout.
- `helm package charts/fdsc-dashboard` produces a `.tgz` that bundles
  the `common` library chart.
- Artifact Hub / `helm show readme charts/fdsc-dashboard` displays the
  values table.
- The root README lists `fdsc-dashboard` alongside every other chart.
