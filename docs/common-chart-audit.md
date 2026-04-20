# Common Chart Audit — Duplication Baseline

This document is the machine-readable inventory produced in Step 1 of the
`common` library chart initiative (see `IMPLEMENTATION_PLAN.md`). It captures,
for every chart currently in `charts/`, the helper surface, the template
files rendered, and the chart-specific deviations that later steps must
preserve.

Canonical references used throughout:

- `charts/orion/templates/_helpers.tpl` — reference implementation of
  `name` / `fullname` / `chart` / `serviceAccountName` / `labels` /
  `secretName` / `secretKey`.
- `charts/keyrock/templates/_helpers.tpl` — reference implementation of
  `existingSecret`-based `secretName` and the chart-specific
  `certSecretName` (with a `-certs` suffix).

A helper is described as "canonical" below when its body is byte-identical
to the matching helper in one of those two files (modulo the chart-name
prefix).

Chart count: **26** (`charts/*` at the time of this audit — the repo
currently contains one chart more than the "25+" figure noted in
`CLAUDE.md`).

---

## Per-chart inventory

### api-umbrella

- **Helpers (`_helpers.tpl`):**
  - `api-umbrella.name` — canonical (orion).
  - `api-umbrella.fullname` — canonical (orion).
  - `api-umbrella.chart` — canonical (orion).
  - `api-umbrella.serviceAccountName` — canonical (orion).
  - `api-umbrella.labels` — canonical (orion).
  - `api-umbrella.mongoPassword` — **chart-specific**: `randAlphaNum 10`
    fallback for a generated MongoDB password.
- **Templates:** `_helpers.tpl`, `NOTES.txt`, `service.yaml`, `ingress.yaml`,
  `route.yaml`, `deployment.yaml`, `secret.yaml`, `serviceaccount.yaml`,
  `configmap.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `0.1.0`; appVersion `v0.18.0`;
  no `kubeVersion`; no OpenShift annotation.
- **Deviations:** `mongoPassword` helper; legacy `apiVersion: v1`.

### apollo

- **Helpers:** `apollo.name|fullname|chart|serviceAccountName|labels` — all
  canonical (orion).
- **Templates:** `_helpers.tpl`, `NOTES.txt`, `service.yaml`, `ingress.yaml`,
  `route.yaml`, `route-certificate.yaml`, `deployment.yaml`,
  `deployment-hpa.yaml`, `serviceaccount.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `0.1.4`; appVersion `0.0.10`.
- **Deviations:** none; pure canonical pattern plus HPA and Route/cert.

### bae-activation-service

- **Helpers:** `bae-activation-service.name|fullname|chart|serviceAccountName|labels`
  — canonical (orion).
  - `bae-activation-service.fullhostname` — **chart-specific**: returns
    `<fullname>.<namespace>.svc.cluster.local:<port>`.
