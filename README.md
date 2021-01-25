# Helm Repository for FIWARE Components

![FIWARE Catalogue](https://nexus.lab.fiware.org/repository/raw/public/badges/chapters/deployment-tools.svg)
[![License: MIT](https://img.shields.io/github/license/FIWARE/helm-charts.svg)](https://opensource.org/licenses/MIT)
[![Releases downloads](https://img.shields.io/github/downloads/fiware/helm-charts/total.svg)](https://github.com/fiware/helm-charts/releases)
[![Chart Test](https://github.com/FIWARE/helm-charts/workflows/Chart%20Test/badge.svg)](https://github.com/fiware/helm-charts/commits/main)
[![FIWARE](https://nexus.lab.fiware.org/repository/raw/public/badges/stackoverflow/fiware.svg)](https://stackoverflow.com/questions/tagged/fiware)
[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/fiware)](https://artifacthub.io/packages/search?repo=fiware)
<br/>

Repository for providing [HELM Charts](https://helm.sh/) of [FIWARE Components](https://github.com/FIWARE/catalogue). The charts can be install into
 [Kubernetes](https://kubernetes.io/) with [helm3](https://helm.sh/docs/) .

For further information, please look into the individual chart-readme's.

## Add Repo

To make use of the charts, you may add the repository: 

```console
helm repo add fiware https://fiware.github.io/helm-charts
```

## Install

After the repo is added all charts can be installed via:

```console
helm install <RELEASE_NAME> fiware/<CHART_NAME>
```

---

## License

[MIT](./LICENSE). © 2020-21 FIWARE Foundation e.V.
