# Module 1: First agent with kagent

**Solo labs:** Building an AI agent with kagent; Implement AgentOps with kagent.

**Script:** `scripts/01-install-kagent.sh` (needs `ANTHROPIC_API_KEY` in `.env`)

## What it does

Installs the `kagent` CLI and runs `kagent install --provider Anthropic`. Model calls go straight to the
provider; Module 2 moves them behind agentgateway.

> **kagent 1.0 changed the install.** The Helm chart alone no longer deploys PostgreSQL or Substrate (the
> sandbox runtime agents now run in). A plain `helm install` leaves `kagent-controller` stuck in
> `ContainerCreating` with `secret "kagent-postgres-readwrite" not found`. `kagent install` sets up
> Postgres (namespace `kagent`), Substrate (namespace `ate-system`), the DB secrets, and kagent.
> The script removes an earlier Helm-only install first.

Look around after install:

```bash
kubectl get pods -n kagent         # controller, ui, tools, postgres
kubectl get pods -n ate-system     # Substrate: where agent sandboxes run
kubectl api-resources | grep kagent  # the kinds kagent adds (Agent, ModelConfig, Harness, ...)
```

## Exercises

```bash
kubectl port-forward -n kagent service/kagent-ui 8082:8080   # http://localhost:8082
```

1. Chat with the default agent in the UI. Ask it something that needs a tool and watch the tool calls.
2. `kubectl get agents,modelconfigs -n kagent`, then read one Agent's YAML (`-o yaml`). Prompt, model,
   and tools are just fields on a resource.
3. See what the controller built from it: `kubectl get deploy,svc,pods -n kagent` and `-n ate-system`.
4. Copy that Agent, change its system prompt, `kubectl apply` it, and chat with your version.

Agent names and fields shift between kagent releases. If a name above doesn't exist, use
`kubectl get agents -A` and `kubectl explain agent.spec`.

## References

- [kagent quickstart](https://www.kagent.dev/docs/kagent/getting-started/quickstart)
- [kagent installation](https://www.kagent.dev/docs/kagent/introduction/installation)
