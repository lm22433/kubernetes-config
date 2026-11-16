#!/bin/bash

set -euo pipefail

OUTPUT_DIRECTORY="generated-manifests"
HEADLAMP_DIRECTORY="${OUTPUT_DIRECTORY}/headlamp"
HEADLAMP_VERSION="0.46.0"
SERVICE="headlamp"
KUBERNETES_VERSION="1.37.0"

rm -rf "$OUTPUT_DIRECTORY"

helm template headlamp headlamp \
    --repo https://kubernetes-sigs.github.io/headlamp/ \
    -f values.yaml \
    -n headlamp \
    --version $HEADLAMP_VERSION \
    --output-dir $OUTPUT_DIRECTORY \
    --kube-version $KUBERNETES_VERSION

cat <<EOF > $OUTPUT_DIRECTORY/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
metadata:
  name: $SERVICE

resources:
EOF

find $HEADLAMP_DIRECTORY/templates -name '*.yaml' -not -name 'kustomization.yaml' | sort | while read -r file; do
    echo "  - .${file#"$OUTPUT_DIRECTORY"}" >> $OUTPUT_DIRECTORY/kustomization.yaml
done
