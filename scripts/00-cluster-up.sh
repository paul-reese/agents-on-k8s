#!/usr/bin/env bash
# Module 0: start a Colima k3s cluster and install Gateway API CRDs.
source "$(dirname "$0")/lib.sh"
need colima; need kubectl; need helm

colima start "$COLIMA_PROFILE" --kubernetes \
  --cpu "${COLIMA_CPU:-6}" --memory "${COLIMA_MEMORY:-12}" --disk "${COLIMA_DISK:-60}"
use_ctx
kubectl get nodes

if kubectl get pods -A 2>/dev/null | grep -q traefik; then
  echo "WARNING: Traefik is running and may hold ports 80/443. Consider disabling it."
fi

kubectl apply --server-side --force-conflicts \
  -f "https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION:-v1.5.0}/standard-install.yaml"

echo "Cluster ready (context: $CTX)."
