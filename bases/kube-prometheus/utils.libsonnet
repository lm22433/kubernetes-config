{
  local kustomizationResourceFile(name) = name + '.yaml',
  local generate_kustomization(resources) =
    {
      apiVersion: 'kustomize.config.k8s.io/v1beta1',
      kind: 'Kustomization',
      resources: std.map(kustomizationResourceFile, std.objectFields(resources)),
    },
  generate(manifests, kustomizationExtras={})::
    manifests
    {
      kustomization: generate_kustomization(manifests) + kustomizationExtras,
    },
}
