#!/bin/bash

wget "https://get.helm.sh/helm-v3.4.1-linux-amd64.tar.gz"
tar zxf helm-v3.4.1-linux-amd64.tar.gz
mkdir bin
mv linux-amd64/helm ./bin/helm
wget "https://github.com/instrumenta/kubeval/releases/download/0.15.0/kubeval-linux-amd64.tar.gz"
tar -C ./bin -xf ./kubeval-linux-amd64.tar.gz kubeval