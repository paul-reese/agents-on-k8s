#!/usr/bin/env bash
# Module 1: install kagent with Anthropic as the default provider (direct, no gateway yet).
source "$(dirname "$0")/lib.sh"
use_ctx
require_var ANTHROPIC_API_KEY

# Plain string, not an array: macOS ships Bash 3.2, where an empty array fails under `set -u`.
VER=""
[[ -n "${KAGENT_VERSION:-}" ]] && VER="--version $KAGENT_VERSION"

# shellcheck disable=SC2086  # $VER is intentionally unquoted so it splits into two args or none
helm upgrade --install kagent-crds oci://ghcr.io/kagent-dev/kagent/helm/kagent-crds \
  --namespace kagent --create-namespace $VER

# shellcheck disable=SC2086
helm upgrade --install kagent oci://ghcr.io/kagent-dev/kagent/helm/kagent \
  --namespace kagent $VER \
  --set providers.default=anthropic \
  --set providers.anthropic.apiKey="$ANTHROPIC_API_KEY"

echo "Waiting for kagent deployments (first run pulls large images; can take several minutes)..."
kubectl wait --for=condition=Available deployment --all -n kagent --timeout=15m
echo "Open the UI with:"
echo "  kubectl port-forward -n kagent service/kagent-ui 8082:8080   # then http://localhost:8082"
