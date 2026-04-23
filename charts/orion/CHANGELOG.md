# orion changelog

## 1.6.7

### Breaking changes

1. **ServiceAccount resource name honours `.Values.serviceAccount.name`**
   — the legacy `templates/serviceaccount.yaml` hard-coded
   `metadata.name: {{ include "orion.fullname" . }}` and ignored
   `.Values.serviceAccount.name`. The new `common.serviceAccount.tpl`
   uses `common.serviceAccount.name`, which applies
   `.Values.serviceAccount.name` as an override (same helper that
   already drove `serviceAccountName` on the Deployment pod spec).
   Concretely, a release with `serviceAccount.create: true` and
   `serviceAccount.name: custom-sa` now renders a ServiceAccount named
   `custom-sa` instead of `<fullname>`.