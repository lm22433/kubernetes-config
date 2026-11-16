.PHONY: all cluster-rbac crds namespace-install
version = 3.6.1

all: cluster-rbac crds namespace-install

cluster-rbac:
	echo "# This is an auto-generated file. Do not edit manually." > cluster-rbac/cluster-rbac.yaml
	kustomize build "https://github.com/argoproj/argo-cd//manifests/cluster-rbac?ref=v$(version)" >> cluster-rbac/cluster-rbac.yaml

crds:
	echo "# This is an auto-generated file. Do not edit manually." > crds/crds.yaml
	kustomize build "https://github.com/argoproj/argo-cd//manifests/crds?ref=v$(version)" >> crds/crds.yaml

namespace-install:
	echo "# This is an auto-generated file. Do not edit manually." > namespace-install/namespace-install.yaml
	kustomize build "https://github.com/argoproj/argo-cd//manifests/ha/namespace-install?ref=v$(version)" >> namespace-install/namespace-install.yaml