- **Templates:** `_helpers.tpl`, `NOTES.txt`, `service.yaml`, `ingress.yaml`,
  `route.yaml`, `deployment.yaml`, `secret.yaml`, `serviceaccount.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `0.1.2`; appVersion `0.0.3`.
- **Deviations:** `fullhostname` helper.

### business-api-ecosystem

- **Helpers:** multi-component. Base helpers:
  - `business-api-ecosystem.name|chart|namespace`.
  - `business-api-ecosystem.common.matchLabels` /
    `business-api-ecosystem.common.metaLabels` — shared label fragments.
  - `business-api-ecosystem.initContainer.*` — templated init containers
    (mysql/mongodb/apis/rss/charging).
  - Per component: `bizEcosystemApis.*`, `bizEcosystemRss.*`,
    `bizEcosystemChargingBackend.*`, `bizEcosystemLogicProxy.*` — each
    component defines its own `labels` / `matchLabels` / `fullname` /
    `serviceAccountName` / `fullhostname` / `hostnameonly` / `secretName`
    (and a few of them add `apiInitContainer`, `certSecretName`).
- **Templates:** `_helpers.tpl`, `NOTES.txt`, `role-binding.yaml`,
  `role-openshift.yaml`, `service-account.yaml`; per-component subdirectories
  `biz-ecosystem-apis/`, `biz-ecosystem-charging-backend/`,
  `biz-ecosystem-logic-proxy/`, `biz-ecosystem-rss/`.
- **Chart.yaml:** apiVersion `v2`; version `0.11.26`; appVersion `9.0.1`.
- **Deviations:** multi-component layout, no single `fullname`, uses
  `fromYaml` / `merge` for label composition, subdirectory organisation.

### canis-major

- **Helpers:** `canis-major.name|fullname|chart|serviceAccountName|labels`
  — canonical (orion).
  - `canis-major.secretName` — canonical (keyrock variant, with `existingSecret` + `tpl`).
- **Templates:** `_helpers.tpl`, `NOTES.txt`, `service.yaml`, `ingress.yaml`,
  `route.yaml`, `route-certificate.yaml`, `deployment.yaml`,
  `deployment-hpa.yaml`, `secret.yaml`, `serviceaccount.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `0.1.4`; appVersion `1.5.15`.
- **Deviations:** none relative to orion+keyrock helpers; ships route certificate.

### contract-management

- **Helpers:** `contract.name|fullname|chart|serviceAccountName|labels` —
  canonical (orion) **with a `contract` prefix** (not `contract-management`).
  - `contract.secretName` — database variant keyed on
    `database.existingSecret.enabled`.
  - `contract.passwordKey` — chart-specific key extractor.
- **Templates:** `_helpers.tpl`, `service.yaml`, `deployment.yaml`,
  `configmap.yaml`, `serviceaccount.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `3.5.18`; appVersion `3.3.7`.
- **Deviations:** prefix differs from chart name; no ingress/route/HPA/NOTES;
  DB-flavoured `secretName` / `passwordKey`.

### credentials-config-service

- **Helpers:** `ccs.name|fullname|chart|serviceAccountName|labels` — canonical
  with `ccs` prefix.
  - `ccs.secretName` + `ccs.passwordKey` — DB variant
    (`database.existingSecret.enabled`).
  - `ccs.app.config` — **chart-specific**: renders the full application YAML
    (datasources, dialects H2/PostgreSQL/MySQL).
- **Templates:** `_helpers.tpl`, `service.yaml`, `deployment.yaml`,
  `deployment-hpa.yaml`, `ingress.yaml`, `route.yaml`,
  `route-certificate.yaml`, `secret.yaml`, `serviceaccount.yaml`,
  `configmap.yaml`, `registration-cm.yaml`, `registration-job.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `2.5.2`; appVersion `3.4.2`.
- **Deviations:** prefix differs from chart name; embedded application
  config; registration Job; route certificate.

### did-helper

- **Helpers:** `did-helper.name|fullname|chart` — canonical (orion).
  - `did-helper.labels` — **modern variant**: delegates selector labels to
    `did-helper.selectorLabels`.
  - `did-helper.selectorLabels` — **chart-specific** (only `name` +
    `instance`, not seen in the orion/keyrock references).
- **Templates:** `_helpers.tpl`, `configmap.yaml`, `deployment.yaml`,
  `ingress.yaml`, `service.yaml`.
- **Chart.yaml:** apiVersion `v2`; type `application`; version `0.1.15`;
  appVersion `0.4.5`.
- **Deviations:** separate `selectorLabels`; no `serviceAccountName`; no
  route/secret/HPA.

### dsba-pdp

- **Helpers:** `dsba-pdp.name|fullname|chart|serviceAccountName|labels` —
  canonical (orion).
  - `dsba-pdp.secretName` — DB variant (`db.existingSecret`).
  - `dsba-pdp.ishareSecret` — **chart-specific**: `-ishare`-suffixed secret.
  - `dsba-pdp.ishareTrustedList` / `dsba-pdp.trustedVerifiers` —
    **chart-specific**: join-with-comma helpers over user-supplied arrays.
