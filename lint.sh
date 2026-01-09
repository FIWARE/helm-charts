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

for chart in $CHARTS; do
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