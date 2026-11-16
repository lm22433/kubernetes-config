#!/usr/bin/env bash
set -euo pipefail

fail=0
while IFS= read -r file; do
  dir=$(dirname "$file")
  if [[ ! -s $file ]]; then
    echo "::notice file=$file::empty kustomization, skipped"; continue
  fi
  flags=()
  [[ $dir == clusters/kitsune/kube-prometheus/grafana ]] && flags+=(--load-restrictor LoadRestrictionsNone)

  if kustomize build "${flags[@]}" "$dir" > /dev/null; then echo "$file: OK"
  else echo "::error file=$file::kustomize build failed"; fail=1
  fi
done < <(git ls-files '*kustomization.yaml')

exit $fail
