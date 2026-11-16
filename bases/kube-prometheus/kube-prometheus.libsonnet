(import 'github.com/prometheus-operator/kube-prometheus/jsonnet/kube-prometheus/main.libsonnet') +
(import 'github.com/prometheus-operator/kube-prometheus/jsonnet/kube-prometheus/addons/all-namespaces.libsonnet') +
(import 'github.com/prometheus-operator/kube-prometheus/jsonnet/kube-prometheus/addons/managed-cluster.libsonnet') + {
  values+:: {
    common+: {
      namespace: 'kube-prometheus',
    },
  },
}
