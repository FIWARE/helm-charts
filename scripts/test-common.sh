#!/usr/bin/env bash
#
# Render the `common` library chart's fixture consumer
# (`charts/common/tests`) and diff the rendered output against the
# committed golden files under `charts/common/tests/expected/`.
#
# Purpose
# -------
#   The `common` library chart (charts/common) is not installable on its
#   own — Helm refuses to render library charts directly. The fixture
#   chart at charts/common/tests is a minimal consumer that `include`s
#   every helper the library exposes, so we can render it with
#   deterministic values and compare against a known-good reference.
#
#   Any drift — a subtle change in a helper, a whitespace regression, a
#   reordered YAML field, or an accidental removal — will surface here
#   as a non-empty `diff`, and the script will exit non-zero so CI and
#   local pre-commit checks both fail loudly.
#
# Behaviour
# ---------
#   1. Run `helm dependency update` on the fixture chart so it picks up
#      the latest `charts/common` sources via its `file://..` dependency.
#   2. Render the fixture with `helm template` using the fixed release
#      name and namespace hard-coded below (they must stay in sync with
#      the names embedded in the golden files).
#   3. `diff -u` the rendered output against each expected/*.yaml file.
#   4. Emit a compact PASS/FAIL summary and exit with the number of
#      failing scenarios (0 == success).
#
# Usage
# -----
#   bash scripts/test-common.sh
#
# Requirements
# ------------
#   - `helm` v3+ on PATH (see .github/workflows/check.yml for the CI
#     version pin).
#   - `diff` (POSIX).
#
set -o errexit
set -o nounset
set -o pipefail

# --- Configuration constants -------------------------------------------------

# Repo root is the parent of this script's directory, regardless of
# where the script is invoked from.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Paths to the library chart, the fixture, and the golden directory.
readonly COMMON_CHART_DIR="${REPO_ROOT}/charts/common"
readonly FIXTURE_CHART_DIR="${COMMON_CHART_DIR}/tests"
readonly EXPECTED_DIR="${FIXTURE_CHART_DIR}/expected"

# The golden files under expected/ were generated with this release
# name and namespace — the full-name helper bakes both into rendered
# manifests, so these values must not drift from the fixture's
# golden output. See charts/common/tests/expected/default.yaml.
readonly FIXTURE_RELEASE_NAME="test-release"
readonly FIXTURE_NAMESPACE="test-ns"

# --- Colour helpers ----------------------------------------------------------

# Match the colour scheme used by lint.sh / eval.sh so local output is
# consistent across helper scripts.
readonly GREEN="\033[1;32m"
readonly BLUE="\033[1;34m"
readonly RED="\033[1;31m"
readonly WHITE="\033[1;37m"
readonly RESET="\033[0m"

log_info()  { echo -e "${BLUE}[common-tests]${RESET} ${WHITE}$*${RESET}"; }
log_pass()  { echo -e "${BLUE}[common-tests]${RESET} ${GREEN}✔ $*${RESET}"; }
log_fail()  { echo -e "${BLUE}[common-tests]${RESET} ${RED}✖ $*${RESET}"; }

# --- Preconditions -----------------------------------------------------------

HELM_CMD="$(command -v helm || true)"
if [[ -z "${HELM_CMD}" ]]; then
    log_fail "helm is not on PATH"
    exit 2
fi

if [[ ! -d "${FIXTURE_CHART_DIR}" ]]; then
    log_fail "fixture chart not found at ${FIXTURE_CHART_DIR}"
    exit 2
fi

if [[ ! -d "${EXPECTED_DIR}" ]] || ! compgen -G "${EXPECTED_DIR}/*.yaml" > /dev/null; then
    log_fail "no golden files under ${EXPECTED_DIR}/*.yaml"
    exit 2
fi

# --- 1. Refresh the fixture's dependency on charts/common -------------------

log_info "helm dependency update ${FIXTURE_CHART_DIR}"
"${HELM_CMD}" dependency update "${FIXTURE_CHART_DIR}" >/dev/null

# --- 2. Render the fixture ---------------------------------------------------

# Render into a tempfile so the diff output is easy to point callers at
# when a golden file drifts. The tempfile is cleaned up on any exit.
RENDERED_OUTPUT="$(mktemp)"
trap 'rm -f "${RENDERED_OUTPUT}"' EXIT

log_info "helm template ${FIXTURE_RELEASE_NAME} ${FIXTURE_CHART_DIR} --namespace ${FIXTURE_NAMESPACE}"
"${HELM_CMD}" template "${FIXTURE_RELEASE_NAME}" "${FIXTURE_CHART_DIR}" \
    --namespace "${FIXTURE_NAMESPACE}" \
    > "${RENDERED_OUTPUT}"

# --- 3. Diff against each golden file ---------------------------------------

failed_scenarios=()

# Each expected/*.yaml file is an independent scenario. Today the
# fixture renders a single multi-document YAML stream and there is a
# single scenario file (default.yaml), but the loop is written so
# additional scenarios (e.g. expected/component.yaml for the
# scorpio-broker multi-component case added in Step 10) can be dropped
# in without touching this script.
for expected_file in "${EXPECTED_DIR}"/*.yaml; do
    scenario_name="$(basename "${expected_file}" .yaml)"
    if diff -u "${expected_file}" "${RENDERED_OUTPUT}"; then
        log_pass "scenario '${scenario_name}' matches golden output"
    else
        log_fail "scenario '${scenario_name}' diverges from ${expected_file}"
        failed_scenarios+=("${scenario_name}")
    fi
done

# --- 4. Summarise ------------------------------------------------------------

if [[ ${#failed_scenarios[@]} -ne 0 ]]; then
    log_fail "${#failed_scenarios[@]} scenario(s) failed: ${failed_scenarios[*]}"
    echo
    echo "To refresh the golden file after an intentional change, run:"
    echo "  helm dependency update ${FIXTURE_CHART_DIR}"
    echo "  helm template ${FIXTURE_RELEASE_NAME} ${FIXTURE_CHART_DIR} \\"
    echo "    --namespace ${FIXTURE_NAMESPACE} \\"
    echo "    > ${EXPECTED_DIR}/<scenario>.yaml"
    exit 1
fi

scenario_count=$(find "${EXPECTED_DIR}" -maxdepth 1 -name '*.yaml' -type f | wc -l)
log_pass "all ${scenario_count} scenario(s) matched — common chart helpers are on-spec"
exit 0
