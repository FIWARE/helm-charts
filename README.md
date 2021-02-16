# Helm Repository for Catalogue<img src="https://fiware.github.io//catalogue/img/fiware-black.png" width="145" align="left">  Components

![FIWARE Catalogue](https://nexus.lab.fiware.org/repository/raw/public/badges/chapters/deployment-tools.svg)
[![License: MIT](https://img.shields.io/github/license/FIWARE/helm-charts.svg)](https://opensource.org/licenses/MIT)
[![FIWARE](https://nexus.lab.fiware.org/repository/raw/public/badges/stackoverflow/fiware.svg)](https://stackoverflow.com/questions/tagged/fiware)
<br/>
[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/fiware)](https://artifacthub.io/packages/search?repo=fiware)
[![Chart Test](https://github.com/FIWARE/helm-charts/workflows/Chart%20Test/badge.svg)](https://github.com/fiware/helm-charts/commits/main)
[![Releases downloads](https://img.shields.io/github/downloads/fiware/helm-charts/total.svg)](https://github.com/fiware/helm-charts/releases)


Repository for providing [HELM Charts](https://helm.sh/) of Generic Enablers from the [FIWARE Catalogue](https://github.com/FIWARE/catalogue). The 
charts can be install into  [Kubernetes](https://kubernetes.io/) with [helm3](https://helm.sh/docs/).

FIWARE is a curated framework of open source platform components which can be assembled together and with other third-party platform components to
accelerate the development of Smart Solutions. The main and only mandatory component of any “Powered by FIWARE” platform or solution is a 
[FIWARE Context Broker](https://github.com/FIWARE/catalogue/blob/master/core/README.md) Generic Enabler, bringing a cornerstone function in any smart 
solution: the need to manage context information, enabling to perform updates and bring access to context.

Note that FIWARE is not about take it all or nothing. With the exception of a mandatory FIWARE Context Broker you should feel free to 
mix [FIWARE Catalogue](https://github.com/FIWARE/catalogue) elements with other open-source and commercial third-party platform components to 
design the hybrid platform of your choice. As long as it uses the FIWARE Context Broker technology to manage context information, your platform 
can be labeled as _“Powered by FIWARE”_  and other solutions can build on top of it as well. Listings of many _FIWARE Ready_ software enablers
and devices and commercial _“Powered by FIWARE”_ solutions can be found on the [FIWARE Marketplace](http://marketplace.fiware.org/).

For additional Helm Charts collections for supplementary open-source components such as Grafana, Apache Spark, Keycloak and Kong we recommend other 
community-maintained listings such as [Bitnami](https://github.com/bitnami/charts/tree/master/bitnami) or [Orchestra Cities](https://github.com/orchestracities/charts)
or searching for a specific helm chart on [Artifact Hub](https://artifacthub.io/packages/search?page=1&kind=0) 

More information on each individual FIWARE component, can be found within the individual chart READMEs.

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
