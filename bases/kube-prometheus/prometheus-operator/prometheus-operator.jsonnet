local utils = import '../utils.libsonnet';

local kp = import '../kube-prometheus.libsonnet';

local manifests = {
  [name]: kp.prometheusOperator[name]
  for name in std.objectFields(kp.prometheusOperator)
  if !std.startsWith(name, '0')
};

utils.generate(manifests)
