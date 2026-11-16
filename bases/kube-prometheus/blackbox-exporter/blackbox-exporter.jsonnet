local utils = import '../utils.libsonnet';

local kp = import '../kube-prometheus.libsonnet';

local manifests = kp.blackboxExporter;

utils.generate(manifests)
