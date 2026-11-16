CLUSTER_TENGU := tengu
CLUSTER_KITSUNE := kitsune

.PHONY: clusters/tengu/bootstrap
clusters/tengu/bootstrap:
	kubectl --context=${CLUSTER_TENGU} apply -k clusters/tengu/kube-prometheus
	kubectl --context=${CLUSTER_TENGU} wait --all customresourcedefinition.apiextensions.k8s.io --for condition=established

	kubectl --context=${CLUSTER_TENGU} apply -k bases/argocd/crds
	kubectl --context=${CLUSTER_TENGU} wait --all customresourcedefinition.apiextensions.k8s.io --for condition=established
	kubectl --context=${CLUSTER_TENGU} apply -k clusters/tengu/argocd

.PHONY: kitsune/bootstrap
kitsune/bootstrap:
	# Setup Envoy Gateway
	kubectl --context=kind-${CLUSTER_KITSUNE} apply -k bases/envoy-gateway/setup
	kubectl --context=kind-${CLUSTER_KITSUNE} wait --all customresourcedefinition.apiextensions.k8s.io --for condition=established

	# Kube Prometheus
	kubectl --context=kind-${CLUSTER_KITSUNE} apply -k clusters/kitsune/kube-prometheus
	kubectl --context=kind-${CLUSTER_KITSUNE} wait --all customresourcedefinition.apiextensions.k8s.io --for condition=established

	# Cert Manager
	kubectl --context=kind-${CLUSTER_KITSUNE} apply -k bases/cert-manager/generated-manifests/cert-manager/crds
	kubectl --context=kind-${CLUSTER_KITSUNE} wait --all customresourcedefinition.apiextensions.k8s.io --for condition=established
	kubectl --context=kind-${CLUSTER_KITSUNE} wait --all deployment.apps --all-namespaces --for condition=available --timeout 2m
	kubectl --context=kind-${CLUSTER_KITSUNE} apply -k clusters/kitsune/cert-manager

	# External Secrets
	kubectl --context=kind-${CLUSTER_KITSUNE} apply --server-side -k clusters/kitsune/external-secrets
	kubectl --context=kind-${CLUSTER_KITSUNE} wait --all customresourcedefinition.apiextensions.k8s.io --for condition=established
	kubectl --context=kind-${CLUSTER_KITSUNE} wait --all deployment.apps --all-namespaces --for condition=available --timeout 2m

	# Envoy Gateway
	kubectl --context=kind-${CLUSTER_KITSUNE} apply -k clusters/kitsune/envoy-gateway
	kubectl --context=kind-${CLUSTER_KITSUNE} wait --all deployment.apps --all-namespaces --for condition=available --timeout 5m

	# Gateways
	kubectl --context=kind-${CLUSTER_KITSUNE} apply -k clusters/kitsune/gateways
	kubectl --context=kind-${CLUSTER_KITSUNE} -n envoy-gateway wait gateway/private --for condition=Programmed --timeout 2m

.PHONY: kitsune/create
kitsune/create:
	kind create cluster --name ${CLUSTER_KITSUNE} --config clusters/kitsune/cluster.yaml
	${MAKE} kitsune/bootstrap

.PHONY: kitsune/destroy
kitsune/destroy:
	kind delete cluster --name ${CLUSTER_KITSUNE}

include clusters/kitsune/Makefile
