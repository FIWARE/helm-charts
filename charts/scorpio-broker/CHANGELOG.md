# scorpio-broker changelog

## 0.3.0

### Common library chart migration

The chart now depends on the local `common` library chart
(`charts/common`, introduced in ticket-9 steps 1–6). Every helper and
every per-component Service / NodePort Service / HorizontalPodAutoscaler
that was previously duplicated in this chart is now a thin `include` of
the matching `common.*` helper. The work was split into four
implementation steps (this is step 5):

- **Step 1 — `templates/_helpers.tpl` rewrite.** `scorpio-broker.name`,
  `scorpio-broker.fullname`, `scorpio-broker.chart`,
  `scorpio-broker.serviceAccountName`, `scorpio-broker.labels`,
  `scorpio-broker.matchLabels` and the per-component variants
  (`scorpio-broker.<component>.fullname` /
  `scorpio-broker.<component>.labels` /
  `scorpio-broker.<component>.matchLabels`) now delegate to
  `common.names.*`, `common.serviceAccount.name`,
  `common.labels.standard` and `common.labels.matchLabels`. The
  `<chart>.*` names are preserved so the per-component Deployment
  bodies (which were intentionally **not** migrated — see "Out of
  scope" below) keep working as thin wrappers.
- **Step 2 — per-component Services.** The 10 component
  `<component>-service.yaml` files
  (`atcontext-server-service.yaml`, `config-server-service.yaml`,
  `entity-manager-service.yaml`, `eureka-service.yaml`,
  `gateway-service.yaml`, `history-manager-service.yaml`,
  `query-manager-service.yaml`, `registration-manager-service.yaml`,
  `registration-subscription-manager-service.yaml`,
  `subscription-manager-service.yaml`) are now thin calls to
  `common.service.tpl`.
- **Step 3 — extra NodePort Services.** The two NodePort-only
  Services (`eureka-node-port.yaml` and
  `scorpio-gateway-node-port-svc.yaml`) are now thin calls to
  `common.service.tpl` as well.
- **Step 4 — per-component HPAs.** The 10 component
  `<component>-hpa.yaml` files
  (`atcontext-server-hpa.yaml`, `config-server-hpa.yaml`,
  `entity-manager-hpa.yaml`, `eureka-server-hpa.yaml`,
  `gateway-server-hpa.yaml`, `history-manager-hpa.yaml`,
  `query-manager-hpa.yaml`, `registration-manager-hpa.yaml`,
  `registration-subscription-manager-hpa.yaml`,
  `subscription-manager-hpa.yaml`) are now thin calls to
  `common.hpa.tpl`. The per-component `hpa:` values block was
  restructured to `autoscaling:` to match the helper's contract
  (see "Breaking changes" below).
- **Chart.yaml** — `apiVersion` was already v2; `version` bumped
  `0.2.0` → `0.3.0` (minor bump signalling the added dependency and
  the breaking deltas). `appVersion` stays at `2.1.0` (the scorpio
  image tags are unchanged). Added the `common` entry under
  `dependencies` (resolved via a `file://../common` reference).
- **`.gitignore`** — present from earlier steps; excludes the
  resolved `Chart.lock` and the `charts/` sub-directory
  (`common-<version>.tgz` is pulled in by `helm dependency update`
  on install / publish and does not need to live in git).

#### Out of scope

- The 10 per-component Deployment bodies
  (`<component>-deployment.yaml` and `history-manager-development.yaml`)
  are **not** migrated. `docs/common-chart.md` explicitly lists
  Deployments as a non-goal of the library — they contain
  scorpio-specific container / env / probe configuration that has no
  counterpart in the `common` helper surface. The Deployments
  continue to reference `<chart>.*.fullname` / `<chart>.*.labels` /
  `<chart>.*.matchLabels`, which are now wrappers around the common
  helpers.
- No top-level `templates/serviceaccount.yaml` is introduced.
  scorpio-broker ships no top-level ServiceAccount today (per-component
  `serviceAccount.enabled/name` values pass through to each
  Deployment's pod spec). Adding one is a separate feature outside
  the scope of this migration.

### Breaking changes

1. **Selector and label schema aligned with the rest of FIWARE.**
   The legacy scorpio label set
   (`app`, `release`, `component`, `chart`, `heritage`) is replaced
   with the canonical
   `app.kubernetes.io/{name,instance,component,version,managed-by}` +
   `helm.sh/chart` set emitted by `common.labels.standard` /
   `common.labels.matchLabels`. The per-component
   `app.kubernetes.io/component: <component>` line is added via the
   helpers' `component` argument.

   This applies to **all** rendered manifests, including the 10
   per-component Deployment bodies that were not migrated — the
   Deployments reference the now-rewritten
   `<chart>.<component>.labels` / `.matchLabels` helpers, so their
   `metadata.labels`, `spec.selector.matchLabels` and
   `spec.template.metadata.labels` blocks change in lock-step with
   the Service and HPA manifests.

   Because Deployment `spec.selector` is immutable, **in-place
   `helm upgrade` of a pre-`0.3.0` release is not supported.**
   Operators must either uninstall and reinstall (preferred — see
   "Upgrade path" below) or pin the pre-migration chart version
   (`0.2.0`) until they can take a maintenance window.

2. **Per-component `hpa:` values block renamed to `autoscaling:`**
   with the v2 `metrics:` list shape. The legacy
   per-component `<component>-hpa.yaml` templates hard-coded
   `autoscaling/v1` with `spec.targetCPUUtilizationPercentage`.
   `common.hpa.tpl` emits
   `autoscaling/{{ default "v2" $autoscaling.apiVersion }}` with a
   `spec.metrics:` list. The default reproduces the legacy v1
   HPA's 80% CPU target as a v2 `Resource` / `cpu` / `Utilization`
   metric.

   Before (`0.2.0`):

   ```yaml
   eureka:
     hpa:
       enabled: true
       minReplicas: 1
       maxReplicas: 5
       targetCPUUtilizationPercentage: 80
   ```

   After (`0.3.0`):

   ```yaml
   eureka:
     autoscaling:
       enabled: true
       apiVersion: "v2beta2"
       minReplicas: 1
       maxReplicas: 5
       metrics:
         - type: Resource
           resource:
             name: cpu
             target:
               type: Utilization
               averageUtilization: 80
   ```

   Users on Kubernetes < 1.23 (which removed `autoscaling/v2beta2`)
   can keep `apiVersion: "v2beta1"` / `"v2beta2"`; users on 1.26+
   may wish to override it to `"v2"`. The same restructure applies
   to all 10 components
   (`eureka`, `gateway`, `config-server`, `entity-manager`,
   `query-manager`, `registration-manager`,
   `registration-subscription-manager`, `subscription-manager`,
   `history-manager`, `atcontext-server`).

3. **Explicit `metadata.namespace` on Service and HPA manifests.**
   All 12 Services (10 component + 2 NodePort) and all 10 HPAs now
   carry an explicit `metadata.namespace` field (taken from
   `.Release.Namespace`). This matches the convention used by every
   other FIWARE chart. It does not change where the resources are
   deployed; it only makes the namespace visible in the rendered
   manifest.

4. **HPA resource name drops the `-hpa` suffix.** The legacy
   per-component `<component>-hpa.yaml` templates emitted
   `metadata.name: {{ template "<chart>.<component>.fullname" . }}-hpa`.
   `common.hpa.tpl` uses `common.names.fullname` directly, dropping
   the suffix. The HPA for the `eureka` component (for example) is
   now named `<release>-scorpio-broker-eureka` instead of
   `<release>-scorpio-broker-eureka-hpa`. `helm upgrade` will
   delete the old HPA and create the new one; this has no impact
   on running pods because HPAs are control-plane controllers, not
   workload owners.

### Non-breaking cosmetic changes to rendered output

- The blank leading line inside the labels block (a side-effect of
  the legacy `{{ include "<chart>.<component>.labels" . | nindent 4 }}`
  pattern) is gone from the Service and HPA manifests — the common
  helpers emit labels without a leading blank. Deployment manifests
  still carry the blank line because their bodies were not migrated.
- Service `spec.type` is now always emitted (the legacy template
  omitted it for ClusterIP defaults; `common.service.tpl` writes
  `type: ClusterIP` explicitly). YAML-equivalent.
- Service `spec.ports[]` items are indented by 4 spaces rather than
  2, always carry `protocol: TCP`, and always carry a `name` field
  (previously omitted on the two NodePort Services). YAML-equivalent.
- HPA `spec.scaleTargetRef` and `spec.metrics` use the canonical
  2-space + 4-space indentation rather than the legacy 1-space +
  3-space layout. YAML-equivalent.
- HPA manifests now carry a `metadata.labels` block. The legacy
  `<component>-hpa.yaml` templates emitted no labels at all on the
  HPA resource. The added labels follow the canonical FIWARE set
  (item 1 under "Breaking changes") but, because the legacy block
  was empty, the addition itself is purely additive — no existing
  selector or matcher relied on its absence.

All of the above are cosmetic and do not alter the runtime behaviour
of any resource.

### Upgrade path

In-place `helm upgrade` from `0.2.0` to `0.3.0` is **not supported**
because Deployment `spec.selector.matchLabels` is immutable in
Kubernetes and the selector / label schema has changed (see Breaking
change 1).

Recommended migration:

1. Note any per-component overrides (`replicas`, `image.tag`,
   `resources`, `hpa.targetCPUUtilizationPercentage`, …) currently in
   use. Translate the `hpa:` keys to the new `autoscaling:` shape
   per Breaking change 2.
2. `helm uninstall <release>` the pre-migration release.
3. `helm install <release> fiware/scorpio-broker --version 0.3.0`
   with the translated values.

If a maintenance window is not yet possible, pin the chart at
`0.2.0` until one is.

No data migration is required — the scorpio-broker components are
stateless from the chart's perspective; any backing Postgres /
Kafka / Zookeeper instances are managed by their own charts and
are unaffected.