- **Templates:** `_helpers.tpl`, `NOTES.txt`, `service.yaml`,
  `deployment.yaml`, `secret.yaml`, `secret-ishare.yaml`,
  `serviceaccount.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `0.1.2`; appVersion `0.3.2`.
- **Deviations:** iSHARE-specific helpers and secondary secret template.

### dss-validation-service

- **Helpers:** `dss.name|fullname|chart|serviceAccountName|labels` —
  canonical (orion) with `dss` prefix.
  - `dss.secretName` + `dss.passwordKey` — DB variant.
- **Templates:** `_helpers.tpl`, `service.yaml`, `deployment.yaml`,
  `ingress.yaml`, `serviceaccount.yaml`, `keystore-secret.yaml`,
  `trustlist-config.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `0.0.19`; appVersion `0.0.1`.
- **Deviations:** prefix differs from chart name; keystore + trustlist
  templates; no generic `secret.yaml`/`route`/`HPA`.

### endpoint-auth-service

- **Helpers:** multi-component.
  - `endpointAuthService.name|fullname|chart|labels` — umbrella helpers.
  - Per component: `configService.*`, `ishare.*`, `sidecarInjector.*` —
    each defines `name` / `fullname` / `serviceAccountName` / `labels`.
- **Templates:** 29 files. Deployments:
  `deployment-config-service.yaml`, `deployment-ishare-auth-provider.yaml`,
  `deployment-sidecar-injector.yaml`, plus per-deployment HPAs for the
  first two. Services, ingresses and routes per component.
  Additional: `configmap{,-sidecar-injector}.yaml`, secrets, roles and
  bindings per component, `mutation-webhook-sidecar-injector.yaml`,
  `certificate-sidecar-injector.yaml`, `pvc-ishare.yaml`,
  `service-entry-ishare.yaml`, `NOTES.txt`.
- **Chart.yaml:** apiVersion `v1`; version `0.1.4`; appVersion `0.4.4`.
- **Deviations:** 3 deployable components; RBAC per component; Istio
  service entry; webhook + certificate; PVC.

### fdsc-edc

- **Helpers:** `fdsc-edc.name|fullname|chart|serviceAccountName|labels` —
  canonical (orion).
- **Templates:** `_helpers.tpl`, `service.yaml`, `deployment.yaml`,
  `ingress.yaml`, `serviceaccount.yaml`, `config-map.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `0.1.8`; appVersion `0.1.7`.
- **Deviations:** none; minimal template set.

### iotagent-json

- **Helpers:** `iota-json.name|fullname|chart|serviceAccountName|labels`
  — canonical (orion) with `iota-json` prefix (not the chart name).
- **Templates:** `_helpers.tpl`, `NOTES.txt`, `service.yaml`,
  `deployment.yaml`, `deployment-hpa.yaml`,
  `ingress-{amqp,mqtt,north,south}.yaml`,
  `secret-{keystone,mqtt,oauth2}.yaml`, `configmap.yaml`,
  `serviceaccount.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `0.1.2`; appVersion `1.14.0`.
- **Deviations:** prefix differs from chart name; four protocol-specific
  ingresses; three protocol-specific secrets.

### iotagent-ul

- **Helpers:** `iota-ul.name|fullname|chart|serviceAccountName|labels` —
  canonical (orion) with `iota-ul` prefix (not the chart name).
