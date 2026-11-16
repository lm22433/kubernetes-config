local utils = import '../utils.libsonnet';

local kp = import '../kube-prometheus.libsonnet';

local manifests = kp.alertmanager;

utils.generate(manifests)
