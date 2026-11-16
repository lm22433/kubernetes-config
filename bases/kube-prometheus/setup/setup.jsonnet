local utils = import '../utils.libsonnet';

local kp = import '../kube-prometheus.libsonnet';

local manifests = {
  namespace: kp.kubePrometheus.namespace,
} + {
  [name]: kp.prometheusOperator[name]
  for name in std.objectFields(kp.prometheusOperator)
  if std.startsWith(name, '0')
};

utils.generate(manifests)
