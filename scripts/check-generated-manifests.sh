#!/usr/bin/env bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

ALL_TARGETS=(alloy argocd cert-manager envoy-gateway external-secrets headlamp kube-prometheus loki)

check=0
if [[ ${1:-} == --check ]]; then check=1; shift; fi
targets=("${@:-${ALL_TARGETS[@]}}")

generate() {
  case $1 in
    argocd)          make -C bases/argocd ;;
    alloy|cert-manager|envoy-gateway|external-secrets|headlamp)
                     (cd "bases/$1" && bash template.sh) ;;
    kube-prometheus) make -C bases/kube-prometheus docker-build ;;
    loki)            make -C bases/loki docker-build ;;
    *) echo "unknown target: $1" >&2; return 1 ;;
  esac
}

fail=0
for t in "${targets[@]}"; do
  echo "::group::generate $t"
  generate "$t"
  echo "::endgroup::"

  if (( check )) && [[ -n $(git status --porcelain -- "bases/$t") ]]; then
    echo "::error::bases/$t is out of date, run: scripts/check-generated-manifests.sh $t"
    git status --short -- "bases/$t"
    git --no-pager diff --stat -- "bases/$t"
    fail=1
  fi
done

exit $fail
