#!/bin/bash

# Fail the script if any command in a pipe fails
set -o pipefail

HELM_CMD=$(command -v helm)
KC_CMD=$(command -v kubeconform || echo "./bin/kubeconform")

# Define colors
GREEN="\033[1;32m"
BLUE="\033[1;34m"
RESET="\033[0m"
WHITE="\033[1;37m"
RED="\033[1;31m"

CHARTS=$(pwd)/charts/*

failed_charts=()

for chart in $CHARTS
do
    echo -e "${BLUE}[$(basename $chart)]${RESET} ${WHITE}Validating chart${RESET}"

    $HELM_CMD template "${chart}" | $KC_CMD -strict -ignore-missing-schemas
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo -e "${BLUE}[$(basename $chart)]${RESET} ${GREEN}✔ ${WHITE}Success${RESET}\n"
    else
        echo -e "${BLUE}[$(basename $chart)]${RESET} ${RED}✖ Failed${RESET}\n"
        failed_charts+=("$(basename $chart)")
    fi
done

if [ ${#failed_charts[@]} -ne 0 ]; then
    echo -e "${RED}Some charts failed validation:${RESET}"
    for f in "${failed_charts[@]}"; do
        echo -e "  - ${RED}$f${RESET}"
    done
    exit 1
else
    echo -e "${GREEN}All charts validated successfully!${RESET}"
    exit 0
fi