- **Templates:** `_helpers.tpl`, `NOTES.txt`, `service.yaml`,
  `deployment.yaml`, `deployment-hpa.yaml`,
  `ingress-{amqp,mqtt,north,south}.yaml`, `secret-{keystone,oauth2}.yaml`,
  `configmap.yaml`, `serviceaccount.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `0.1.2`; appVersion `1.14.0`.
- **Deviations:** prefix differs from chart name; multiple
  protocol-specific ingresses.

### ishare-satellite

- **Helpers:** `ishare-satellite.name|fullname|chart|serviceAccountName|labels`
  — canonical (orion).
  - `ishare-satellite.fullhostname` — **chart-specific**:
    `<fullname>.<namespace>.svc.cluster.local:<port>`.
- **Templates:** `_helpers.tpl`, `NOTES.txt`, `service.yaml`,
  `deployment.yaml`, `ingress.yaml`, `route.yaml`, `serviceaccount.yaml`,
  `configmap.yaml`, `certificate.yaml`.
- **Chart.yaml:** apiVersion `v2`; version `1.3.2`; appVersion `1.2.0`.
- **Deviations:** TLS `certificate.yaml`; `fullhostname` helper.

### keyrock

- **Helpers:** `keyrock.name|fullname|chart|serviceAccountName|labels` —
  canonical (matches orion).
  - `keyrock.secretName` — **reference implementation** of the keyrock
    variant: `.Values.existingSecret` (flat) with `tpl`, fallback to
    `fullname`.
  - `keyrock.certSecretName` — **chart-specific**: returns the
    `existingCertSecret` value (via `tpl`) or `<fullname>-certs`.
- **Templates:** `_helpers.tpl`, `NOTES.txt`, `service.yaml`,
  `statefulset.yaml`, `statefulset-hpa.yaml`, `ingress.yaml`,
  `route.yaml`, `secret.yaml`, `serviceaccount.yaml`, `pvc.yaml`,
  `certificate.yaml`, `cm-init-data.yaml`, `initdata-cm.yaml`,
  `post-hook-init-data.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `0.8.2`; appVersion `8.3.3`.
- **Deviations:**
  - Only chart using a `StatefulSet` (plus HPA variant targeting it).
  - Ingress still carries a `semverCompare ">=1.14-0"` branch that
    switches between `networking.k8s.io/v1` and `extensions/v1beta1`.
  - PVC, certificate, post-hook and init-data ConfigMaps.

### mintaka

- **Helpers:** `mintaka.name|fullname|chart|serviceAccountName|labels` —
  canonical (orion).
- **Templates:** `_helpers.tpl`, `NOTES.txt`, `service.yaml`,
  `deployment.yaml`, `deployment-hpa.yaml`, `ingress.yaml`, `route.yaml`,
  `secret.yaml`, `serviceaccount.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `0.4.2`; appVersion `0.0.5`.
- **Deviations:** none; clean canonical pattern with HPA.

### odrl-pap

- **Helpers:** `pap.name|fullname|chart|serviceAccountName|labels` —
  canonical (orion) with `pap` prefix (not the chart name).
  - `pap.secretName` + `pap.passwordKey` — DB variant.
- **Templates:** `_helpers.tpl`, `service.yaml`, `deployment.yaml`,
  `deployment-hpa.yaml`, `ingress.yaml`, `route.yaml`,
  `route-certificate.yaml`, `secret.yaml`, `serviceaccount.yaml`,
  `mapping-cm.yaml`, `rego-cm.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `2.9.1`; appVersion `1.4.3`.
- **Deviations:** prefix differs from chart name; Rego/mapping ConfigMaps.

### onboarding-portal

- **Helpers:** `onboarding.name|fullname|chart` — canonical with
  `onboarding` prefix (not the chart name).
  - `onboarding.labels` — modern variant delegating to `selectorLabels`.
  - `onboarding.selectorLabels` — **chart-specific** pattern.
- **Templates:** `_helpers.tpl`, `configmap.yaml`, `deployment.yaml`,
  `ingress.yaml`, `pvc.yaml`, `service.yaml`.
- **Chart.yaml:** apiVersion `v2`; type `application`; version `1.2.6`;
  appVersion `0.0.5`.
- **Deviations:** prefix differs from chart name; `selectorLabels`; PVC;
  no `serviceAccountName`/route/secret/HPA.

