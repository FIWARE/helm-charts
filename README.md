# Helm Repository for FIWARE Components

![FIWARE Catalogue](https://nexus.lab.fiware.org/repository/raw/public/badges/chapters/cross-chapter.svg)
[![License: APGL](https://img.shields.io/github/license/FIWARE/iotagent-isoxml.svg)](https://opensource.org/licenses/AGPL-3.0)
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

```helm repo add fiware https://fiware.github.io/helm-charts```

## Install

After the repo is added all charts can be installed via:

```helm install <RELEASE_NAME> fiware/<CHART_NAME>```

---

## License

The FIWARE Helm Charts are licensed under [Affero General Public License (GPL) version 3](./LICENSE).

© 2020 FIWARE Foundation e.V.

### Are there any legal issues with AGPL 3.0? Is it safe for me to use?

There is absolutely no problem in using a product licensed under AGPL 3.0. Issues with GPL (or AGPL) licenses are mostly
related with the fact that different people assign different interpretations on the meaning of the term “derivate work”
used in these licenses. Due to this, some people believe that there is a risk in just _using_ software under GPL or AGPL
licenses (even without _modifying_ it).

For the avoidance of doubt, the owners of this software licensed under an AGPL-3.0 license wish to make a clarifying
public statement as follows:

> Please note that software derived as a result of modifying the source code of this software in order to fix a bug or
> incorporate enhancements is considered a derivative work of the product. Software that merely uses or aggregates (i.e.
> links to) an otherwise unmodified version of existing software is not considered a derivative work, and therefore it
> does not need to be released as under the same license, or even released as open source.
