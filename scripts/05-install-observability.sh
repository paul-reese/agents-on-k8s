#!/usr/bin/env bash
# Module 5: deploy Jaeger and send traces to it from agentgateway and kagent.
source "$(dirname "$0")/lib.sh"
use_ctx
KAGENT_CHART_VERSION="${KAGENT_CHART_VERSION:-1.0.1}"
OTLP="http://jaeger.observability.svc.cluster.local:4317"

echo "== Jaeger (trace viewer) in namespace observability"
kubectl apply -f "$ROOT/manifests/lab-e/jaeger.yaml"
kubectl rollout status deploy/jaeger -n observability --timeout=5m

echo "== agentgateway: tracing parameters, referenced by the Gateway"
kubectl apply -f "$ROOT/manifests/lab-e/agentgateway-tracing.yaml"
kubectl rollout status deploy/agentgateway-proxy -n agentgateway-system --timeout=5m

echo "== kagent: controller and agent runtimes export traces to the same Jaeger"
helm upgrade kagent oci://ghcr.io/kagent-dev/kagent/helm/kagent -n kagent \
  --version "$KAGENT_CHART_VERSION" --reuse-values \
  --set-string config.telemetry.traces.endpoint="$OTLP" \
  --set-string config.runtimeDefaults.telemetry.traces.endpoint="$OTLP"
kubectl rollout status deploy/kagent-controller -n kagent --timeout=10m

cat <<'EOF'

Next:
  kubectl port-forward -n observability svc/jaeger 16686:16686    # then http://localhost:16686
  Chat with an agent, then look for its traces. See docs/05-observability.md.
EOF
