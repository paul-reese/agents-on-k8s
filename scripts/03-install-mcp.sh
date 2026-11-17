#!/usr/bin/env bash
# Module 3: deploy two MCP servers, combine them behind agentgateway at /mcp, and give an agent the tools.
source "$(dirname "$0")/lib.sh"
use_ctx

echo "== MCP servers (normal Deployments in namespace mcp)"
kubectl apply -f "$ROOT/manifests/lab-c/mcp-servers.yaml"
kubectl rollout status deploy/website-fetcher -n mcp --timeout=5m
kubectl rollout status deploy/everything -n mcp --timeout=10m

echo "== agentgateway: one MCP backend for both servers, routed at /mcp"
kubectl apply -f "$ROOT/manifests/lab-c/mcp-gateway.yaml"

echo "== kagent: RemoteMCPServer pointing at the gateway, and the web-reader agent"
kubectl apply -f "$ROOT/manifests/lab-c/kagent-mcp.yaml"

kubectl get pods -n mcp
kubectl get agentgatewaybackend,httproute -n agentgateway-system
kubectl get remotemcpserver,agent -n kagent
cat <<'EOF'

Next:
  kubectl get agent web-reader -n kagent -w     # wait for READY=True
  See docs/03-mcp.md: inspect the tools with MCP Inspector, then chat with web-reader.
EOF
