# Module 2: agentgateway in front of kagent

**Solo lab:** [Program agentgateway for LLM consumption](https://solo.io/resources/lab/program-agentgateway-for-llm-consumption)
(note: the lab uses kgateway as the control plane; this repo uses agentgateway's own charts).

**Script:** `scripts/02-install-agentgateway.sh` (needs `AGW_VERSION` and `OPENAI_API_KEY` in `.env`)

## Goal

kagent no longer holds the provider key. Every model call goes agent → agentgateway → LLM, where you can
apply policy and observe traffic.

## What it does

1. Installs `agentgateway-crds` and `agentgateway` from `oci://cr.agentgateway.dev/charts`, with
   `agentgatewayModels.enabled=true`.
2. Stores the OpenAI key as a secret in `agentgateway-system` only.
3. Applies:
   - `manifests/lab-b/gateway.yaml`: the `agentgateway-proxy` Gateway
   - `manifests/lab-b/agentgateway-model.yaml`: `gpt-4o-mini` exposed via the gateway
   - `manifests/lab-b/kagent-modelconfig.yaml`: a kagent ModelConfig whose `baseUrl` is the gateway

> **Verify before relying on it:** the AgentgatewayModel field layout was reconstructed from the guide.
> Run `kubectl explain agentgatewaymodel.spec` and adjust if the apply fails.

## Exercises

- [ ] Set an agent's model config to `agentgateway-model`, chat, and confirm the request in
      `kubectl logs -n agentgateway-system deploy/agentgateway-proxy`.
- [ ] Add a prompt-guard AgentgatewayPolicy that rejects prompts containing "email"
      ([example](https://agentgateway.dev/docs/kubernetes/main/integrations/agent-runtimes/kagent/)).
- [ ] Add Anthropic as a second model behind the same Gateway; switch the agent by editing only the ModelConfig.
- [ ] Remove the provider key from kagent's Helm values. The gateway is now the only place it lives.

## References

- [kagent: bring your own agentgateway](https://www.kagent.dev/docs/kagent/supported-providers/byo-agentgateway/)
- [agentgateway: install on Kubernetes](https://agentgateway.dev/docs/kubernetes/latest/quickstart/install/)
- [agentgateway: kagent integration](https://agentgateway.dev/docs/kubernetes/main/integrations/agent-runtimes/kagent/)
