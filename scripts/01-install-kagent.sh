#!/usr/bin/env bash
# Module 1: install kagent with the kagent CLI.
#
# Why the CLI and not plain Helm: since kagent 1.0 the Helm chart no longer deploys PostgreSQL or the
# Substrate sandbox runtime. `kagent install` sets up both (dev-grade Postgres in the kagent namespace,
# Substrate in ate-system), writes the DB connection Secrets, then installs kagent.
# A plain `helm install` leaves the controller stuck on missing kagent-postgres-* Secrets.
source "$(dirname "$0")/lib.sh"
use_ctx
require_var ANTHROPIC_API_KEY

# Clean up an earlier plain-Helm install, if present.
if helm status kagent -n kagent >/dev/null 2>&1 && ! kubectl get ns ate-system >/dev/null 2>&1; then
  echo "Removing earlier Helm-only kagent install..."
  helm uninstall kagent -n kagent || true
  helm uninstall kagent-crds -n kagent || true
fi

if ! command -v kagent >/dev/null; then
  echo "Installing the kagent CLI (may prompt for your password to write to /usr/local/bin)..."
  if [[ -n "${KAGENT_VERSION:-}" ]]; then
    curl -sL https://kagent.dev/install | bash -s -- --version "$KAGENT_VERSION"
  else
    curl -sL https://kagent.dev/install | bash
  fi
fi
kagent version || true

export ANTHROPIC_API_KEY
kagent install --provider Anthropic

echo "Waiting for kagent deployments (first run pulls large images; can take several minutes)..."
kubectl wait --for=condition=Available deployment --all -n kagent --timeout=15m

echo "Open the UI with:"
echo "  kubectl port-forward -n kagent service/kagent-ui 8082:8080   # then http://localhost:8082"
