#!/bin/bash

CHARTS=./charts/*
HELM_CMD=$(command -v helm)

for chart in $CHARTS; do
    $HELM_CMD dependency update "$chart"
done