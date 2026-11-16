#!/usr/bin/env bash

set -euo pipefail

OUTPUT_DIRECTORY="generated-manifests"
ALLOY_DIRECTORY="${OUTPUT_DIRECTORY}/alloy"
ALLOY_VERSION="1.16.0"
SERVICE="alloy"
KUBERNETES_VERSION="1.37.0"

rm -rf "$OUTPUT_DIRECTORY"

helm template alloy alloy \
    --repo https://grafana.github.io/helm-charts \
    -f values.yaml \
    -n alloy \
    --api-versions monitoring.coreos.com/v1 \
    --version $ALLOY_VERSION \
    --output-dir $OUTPUT_DIRECTORY \
    --kube-version $KUBERNETES_VERSION

cat <<EOF > $OUTPUT_DIRECTORY/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
metadata:
  name: $SERVICE

resources:
EOF

find $ALLOY_DIRECTORY/templates -name '*.yaml' -not -name 'kustomization.yaml' | sort | while read -r file; do
    echo "  - .${file#"$OUTPUT_DIRECTORY"}" >> $OUTPUT_DIRECTORY/kustomization.yaml
done