### orion

- **Helpers:** reference implementation. `orion.name|fullname|chart|serviceAccountName|labels|secretName|secretKey`
  — all bodies are used by the rest of the audit as canonical.
- **Templates:** `_helpers.tpl`, `NOTES.txt`, `service.yaml`,
  `deployment.yaml`, `deployment-hpa.yaml`, `ingress.yaml`, `route.yaml`,
  `secret.yaml`, `serviceaccount.yaml`, `deployment-mongo.yaml`,
  `service-mongo.yaml`, `initdata-cm.yaml`, `post-hook-initdata.yaml`,
  plus a `test/` directory.
- **Chart.yaml:** apiVersion `v2`; version `1.6.6`; appVersion `1.0.1`;
  `kubeVersion: '>= 1.19-0'`; annotation
  `charts.openshift.io/name: orion-ld`.
- **Deviations:** optional managed Mongo deployment + service; post-hook
  init-data; OpenShift-certified.

### scorpio-broker

- **Helpers:** multi-component. Base:
  - `scorpio-broker-dist.name|fullname|chart|selectorLabels|serviceAccountName`.
  - `scorpio-broker-dist.common.matchLabels` /
    `scorpio-broker-dist.common.metaLabels` — shared fragments used by all
    component label helpers.
  - Per component: `atContextServer`, `configServer`, `entityManager`,
    `gateway`, `eureka`, `historyManager`, `queryManager`,
    `registryManager`, `registrySubscriptionManager`, `subscriptionManager`
    — each has a `fullname`, `labels` and `matchLabels`.
- **Templates:** for every component:
  `<component>-deployment.yaml`, `<component>-service.yaml`,
  `<component>-hpa.yaml`, plus `eureka-node-port.yaml` and
  `scorpio-gateway-node-port-svc.yaml`.
- **Chart.yaml:** apiVersion `v2`; type `application`; version `0.2.0`.
- **Deviations:** distributed microservice chart with 11 components; no
  central deployment; no ingress (node-port services instead).

### scorpio-broker-aaio

- **Helpers:** `scorpioBroker-aaio.name|fullname|chart|serviceAccountName|labels`
  — canonical (orion).
  - `scorpioBroker-aaio.selectorLabels` — **chart-specific** modern variant.
  - `scorpioBroker-aaio.secretName` + `scorpioBroker-aaio.passwordKey`.
- **Templates:** `_helpers.tpl`, `service.yaml`, `deployment.yaml`,
  `hpa.yaml`, `ingress.yaml`, `secret.yaml`, `serviceaccount.yaml`.
- **Chart.yaml:** apiVersion `v2`; type `application`; version `0.4.12`.
- **Deviations:** all-in-one single-container counterpart to
  `scorpio-broker`; carries `selectorLabels`.

### tm-forum-api

- **Helpers:** `tmforum.name|fullname|chart|serviceAccountName|labels` —
  canonical (orion) with `tmforum` prefix (not the chart name).
- **Templates:** `_helpers.tpl`, `NOTES.txt`, `service.yaml`,
  `deployment.yaml`, `ingress.yaml`, `route.yaml`,
  `route-certificate.yaml`, `serviceaccount.yaml`, `envoy.yaml`,
  `envoy-service.yaml`, `envoy-configmap.yaml`, `deploy-all-in-one.yaml`.
- **Chart.yaml:** apiVersion `v2`; version `0.16.13`; appVersion `1.10.2`;
  `kubeVersion: '>= 1.19-0'`; annotation
  `charts.openshift.io/name: tm-forum-api`; redis dependency.
- **Deviations:** prefix differs from chart name; Envoy proxy sidecar with
  full static-resources ConfigMap; optional all-in-one deployment;
  OpenShift-certified.

### trusted-issuers-list

