local utils = import '../utils.libsonnet';

local kp = import '../kube-prometheus.libsonnet';

local manifests = kp.prometheus {
  kubePrometheusRule: kp.kubePrometheus.prometheusRule,
};

utils.generate(manifests)
