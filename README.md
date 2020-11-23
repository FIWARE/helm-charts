# Helm Repository for Fiware Components

![FIWARE Catalogue](https://nexus.lab.fiware.org/repository/raw/public/badges/chapters/cross-chapter.svg)
[![License: APGL](https://img.shields.io/github/license/FIWARE/iotagent-isoxml.svg)](https://opensource.org/licenses/AGPL-3.0)
[![Releases downloads](https://img.shields.io/github/downloads/fiware/helm-charts/total.svg)](https://github.com/fiware/helm-charts/releases)
[![Release Charts](https://github.com/fiware/helm-charts/workflows/Build/badge.svg)](https://github.com/fiware/helm-charts/commits/main)
[![Fiware](https://nexus.lab.fiware.org/repository/raw/public/badges/stackoverflow/fiware.svg)](https://stackoverflow.com/questions/tagged/fiware)
<br/>

Repository for providing [HELM Charts](https://helm.sh/) of [Fiware Components](https://github.com/FIWARE/catalogue). The charts can be install into
 [Kubernetes](https://kubernetes.io/) with [helm3](https://helm.sh/docs/) .

For further information, look into the individual chart-readme's.

## Add Repo

To make use of the charts, you may add the repository: 

```helm repo add fiware https://fiware.github.io/helm-charts```

## Install

After the repo is added all charts can be installed via:

```helm install <RELEASE_NAME> fiware/<CHART_NAME>```