- **Helpers:** `til.name|fullname|chart|serviceAccountName|labels` —
  canonical (orion) with `til` prefix (not the chart name).
  - `til.serviceName` — **chart-specific** service-name helper.
  - `til.secretName` + `til.passwordKey` — DB variant.
  - `til.app.config` — **chart-specific** application-config renderer
    (same pattern as `ccs`).
- **Templates:** `_helpers.tpl`, `service.yaml`, `deployment.yaml`,
  `deployment-hpa.yaml`, `ingress.yaml`, `ingress-tir.yaml`,
  `route-til.yaml`, `route-til-certificate.yaml`, `route-tir.yaml`,
  `route-tir-certificate.yaml`, `secret.yaml`, `serviceaccount.yaml`,
  `til-configmap.yaml`, `initdata-cm.yaml`, `post-hook-initdata.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `0.16.2`; appVersion `0.8.1`.
- **Deviations:** hosts two logical services (TIL + TIR); per-service
  routes with certificates; application-config helper; init-data + post-hook.

### trusted-issuers-registry

- **Helpers:** `tir.name|fullname|chart|serviceAccountName|labels` —
  canonical (orion) with `tir` prefix (not the chart name).
- **Templates:** `_helpers.tpl`, `NOTES.txt`, `service.yaml`,
  `deployment.yaml`, `deployment-hpa.yaml`, `ingress.yaml`, `route.yaml`,
  `route-certificate.yaml`, `secret.yaml`, `serviceaccount.yaml`,
  `configmap.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `0.13.0`; appVersion `0.11.1`.
- **Deviations:** prefix differs from chart name; route certificate.

### vcverifier

- **Helpers:** `vcverifier.name|fullname|chart|serviceAccountName|labels`
  — canonical (orion).
- **Templates:** `_helpers.tpl`, `service.yaml`, `deployment.yaml`,
  `ingress.yaml`, `route.yaml`, `serviceaccount.yaml`, `certificate.yaml`,
  `configmap.yaml`, `configmap-templates.yaml`.
- **Chart.yaml:** apiVersion `v1`; version `4.8.0`; appVersion `6.10.2`.
- **Deviations:** cert-issuer `certificate.yaml`; extra credential template
  ConfigMap; no NOTES/HPA/secret.

---

## Summary matrix

### Helper presence across charts

Only charts that ship a `_helpers.tpl` file are counted (all 26 do).

| Helper                          | Charts implementing it                       | Notes                                                          |
| ------------------------------- | -------------------------------------------- | -------------------------------------------------------------- |
| `<chart>.name`                  | 26 / 26                                      | Always canonical (orion body).                                 |
| `<chart>.fullname`              | 24 / 26                                      | `business-api-ecosystem` and `scorpio-broker` replace it with per-component variants. |
| `<chart>.chart`                 | 26 / 26                                      | Always canonical.                                              |
| `<chart>.labels`                | 26 / 26                                      | Canonical body in 22; delegates to `selectorLabels` in `did-helper`, `onboarding-portal`, `scorpio-broker`, `scorpio-broker-aaio`. |
| `<chart>.selectorLabels`        | 4 / 26                                       | `did-helper`, `onboarding-portal`, `scorpio-broker`, `scorpio-broker-aaio`. |
| `<chart>.serviceAccountName`    | 24 / 26                                      | Missing in `did-helper`, `onboarding-portal`. Canonical body in all others. |
| `<chart>.secretName` (keyrock-style, single `existingSecret`) | 2 / 26       | `canis-major`, `keyrock`.                                      |
| `<chart>.secretName` (orion DB style, `broker.db.existingSecret`) | 1 / 26  | `orion`.                                                       |
| `<chart>.secretName` (`db.existingSecret` / `database.existingSecret.enabled`) | 8 / 26 | `contract-management`, `credentials-config-service`, `dsba-pdp`, `dss-validation-service`, `odrl-pap`, `scorpio-broker-aaio`, `trusted-issuers-list` (plus `orion` counted above). |
| `<chart>.passwordKey` / `secretKey` | 8 / 26                                    | Same set as the DB-style secret helpers (plus `orion.secretKey`). |
| `<chart>.certSecretName`        | 1 / 26                                       | `keyrock` (used by its TLS secret mount).                      |
| `<chart>.fullhostname`          | 3 / 26                                       | `bae-activation-service`, `ishare-satellite` (and a per-component variant in `business-api-ecosystem`). |
| Custom / chart-specific helpers | various                                      | `api-umbrella.mongoPassword`, `dsba-pdp.ishareSecret` / `.ishareTrustedList` / `.trustedVerifiers`, `til.serviceName` + `til.app.config`, `ccs.app.config`, `business-api-ecosystem.initContainer.*`. |

