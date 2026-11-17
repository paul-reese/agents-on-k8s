# Agents on Kubernetes: kagent + agentgateway on Colima

A hands-on path for running AI agents on a local Kubernetes cluster (Colima/k3s on macOS), with
[kagent](https://kagent.dev) as the agent runtime and [agentgateway](https://agentgateway.dev) in front of
every model, tool, and agent call.

Each module pairs a free [Solo Academy lab](https://www.solo.io/mcp-academy) (concepts, hosted sandbox) with a
local rebuild on your own cluster using current upstream charts.

## Modules

| # | Goal | Solo lab(s) | Local exercise | Status |
|---|------|-------------|----------------|--------|
| 0 | Cluster + Gateway API | Basics of Kubernetes Gateway API | [docs/00-colima.md](docs/00-colima.md) | Ready |
| 1 | First agent (kagent 1.0) | Building an AI agent with kagent; Implement AgentOps with kagent | [docs/01-kagent.md](docs/01-kagent.md) | Ready, tested |
| 1b | Egress policies | (none; new in kagent 1.0) | [docs/01b-egress.md](docs/01b-egress.md) | Ready |
| 2 | LLM traffic through a gateway | Program agentgateway for LLM consumption | [docs/02-agentgateway.md](docs/02-agentgateway.md) | Needs rework for kagent 1.0 |
| 3 | Tools via MCP | Build, run & deploy MCP servers to Kubernetes; Multiplex MCP servers & control auth policy | [docs/03-mcp.md](docs/03-mcp.md) | Outline |
| 4 | Your own agents + A2A | Local development with kagent CLI; Build AI agents with agent skills | [docs/04-custom-agents.md](docs/04-custom-agents.md) | Outline |
| 5 | Observability | Observe Agent & MCP server interactions (enterprise) | [docs/05-observability.md](docs/05-observability.md) | Outline |

## Quick start

```bash
cp .env.example .env          # add your API keys
./scripts/00-cluster-up.sh    # Colima k3s + Gateway API CRDs
./scripts/01-install-kagent.sh
./scripts/02-install-agentgateway.sh
```

Tear down with `./scripts/teardown.sh` (deletes the Colima profile).

## Requirements

- macOS with Homebrew: `brew install colima kubectl helm`
- 6 CPU / 12 GB RAM free for the VM
- An OpenAI and/or Anthropic API key

## Notes

- **kagent 1.0 (Nov 2026) changed the install and runtime model.** Agents run as sandboxed actors on
  Substrate, which needs Pod Certificates (feature gates set in `00-cluster-up.sh`) and the `kagent install`
  CLI. Solo Academy labs and kagent.dev pages that predate 1.0 describe the older Helm-only model.
- Upstream docs assume kind. Here, `kind create cluster` and `cloud-provider-kind` steps are replaced by
  Colima's k3s and `kubectl port-forward`.
- agentgateway is installed with its own control plane charts (`cr.agentgateway.dev`), not via kgateway as in
  some older labs. Don't mix the two on one cluster.
- CRDs are alpha (`v1alpha1`/`v1alpha2`). If an apply fails, check fields with `kubectl explain <kind>.spec`.
- Chart versions are pinned in `.env`. Update them deliberately.

## License

Add a license before publishing (MIT or Apache-2.0 are common for tutorials).
