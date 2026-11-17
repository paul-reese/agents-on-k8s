#!/usr/bin/env bash
# Module 2: install agentgateway, put Anthropic behind it, and create a kagent agent that uses it.
source "$(dirname "$0")/lib.sh"
use_ctx
require_var ANTHROPIC_API_KEY
AGW_VERSION="${AGW_VERSION:-v1.7.0}"
GATEWAY_API_VERSION="${GATEWAY_API_VERSION:-v1.6.3}"

echo "== Gateway API CRDs ${GATEWAY_API_VERSION} (agentgateway builds on them)"
kubectl apply --server-side --force-conflicts \
  -f "https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/standard-install.yaml"

echo "== agentgateway ${AGW_VERSION}: CRDs, then the control plane"
helm upgrade -i agentgateway-crds oci://cr.agentgateway.dev/charts/agentgateway-crds \
  --create-namespace -n agentgateway-system --version "$AGW_VERSION"
helm upgrade -i agentgateway oci://cr.agentgateway.dev/charts/agentgateway \
  -n agentgateway-system --version "$AGW_VERSION" --wait

echo "== Gateway (the controller creates the agentgateway-proxy Deployment for it)"
kubectl apply -f "$ROOT/manifests/lab-b/gateway.yaml"
kubectl wait --for=condition=Programmed gateway/agentgateway-proxy -n agentgateway-system --timeout=5m

echo "== Anthropic key: stored only in agentgateway-system"
kubectl create secret generic anthropic-secret -n agentgateway-system \
  --from-literal=Authorization="$ANTHROPIC_API_KEY" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "== Anthropic backend + route"
kubectl apply -f "$ROOT/manifests/lab-b/anthropic-backend.yaml"

echo "== kagent side: ModelConfig pointing at the gateway, and an agent that uses it"
kubectl apply -f "$ROOT/manifests/lab-b/kagent-modelconfig.yaml"
kubectl apply -f "$ROOT/manifests/lab-b/k8s-via-gateway.yaml"

kubectl get gateway,agentgatewaybackend,httproute -n agentgateway-system
kubectl get modelconfig,agent -n kagent
cat <<'EOF'

Next:
  kubectl get agent k8s-via-gateway -n kagent -w        # wait for READY=True
  kubectl logs -n agentgateway-system deploy/agentgateway-proxy -f
  Then chat with k8s-via-gateway in the dashboard and watch the gateway log.
See docs/02-agentgateway.md for the exercises.
EOF
