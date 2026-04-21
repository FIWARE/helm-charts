#! /bin/bash

HELM_CMD=$(command -v helm)

# Define colors
GREEN="\033[1;32m"
BLUE="\033[1;34m"
RESET="\033[0m"
WHITE="\033[1;37m"
RED="\033[1;31m"

# Counters
failed_charts=()

CHARTS=./charts/*

# Fixture chart paths (relative to repo root) that are NOT first-class
# published charts and must be excluded from `helm lint`. They live
# under `charts/<chart>/tests/` so they are already below the `./charts/*`
# glob expansion, but we keep an explicit skip list in case a future
# refactor widens the glob (e.g. `find ./charts -name Chart.yaml`). Each
# entry is an absolute-from-repo path without a trailing slash.
SKIP_CHARTS=(
    "./charts/common/tests"
)

is_skipped() {
    local candidate="$1"
    for skip in "${SKIP_CHARTS[@]}"; do
        if [[ "$candidate" == "$skip" ]]; then
            return 0
        fi
    done
    return 1
}

for chart in $CHARTS; do
    if is_skipped "$chart"; then
        echo -e "${BLUE}[${chart}]${WHITE} ⇢ Skipping fixture (not a published chart)${RESET}"
        continue
    fi
    if helm lint "$chart"; then
        echo -e "${BLUE}[${chart}]${GREEN} ✔ Lint passed for $chart${RESET}"
    else
        echo -e "${BLUE}[${chart}]${RED} ✖ Lint failed for $chart${RESET}"
        failed_charts+=("$chart")
    fi
done

if [ ${#failed_charts[@]} -ne 0 ]; then
    echo -e "${RED} Charts that failed linting:${RESET}"
    for chart in "${failed_charts[@]}"; do
        echo -e "${RESET} - $chart${RESET}"
    done
    exit 1
fi