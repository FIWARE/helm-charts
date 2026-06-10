# Implementation Plan: Add charts as OCI artifacts to quay.io

## Overview

Create a GitHub Actions workflow that publishes all FIWARE Helm charts as OCI artifacts
to `quay.io/fiware/helm-charts/<chart-name>` on every push to `main`. This is purely
additive — the existing GitHub Pages publishing via `chart-releaser-action` in
`deploy.yml` remains untouched.

## Steps

### Step 1: Create the OCI publish GitHub Actions workflow

**Goal:** Add a new workflow file `.github/workflows/oci-publish.yml` that packages and
pushes every chart to the quay.io OCI registry whenever a commit lands on `main`.

**File to create:** `.github/workflows/oci-publish.yml`

**Workflow specification:**

- **Trigger:** `on: push: branches: [main]` (same trigger as `deploy.yml`).
- **Runner:** `ubuntu-latest`.
- **Environment variable:** `HELM_VERSION: "4.0.4"` (matches `check.yml` for consistency).
- **Steps:**
  1. `actions/checkout@v3` — check out the repository.
  2. `azure/setup-helm@v4` — install Helm at the pinned version.
  3. **Login to quay.io** — run `helm registry login quay.io --username … --password …`
     using two repository secrets: `QUAY_USERNAME` and `QUAY_PASSWORD`. These are
     expected to be configured in the GitHub repo settings for a quay.io robot account
     with push access to the `quay.io/fiware/helm-charts` namespace. The workflow
     references them as `${{ secrets.QUAY_USERNAME }}` and `${{ secrets.QUAY_PASSWORD }}`.
  4. **Update chart dependencies** — run `./build.sh` so that charts with sub-chart
     dependencies (e.g., `tm-forum-api` depending on `redis` from Bitnami OCI, and all
     charts depending on `common`) are fully resolved before packaging.
  5. **Package and push every chart** — iterate over `charts/*/` and, for each directory
     that contains a `Chart.yaml`:
     - Read the chart name and version from `Chart.yaml` using `yq` or `grep`/`awk`.
     - Run `helm package charts/<chart-name>` to produce `<name>-<version>.tgz`.
     - Run `helm push <name>-<version>.tgz oci://quay.io/fiware/helm-charts`.
     - **Handle already-existing versions:** quay.io returns an error if the exact
       tag already exists. The script must catch this gracefully (log a warning and
       continue) so that unchanged charts do not fail the entire workflow. Use
       `|| echo "Already exists or push failed for <chart-name>, skipping"` or
       check the exit code and only fail on unexpected errors.
     - **Library charts:** The `common` chart (`type: library`) **should** be pushed.
       Library charts are valid OCI artifacts and consumer charts may reference them
       as OCI dependencies in the future. There is no need to skip them.
  6. **Cleanup** — `helm registry logout quay.io`.

**Design decisions:**

- Push **all** charts on every `main` push, not only changed ones. The `helm push`
  call for an already-existing version is a harmless no-op (after error handling).
  This avoids the complexity of diffing chart versions in CI and ensures the OCI
  registry is always in sync with the repository.
- Do **not** modify `deploy.yml`. The two workflows run independently on the same
  trigger.
- Use `yq` (installed via `actions/setup-go` + `go install`) for robust YAML parsing
  of `Chart.yaml` fields (name, version, type), consistent with the existing
  `check-chart-updates.yml` workflow.

**Secrets required (configured outside this repo, in GitHub repo settings):**

| Secret            | Description                                          |
|-------------------|------------------------------------------------------|
| `QUAY_USERNAME`   | quay.io robot account username (e.g., `fiware+ci`)   |
| `QUAY_PASSWORD`   | quay.io robot account token / password               |

**Acceptance criteria:**

- `.github/workflows/oci-publish.yml` exists and is valid YAML.
- The workflow triggers on push to `main`.
- All 28 charts (27 application + 1 library) are iterated, packaged, and pushed.
- Already-existing versions do not cause a workflow failure.
- `deploy.yml` is not modified.
- `./lint.sh` passes without errors (no chart breakage introduced).
- `helm lint` and `helm template` on a sample chart (e.g., `orion`) still succeed.

### Step 2: Add OCI consumer documentation and verify CI compatibility

**Goal:** Document how consumers can pull and install charts from the quay.io OCI
registry, and verify that all existing CI scripts (`lint.sh`, `eval.sh`, `build.sh`)
still pass without modification.

**Files to modify/create:**

- **`README.md`** (repo root) — add a section describing OCI availability. If no
  root-level `README.md` exists, create one; otherwise append to the existing file.

**Documentation content to add:**

```markdown
## OCI Registry (quay.io)

All charts are also published as OCI artifacts to quay.io. To pull or install
a chart from the OCI registry:

### Pull a chart archive

    helm pull oci://quay.io/fiware/helm-charts/<chart-name> --version <version>

### Install directly from OCI

    helm install my-release oci://quay.io/fiware/helm-charts/<chart-name> --version <version>

### Example

    helm install orion oci://quay.io/fiware/helm-charts/orion --version 1.6.11

### Available charts

All charts published to https://fiware.github.io/helm-charts are also available
in the OCI registry at `oci://quay.io/fiware/helm-charts/<chart-name>`.
```

**Verification tasks (run, not committed):**

- Run `./lint.sh` — must exit 0.
- Run `./build.sh` — must complete without errors.
- Run `helm package charts/orion` and `helm package charts/keyrock` — must produce
  valid `.tgz` files.
- Confirm `deploy.yml` has not been modified (`git diff .github/workflows/deploy.yml`
  shows no changes).

**Acceptance criteria:**

- The repository README includes OCI pull/install instructions.
- All existing CI scripts pass without modification.
- `deploy.yml` is unchanged.
- The OCI instructions reference the correct registry path:
  `oci://quay.io/fiware/helm-charts/<chart-name>`.
