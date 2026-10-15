# orion changelog

## 1.7.0

### Breaking changes

1. `autoscaling.apiVersion` defaults to `v2`, `v2beta2` was removed in Kubernetes 1.26 (see #278), `kubeVersion` is now `>= 1.23-0`.
2. Embedded MongoDB `docker.io/mongo:8.0.32` (amd64 and arm64, see #415) instead of `quay.io/opencloudio/ibm-mongodb:4.0.24`.

### New features

1. **MongoDB connection URI for Orion >= 4.0.0**
   - `broker.db.uri` renders `<envPrefix>MONGO_URI` instead of the legacy connection variables
   (`MONGO_HOST`, `MONGO_REPLICA_SET`, `MONGO_USER`, `MONGO_AUTH_MECH`, `MONGO_SSL`, `MONGO_TIMEOUT`, `MONGO_AUTH_SOURCE`),
   which were removed in Orion 4.0.0.  
   The password is provided via `broker.db.auth.password` or `broker.db.existingSecret` and replaces `${PWD}` in the URI.
2. **`deployment.extraEnv`** - additional environment variables for the broker container.
3. **`deployment.topologySpreadConstraints`** - without `labelSelector` the pods of the release are selected.
4. **`deployment.podDisruptionBudget`** - optional PodDisruptionBudget (disabled by default).
5. **`test.image` / `initData.image`** - configurable images for the helm test and the init data job.

### Fixes

1. Environment variable values are always rendered as strings.
   Numeric values (e.g. `broker.httpTimeout`) produced invalid Deployments and
   boolean values (e.g. `broker.db.sslEnabled`, `broker.logging.relogAlarms`) failed the rendering.
2. Orion (`envPrefix: ORION_`): the readiness and liveness probes always succeeded (`echo ... && true > /tmp/healthcheck`),
   so broken pods were never restarted or removed from the service (see #276).
   They now use `GET /v2/entities?limit=1` (readiness, requires the database) and `GET /version` (liveness).
   The log based health check wrapper was removed, the broker is started with `contextBroker -fg`.
3. Orion (`envPrefix: ORION_`): Orion-LD only variables (`SOCKET_SERVICE`, `SOCKET_SERVICE_PORT`,
   `CACHED_CONTEXT_DIRECTORY`, `FORWARDING`, `MONGOCONLY`, `TROE*`) are no longer rendered,
   the metrics are scraped from `/metrics` of the API port and only when `broker.metrics.enabled` is `"true"`.
4. Orion (`envPrefix: ORION_`): `initData` uses the NGSIv2 endpoint `/v2/entities`,
   the init script exits with `exit` instead of `return`.
5. Embedded MongoDB: always a single replica with `Recreate` strategy
   (it previously used `deployment.replicaCount`/autoscaling, resulting in independent databases),
   working probes (`mongosh`, previously always successful).
6. The helm test fails on an unsuccessful request (`curl --fail`).
7. Orion (`envPrefix: ORION_`) with the embedded MongoDB: the connection is configured via `MONGO_URI`
   (`mongodb://<fullname>-mongo:<port>`), as `MONGO_HOST` was removed in Orion 4.0.0 and Orion never
   started listening. Requires Orion >= 3.12.0.

### Updates

1. Orion-LD `1.12.0` (`appVersion` was not updated since `1.0.1`).
2. Test image `docker.io/curlimages/curl:8.22.0` instead of `quay.io/opencloudio/curl:4.2.0-build.8`, the init data job uses the same image instead of the unpinned `alpine/curl`.
3. `broker.db.sslEnabled` documents the Orion/Orion-LD support (see #99).


## 1.6.7

### Breaking changes

1. **ServiceAccount resource name honours `.Values.serviceAccount.name`**
   — the legacy `templates/serviceaccount.yaml` hard-coded
   `metadata.name: {{ include "orion.fullname" . }}` and ignored
   `.Values.serviceAccount.name`. The new `common.serviceAccount.tpl`
   uses `common.serviceAccount.name`, which applies
   `.Values.serviceAccount.name` as an override (same helper that
   already drove `serviceAccountName` on the Deployment pod spec).
   Concretely, a release with `serviceAccount.create: true` and
   `serviceAccount.name: custom-sa` now renders a ServiceAccount named
   `custom-sa` instead of `<fullname>`.
