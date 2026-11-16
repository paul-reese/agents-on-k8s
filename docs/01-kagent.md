# Module 1: First agent with kagent

**Solo labs:** Building an AI agent with kagent; Implement AgentOps with kagent.

**Script:** `scripts/01-install-kagent.sh` (needs `ANTHROPIC_API_KEY` in `.env`)

## What it does

Installs the kagent CRDs and controller with Anthropic as the default provider. Model calls go straight
to the provider; Module 2 moves them behind agentgateway. Since kagent 0.7, the kmcp MCP-server
controller ships with kagent, so Module 3 needs no extra install.

## Exercises

```bash
kubectl port-forward -n kagent service/kagent-ui 8082:8080   # http://localhost:8082
```

1. Chat with `k8s-agent`: "list the pods in the kagent namespace". Watch which tools it calls.
2. `kubectl get agents,modelconfigs -n kagent`, then read one Agent's YAML. Prompt, model, and tools are
   just fields on a resource.
3. Copy that Agent, change its system prompt, `kubectl apply` it, and chat with your version.

## References

- [kagent quickstart](https://www.kagent.dev/docs/kagent/getting-started/quickstart)
- [kagent installation](https://www.kagent.dev/docs/kagent/introduction/installation)
