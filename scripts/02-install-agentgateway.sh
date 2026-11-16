#!/usr/bin/env bash
# Module 2: install agentgateway, front OpenAI with it, and point a kagent ModelConfig at the gateway.
source "$(dirname "$0")/lib.sh"
use_ctx
require_var AGW_VERSION
require_var OPENAI_API_KEY

helm upgrade -i agentgateway-crds oci://cr.agentgateway.dev/charts/agentgateway-crds \
  --create-namespace -n agentgateway-system --version "$AGW_VERSION"

helm upgrade -i agentgateway oci://cr.agentgateway.dev/charts/agentgateway \
  -n agentgateway-system --version "$AGW_VERSION" \
  --set agentgatewayModels.enabled=true --wait

# Provider key lives only in the gateway's namespace.
kubectl create secret generic openai-key -n agentgateway-system \
  --from-literal=Authorization="$OPENAI_API_KEY" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f "$ROOT/manifests/lab-b/gateway.yaml"
kubectl apply -f "$ROOT/manifests/lab-b/agentgateway-model.yaml"
kubectl apply -f "$ROOT/manifests/lab-b/kagent-modelconfig.yaml"

kubectl get gateway,agentgatewaymodel -n agentgateway-system
kubectl get modelconfig agentgateway-model -n kagent
echo "Next: set an agent's model config to 'agentgateway-model' and chat with it."
echo "Watch traffic: kubectl logs -n agentgateway-system deploy/agentgateway-proxy -f"