### Template-file presence

| Template                              | Charts with it | Notes                                                                   |
| ------------------------------------- | -------------: | ----------------------------------------------------------------------- |
| `service.yaml`                        |        23 / 26 | Missing from `business-api-ecosystem` (subdir), `contract-management`, `tm-forum-api` (uses `envoy-service.yaml` + a separate `service.yaml`). |
| `deployment.yaml`                     |        22 / 26 | Missing from `keyrock` (statefulset), `business-api-ecosystem` (subdir), `endpoint-auth-service` (per-component), `scorpio-broker` (per-component). |
| `statefulset.yaml` / `statefulset-hpa.yaml` | 1 / 26   | `keyrock` only.                                                         |
| `deployment-hpa.yaml`                 |        11 / 26 | `apollo`, `canis-major`, `credentials-config-service`, `iotagent-json`, `iotagent-ul`, `mintaka`, `odrl-pap`, `orion`, `trusted-issuers-list`, `trusted-issuers-registry`, plus `scorpio-broker-aaio` (`hpa.yaml`). |
| `ingress.yaml`                        |        18 / 26 | Optional.                                                               |
| `route.yaml`                          |        13 / 26 | OpenShift-specific.                                                     |
| `route-certificate.yaml`              |         6 / 26 | `apollo`, `canis-major`, `credentials-config-service`, `odrl-pap`, `tm-forum-api`, `trusted-issuers-registry` (plus two copies in `trusted-issuers-list`). |
| `serviceaccount.yaml`                 |        22 / 26 | Missing in `did-helper`, `onboarding-portal`, `vcverifier` (uses default), and `business-api-ecosystem` (which uses `service-account.yaml`). |
| `secret.yaml` / chart-specific secret |        16 / 26 | Various flavours (see per-chart sections).                              |
| `NOTES.txt`                           |        14 / 26 | Optional.                                                               |

### Workload kind

- `Deployment`-based (includes multi-deployment charts): 25 / 26.
- `StatefulSet`-based: 1 / 26 (`keyrock`).

### Chart architecture

- Single-component (one `Deployment` + helpers): 21 / 26.
- Multi-deployment within one chart: `endpoint-auth-service`,
  `tm-forum-api` (main + envoy proxy), `trusted-issuers-list` (TIL + TIR).
- Multi-component with per-component helpers: `business-api-ecosystem` (4),
  `scorpio-broker` (10 components).

### Chart.yaml format

- `apiVersion: v1`: 17 / 26 — api-umbrella, apollo, bae-activation-service,
  canis-major, contract-management, credentials-config-service, dsba-pdp,
  dss-validation-service, endpoint-auth-service, fdsc-edc, iotagent-json,
  iotagent-ul, keyrock, mintaka, odrl-pap, trusted-issuers-list,
  trusted-issuers-registry, vcverifier.
- `apiVersion: v2`: 9 / 26 — business-api-ecosystem, did-helper,
  ishare-satellite, onboarding-portal, orion, scorpio-broker,
  scorpio-broker-aaio, tm-forum-api.
- `kubeVersion: '>= 1.19-0'`: 2 / 26 (`orion`, `tm-forum-api`).
- OpenShift annotation `charts.openshift.io/name`: 2 / 26 (`orion`,
  `tm-forum-api`).

