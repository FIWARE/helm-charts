#!/bin/bash

values_file=${1:-values.yaml}
helm  upgrade --dry-run --debug --cleanup-on-fail --install test-service fiware/coatrack -n synofit --values $values_file --set deployments[0].image.tag=1.0