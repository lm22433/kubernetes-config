ifndef CLUSTER_TENGU
  $(error "CLUSTER_TENGU is not set.")
endif

.PHONY: tengu/deploy/metallb
tengu/deploy/metallb:
	kubectl --context=${CLUSTER_TENGU} apply --server-side -k bases/metallb/generated-manifests/metallb/crds
	kubectl --context=${CLUSTER_TENGU} wait --all customresourcedefinition.apiextensions.k8s.io --for condition=established
	kubectl --context=${CLUSTER_TENGU} apply --server-side -k clusters/tengu/metallb
