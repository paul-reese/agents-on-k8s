# Module 0: Colima cluster + Gateway API

**Solo lab:** Basics of Kubernetes Gateway API (optionally: Exploring HTTPRoute configurations).

**Script:** `scripts/00-cluster-up.sh`

## What it does

1. Starts a dedicated Colima profile with k3s (default 6 CPU / 12 GB / 60 GB disk).
2. Switches kubectl to the `colima-<profile>` context.
3. Applies the Gateway API standard CRDs, which agentgateway needs.

## Why Colima k3s instead of kind

One VM, one command, and k3s includes a basic load balancer. Upstream docs assume kind. Wherever they say
`kind create cluster` or `cloud-provider-kind`, skip that step and use `kubectl port-forward`.

## Check

```bash
kubectl get nodes
kubectl get crd | grep gateway.networking.k8s.io
kubectl get pods -A | grep traefik   # should be empty; Traefik would hold ports 80/443
```

## Reset

`./scripts/teardown.sh` deletes the profile. It's the fastest way to rerun a lab cleanly.
