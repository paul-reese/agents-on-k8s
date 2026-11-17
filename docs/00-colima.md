# Module 0: Colima cluster + Gateway API

**Solo lab:** Basics of Kubernetes Gateway API (optionally: Exploring HTTPRoute configurations).

**Script:** `scripts/00-cluster-up.sh`

## What it does

1. Starts a dedicated Colima profile with k3s v1.35 (default 6 CPU / 12 GB / 60 GB disk), with the
   Pod Certificate feature gates and `certificates.k8s.io/v1beta1` API turned on.
2. Switches kubectl to the `colima-<profile>` context.
3. Applies the Gateway API standard CRDs, which agentgateway needs.

## Why the feature gates

kagent 1.0 runs agents on Substrate, which identifies pods with Kubernetes Pod Certificates
(`PodCertificateRequest`, `ClusterTrustBundle`, `ClusterTrustBundleProjection`). They are off by default.
Without them `kagent install` fails with `podcertificate-controller not ready`. These flags only apply
when the cluster is created, so an existing cluster must be torn down and recreated.

## Why Colima k3s instead of kind

One VM, one command, and k3s includes a basic load balancer. Upstream docs assume kind. Wherever they say
`kind create cluster` or `cloud-provider-kind`, skip that step and use `kubectl port-forward`.

## Check

```bash
kubectl get nodes
kubectl api-resources --api-group=certificates.k8s.io   # should list podcertificaterequests
kubectl get crd | grep gateway.networking.k8s.io
kubectl get pods -A | grep traefik   # should be empty; Traefik would hold ports 80/443
```

## Reset

`./scripts/teardown.sh` deletes the profile. It's the fastest way to rerun a lab cleanly.