### Prefix conventions

Most charts namespace their helpers with the chart name. The following
charts instead use a short prefix (to be preserved by the migration to
avoid breaking any consumer that references `include "<prefix>.fullname"`):

- `contract-management` → `contract.*`
- `credentials-config-service` → `ccs.*`
- `dss-validation-service` → `dss.*`
- `iotagent-json` → `iota-json.*`
- `iotagent-ul` → `iota-ul.*`
- `odrl-pap` → `pap.*`
- `onboarding-portal` → `onboarding.*`
- `scorpio-broker` → `scorpio-broker-dist.*`
- `scorpio-broker-aaio` → `scorpioBroker-aaio.*`
- `tm-forum-api` → `tmforum.*`
- `trusted-issuers-list` → `til.*`
- `trusted-issuers-registry` → `tir.*`

---

## Centralisation candidates

Based on the presence matrix above, the following helpers are the
unambiguous candidates for the `common` library chart (i.e. byte-identical
or trivially-parameterised across the majority of charts):

1. `common.names.name` — replaces every `<chart>.name`.
2. `common.names.fullname` — replaces every `<chart>.fullname` (24
   charts today) and, via an optional `component` argument in Step 10,
   the per-component variants in `scorpio-broker` / `business-api-ecosystem`.
3. `common.names.chart` — replaces every `<chart>.chart`.
4. `common.labels.standard` — replaces every `<chart>.labels` whose body
   matches the orion reference (22 / 26).
5. `common.labels.matchLabels` — subsumes the four `selectorLabels`
   helpers (`did-helper`, `onboarding-portal`, `scorpio-broker`,
   `scorpio-broker-aaio`) and the shared `common.matchLabels` fragment in
   `business-api-ecosystem` / `scorpio-broker`.
6. `common.serviceAccount.name` — replaces every `<chart>.serviceAccountName`.
7. `common.secrets.name` — unifies:
   - orion's `broker.db.existingSecret` form,
   - keyrock's flat `existingSecret` form (and, with a `suffix` argument,
     keyrock's `certSecretName`),
   - the DB-flavoured `database.existingSecret.enabled` form used by
     `contract-management`, `credentials-config-service`, `dsba-pdp`,
     `dss-validation-service`, `odrl-pap`, `scorpio-broker-aaio`,
     `trusted-issuers-list`.
8. `common.secrets.key` — generalises `orion.secretKey` /
   `<chart>.passwordKey`.

The following templates are structurally uniform enough to migrate to
shared helpers returning the entire YAML body:

- `service.yaml` — 23 charts render nearly identical bodies.
- `serviceaccount.yaml` — 22 charts render the same 8-line body.
- `ingress.yaml` — 18 charts; the `keyrock` `semverCompare` branch is the
  only deviation and is already slated for removal (see "Breaking
  Changes").
- `route.yaml` — 13 charts.
- `deployment-hpa.yaml` — 11 charts (plus the hpa variant in
  `scorpio-broker-aaio` and the one in `keyrock`).
- `secret.yaml` — 11 charts share a trivial Opaque-secret body.

Non-candidates (kept in consumer charts):

- Any chart-specific helper (`mongoPassword`, `ishareTrustedList`,
  `app.config`, `serviceName`, `fullhostname`, `initContainer.*`,
  `trustedVerifiers`).
- Multi-component per-service helpers used by
  `business-api-ecosystem` / `endpoint-auth-service` — these will become
  thin wrappers over `common.names.fullname` with a `component` argument
  when we reach Step 10.
- Bespoke templates: `keyrock/pvc.yaml`, `tm-forum-api/envoy-*.yaml`,
  `orion/deployment-mongo.yaml`, `vcverifier/certificate.yaml`,
  `endpoint-auth-service/mutation-webhook-*`, policy ConfigMaps, etc.
