#!/bin/bash

KUBECONFORM_VERSION="0.7.0"
wget "https://github.com/yannh/kubeconform/releases/download/v${KUBECONFORM_VERSION}/kubeconform-linux-amd64.tar.gz"
mkdir bin
tar -C ./bin -xf kubeconform-linux-amd64.tar.gz kubeconform