# Agents on Kubernetes: kagent + agentgateway on Colima

A hands-on path for running AI agents on a local Kubernetes cluster (Colima/k3s on macOS), with
[kagent](https://kagent.dev) as the agent runtime and [agentgateway](https://agentgateway.dev) in front of
every model, tool, and agent call.

Each module pairs a free [Solo Academy lab](https://www.solo.io/mcp-academy) (concepts, hosted sandbox) with a
local rebuild on your own cluster using current upstream charts.

## Modules

Each lesson follows the same shape: why it matters, how the pieces fit (tables plus a diagram), steps where
every command says what it shows and why, troubleshooting, and references.

| # | Goal | Solo lab(s) | Lesson | Script | Status |
|---|------|-------------|--------|--------|--------|
| 0 | Local cluster (Colima k3s 1.35 + Pod Certificates) | Basics of Kubernetes Gateway API | [00-colima](docs/00-colima.md) | `00-cluster-up.sh` | Tested |
| 1 | First agent: Agent, AgentTemplate, Harness, Substrate | Building an AI agent with kagent; AgentOps with kagent | [01-kagent](docs/01-kagent.md) | `01-install-kagent.sh` | Tested |
| 1b | Egress policies: what an agent may reach | (none; new in kagent 1.0) | [01b-egress](docs/01b-egress.md) | (manifest) | Untested |
| 2 | Model calls through agentgateway: one key, guards, budgets | Program agentgateway for LLM consumption | [02-agentgateway](docs/02-agentgateway.md) | `02-install-agentgateway.sh` | Untested |
| 3 | Tools through MCP: multiplexing, tool authorization | Build/deploy MCP servers; Multiplex MCP servers & auth | [03-mcp](docs/03-mcp.md) | `03-install-mcp.sh` | Untested |
| 4 | Agents working together: sub-agents, A2A, harness swap | Local development with kagent CLI; Agent skills | [04-custom-agents](docs/04-custom-agents.md) | (manifests) | Untested |
| 5 | Observability: traces, metrics, logs | Observe Agent & MCP server interactions | [05-observability](docs/05-observability.md) | `05-install-observability.sh` | Untested |

"Untested" means written against the current kagent 1.0 and agentgateway v1.7 docs and CRDs, but not yet
run end to end on this setup. Fixes go in as they are found.

## Quick start

```bash
cp .env.example .env          # add ANTHROPIC_API_KEY
./scripts/00-cluster-up.sh    # Colima k3s 1.35 + feature gates + Gateway API CRDs
./scripts/01-install-kagent.sh
kubectl apply -f manifests/lab-a/k8s-readonly.yaml
./scripts/02-install-agentgateway.sh
./scripts/03-install-mcp.sh
kubectl apply -f manifests/lab-d/platform-team.yaml
./scripts/05-install-observability.sh
```

Tear down with `./scripts/teardown.sh` (deletes the Colima profile).

## Requirements

- macOS with Homebrew: `brew install colima kubectl helm`
- 6 CPU / 12 GB RAM free for the VM
- An Anthropic API key (every module uses Anthropic only)
- Node.js for MCP Inspector in Module 3 (`brew install node`)

## Notes

- **kagent 1.0 (Nov 2026) changed the install and runtime model.** Agents run as sandboxed actors on
  Substrate, which needs Pod Certificates (feature gates set in `00-cluster-up.sh`) and the `kagent install`
  CLI. Solo Academy labs and kagent.dev pages that predate 1.0 describe the older Helm-only model.
- Upstream docs assume kind. Here, `kind create cluster` and `cloud-provider-kind` steps are replaced by
  Colima's k3s and `kubectl port-forward`.
- agentgateway is installed with its own control plane charts (`cr.agentgateway.dev`), not via kgateway as in
  some older labs. Don't mix the two on one cluster.
- CRDs are alpha (`api.kagent.dev/v1alpha3`, `agentgateway.dev/v1alpha1`). If an apply fails, check fields with `kubectl explain <kind>.spec`.
- Versions are pinned in `.env` (kagent 1.0.1, agentgateway v1.7.0, Gateway API v1.6.3). If your `.env`
  predates these, copy the new values from `.env.example`.

## License

Add a license before publishing (MIT or Apache-2.0 are common for tutorials).
