#!/bin/bash

set -euo pipefail

OUTPUT_DIRECTORY="generated-manifests"
CERT_MANAGER_DIRECTORY="${OUTPUT_DIRECTORY}/cert-manager"
TEMPLATE_DIRECTORY="${CERT_MANAGER_DIRECTORY}/templates"
CRD_DIRECTORY="${CERT_MANAGER_DIRECTORY}/crds"
CERT_MANAGER_VERSION="v1.21.3"
SERVICE="cert-manager"
KUBERNETES_VERSION="1.37.0"

rm -rf "$OUTPUT_DIRECTORY" "$CRD_DIRECTORY"

helm template cert-manager cert-manager \
    --repo https://charts.jetstack.io \
    -f values.yaml \
    -n cert-manager \
    --version $CERT_MANAGER_VERSION \
    --output-dir $OUTPUT_DIRECTORY \
    --kube-version $KUBERNETES_VERSION

mkdir -p $CRD_DIRECTORY

find "$TEMPLATE_DIRECTORY" -name 'crd-*.yaml' | while IFS= read -r file; do
    mv "$file" "$CRD_DIRECTORY/$(basename "$file")"
done

cat <<EOF > $OUTPUT_DIRECTORY/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
metadata:
  name: $SERVICE

resources:
EOF

find $TEMPLATE_DIRECTORY -name '*.yaml' -not -name 'kustomization.yaml' | sort | while read -r file; do
    echo "  - .${file#"$OUTPUT_DIRECTORY"}" >> $OUTPUT_DIRECTORY/kustomization.yaml
done

cat <<EOF > $CRD_DIRECTORY/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
metadata:
  name: $SERVICE-crds

resources:
EOF

find $CRD_DIRECTORY -name '*.yaml' -not -name 'kustomization.yaml' | sort | while read -r file; do
    echo "  - .${file#"$CRD_DIRECTORY"}" >> $CRD_DIRECTORY/kustomization.yaml
done
