#!/usr/bin/env bash

set -euo pipefail

OUTPUT_DIRECTORY="generated-manifests"
EXTERNAL_SECRETS_DIRECTORY="${OUTPUT_DIRECTORY}/external-secrets"
EXTERNAL_SECRETS_VERSION="2.15.0"
SERVICE="external-secrets"
KUBERNETES_VERSION="1.37.0"

rm -rf "$OUTPUT_DIRECTORY"

helm template external-secrets external-secrets \
    --repo https://charts.external-secrets.io \
    -f values.yaml \
    -n external-secrets \
    --api-versions monitoring.coreos.com/v1 \
    --version $EXTERNAL_SECRETS_VERSION \
    --output-dir $OUTPUT_DIRECTORY \
    --kube-version $KUBERNETES_VERSION

cat <<EOF > $OUTPUT_DIRECTORY/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
metadata:
  name: $SERVICE

resources:
EOF

find $EXTERNAL_SECRETS_DIRECTORY/templates -name '*.yaml' -not -name 'kustomization.yaml' | sort | while read -r file; do
    echo "  - .${file#"$OUTPUT_DIRECTORY"}" >> $OUTPUT_DIRECTORY/kustomization.yaml
done
