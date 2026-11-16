#!/bin/bash

set -euo pipefail

OUTPUT_DIRECTORY="generated-manifests"
ENVOY_DIRECTORY="${OUTPUT_DIRECTORY}/gateway-helm"
CRD_DIRECTORY="setup"
ENVOY_VERSION="1.10.0"
SERVICE="envoy-gateway"
KUBERNETES_VERSION="1.37.0"

rm -rf "$OUTPUT_DIRECTORY" "$CRD_DIRECTORY"

helm template envoy-gateway oci://docker.io/envoyproxy/gateway-helm \
    -f values.yaml \
    -n envoy-gateway \
    --version $ENVOY_VERSION \
    --output-dir $OUTPUT_DIRECTORY \
    --kube-version $KUBERNETES_VERSION

helm template envoy-gateway oci://docker.io/envoyproxy/gateway-crds-helm \
    -f crd-values.yaml \
    -n envoy-gateway \
    --version $ENVOY_VERSION \
    --output-dir $CRD_DIRECTORY \
    --kube-version $KUBERNETES_VERSION

# Remove descriptions
echo "Removing descriptions from CRDs..."
find "$CRD_DIRECTORY" -name '*.yaml' -print0 | while IFS= read -r -d '' file; do
    echo "Processing: $file"
    cp "$file" "$file.bak"
    yq -y 'select(. != null) | walk(if type == "object" then with_entries(select(.key != "description" or (.value | type) != "string")) else . end)' "$file.bak" > "$file"
    rm "$file.bak"
done
echo "Descriptions removed."

cat <<EOF > $ENVOY_DIRECTORY/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
metadata:
  name: $SERVICE

resources:
EOF

find $ENVOY_DIRECTORY/templates -name '*.yaml' -not -name 'kustomization.yaml' | sort | while read -r file; do
    echo "  - .${file#"$ENVOY_DIRECTORY"}" >> $ENVOY_DIRECTORY/kustomization.yaml
done

cat <<EOF > $CRD_DIRECTORY/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
metadata:
  name: $SERVICE-crds

resources:
EOF

find ${CRD_DIRECTORY} -name '*.yaml' -not -name 'kustomization.yaml' | sort | while read -r file; do
    echo "  - .${file#"$CRD_DIRECTORY"}" >> $CRD_DIRECTORY/kustomization.yaml
done
