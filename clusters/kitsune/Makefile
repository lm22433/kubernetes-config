ifndef CLUSTER_KITSUNE
  $(error "CLUSTER_KITSUNE is not set.")
endif

.PHONY: kitsune/deploy/all
kitsune/deploy/all: kitsune/deploy/kube-prometheus kitsune/deploy/argocd kitsune/deploy/headlamp

.PHONY: kitsune/deploy/kube-prometheus
kitsune/deploy/kube-prometheus: kitsune/deploy/kube-prometheus/alertmanager kitsune/deploy/kube-prometheus/grafana kitsune/deploy/kube-prometheus/prometheus
	kubectl --context=kind-${CLUSTER_KITSUNE} apply -k clusters/kitsune/kube-prometheus/kubernetes-control-plane
	kubectl --context=kind-${CLUSTER_KITSUNE} apply -k clusters/kitsune/kube-prometheus/kube-state-metrics
	kubectl --context=kind-${CLUSTER_KITSUNE} apply -k clusters/kitsune/kube-prometheus/node-exporter

.PHONY: kitsune/deploy/kube-prometheus/prometheus-operator
kitsune/deploy/kube-prometheus/prometheus-operator:
	kubectl --context=kind-${CLUSTER_KITSUNE} apply -k clusters/kitsune/kube-prometheus/prometheus-operator

.PHONY: kitsune/deploy/kube-prometheus/prometheus
kitsune/deploy/kube-prometheus/prometheus: kitsune/deploy/kube-prometheus/prometheus-operator
	kubectl --context=kind-${CLUSTER_KITSUNE} apply -k clusters/kitsune/kube-prometheus/prometheus

.PHONY: kitsune/deploy/kube-prometheus/alertmanager
kitsune/deploy/kube-prometheus/alertmanager: kitsune/deploy/kube-prometheus/prometheus-operator
	kubectl --context=kind-${CLUSTER_KITSUNE} apply -k clusters/kitsune/kube-prometheus/alertmanager

.PHONY: kitsune/deploy/kube-prometheus/grafana
kitsune/deploy/kube-prometheus/grafana:
	kustomize build --load-restrictor LoadRestrictionsNone clusters/kitsune/kube-prometheus/grafana | kubectl --context=kind-${CLUSTER_KITSUNE} apply --server-side -f -

.PHONY: kitsune/deploy/argocd
kitsune/deploy/argocd:
	kubectl --context=kind-${CLUSTER_KITSUNE} apply --server-side --force-conflicts -k bases/argocd/crds
	kubectl --context=kind-${CLUSTER_KITSUNE} wait --all customresourcedefinition.apiextensions.k8s.io --for condition=established
	kubectl --context=kind-${CLUSTER_KITSUNE} apply --server-side --force-conflicts -k clusters/kitsune/argocd

.PHONY: kitsune/deploy/headlamp
kitsune/deploy/headlamp:
	kubectl --context=kind-${CLUSTER_KITSUNE} apply -k clusters/kitsune/headlamp

.PHONY: kitsune/deploy/loki
kitsune/deploy/loki: kitsune/deploy/kube-prometheus/prometheus-operator
	kubectl --context=kind-${CLUSTER_KITSUNE} apply -k clusters/kitsune/loki
