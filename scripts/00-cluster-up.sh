#!/usr/bin/env bash
# Module 0: start a Colima k3s cluster and install Gateway API CRDs.
#
# kagent 1.0 runs agents on Substrate, which uses Kubernetes Pod Certificates. Those need
# Kubernetes >= 1.35 plus feature gates and the certificates.k8s.io/v1beta1 API, which k3s
# leaves off by default (kagent's own kind config enables the same set).
# Without them, `kagent install` fails on "podcertificate-controller not ready".
source "$(dirname "$0")/lib.sh"
need colima; need kubectl; need helm

K8S_VERSION="${K8S_VERSION:-v1.35.0+k3s1}"
GATES="ClusterTrustBundle=true,ClusterTrustBundleProjection=true,PodCertificateRequest=true"

if colima status "$COLIMA_PROFILE" >/dev/null 2>&1; then
  echo "Colima profile '$COLIMA_PROFILE' already exists. k3s flags only apply to a new cluster."
  echo "Run ./scripts/teardown.sh first if this cluster was created without the feature gates."
fi

# --k3s-arg values are parsed as CSV, so args containing commas are wrapped in double quotes.
# Passing --k3s-arg replaces Colima's default (--disable=traefik), so it is repeated here.
colima start "$COLIMA_PROFILE" --kubernetes \
  --kubernetes-version "$K8S_VERSION" \
  --cpu "${COLIMA_CPU:-6}" --memory "${COLIMA_MEMORY:-12}" --disk "${COLIMA_DISK:-60}" \
  --k3s-arg "--disable=traefik" \
  --k3s-arg "\"--kube-apiserver-arg=feature-gates=${GATES}\"" \
  --k3s-arg "--kube-apiserver-arg=runtime-config=certificates.k8s.io/v1beta1=true" \
  --k3s-arg "\"--kube-controller-manager-arg=feature-gates=${GATES}\"" \
  --k3s-arg "\"--kubelet-arg=feature-gates=${GATES}\""
use_ctx
kubectl get nodes

if kubectl api-resources --api-group=certificates.k8s.io | grep -q podcertificaterequests; then
  echo "Pod Certificates API: enabled"
else
  echo "WARNING: podcertificaterequests API not found; kagent 1.0 install will fail. Recreate the cluster."
fi

if kubectl get pods -A 2>/dev/null | grep -q traefik; then
  echo "WARNING: Traefik is running and may hold ports 80/443."
fi

kubectl apply --server-side --force-conflicts \
  -f "https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION:-v1.5.0}/standard-install.yaml"

echo "Cluster ready (context: $CTX)."
