This deploys the [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus) stack on a cluster. The deployment is split into subdirectories, each with their own `kustomization.yaml` file so that they can be managed as seperate applications within ArgoCD.

The `setup` directory includes namespaces and custom resource defenitions (CRDs) and must be deployed first.

Running `` from this directory will regenerate the manifests and `kustomization.yaml` in all subdirectories.
