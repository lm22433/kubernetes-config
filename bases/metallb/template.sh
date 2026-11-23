#!/bin/bash

set -euo pipefail

OUTPUT_DIRECTORY="generated-manifests"
METALLB_DIRECTORY="${OUTPUT_DIRECTORY}/metallb"
TEMPLATE_DIRECTORY="${METALLB_DIRECTORY}/templates"
CRD_DIRECTORY="${METALLB_DIRECTORY}/crds"
METALLB_VERSION="0.16.2"
SERVICE="metallb"
KUBERNETES_VERSION="1.37.0"

rm -rf "$OUTPUT_DIRECTORY"

helm template metallb metallb \
    --repo https://metallb.github.io/metallb \
    -f values.yaml \
    -n metallb-system \
    --version $METALLB_VERSION \
    --output-dir $OUTPUT_DIRECTORY \
    --kube-version $KUBERNETES_VERSION

mkdir -p "$CRD_DIRECTORY"
mv "${METALLB_DIRECTORY}/charts/crds/templates/crds.yaml" "$CRD_DIRECTORY/crds.yaml"
rm -rf "${METALLB_DIRECTORY}/charts"

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
