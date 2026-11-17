# Module 1b: Egress policies (what an agent may reach)

**Manifest:** `manifests/lab-a/egress-github.yaml`

## Why this matters

An agent decides at run time what to do, and a prompt can talk it into things. If its sandbox can reach
anything on the internet, a successful prompt injection can send your data anywhere. Egress policy limits
the damage: the sandbox can only reach the hosts its job needs, and secrets for those hosts never enter the
sandbox at all.

## How it fits together

| Piece | Responsible for |
|---|---|
| Inferred access | Origins kagent works out from the agent's definition: ModelConfig endpoint, MCP server URLs, telemetry endpoint, the control plane. Always allowed |
| `EgressPolicy` | Extra origins, optionally with a credential to inject. Lives in the agent's namespace |
| `Agent.spec.egressPolicyRefs` | Which policies this agent gets. On the Agent, not the template |
| kagent-controller | Resolves the policies, records the grant in Postgres, pushes it to running sessions |
| Substrate egress gateway | Enforces it on every outbound request and swaps in credentials |

```mermaid
flowchart TD
    REQ["Sandbox makes an HTTP(S) request"] --> GW["Substrate egress gateway"]
    GW --> Q1{"Origin inferred?<br/>(model, MCP, telemetry, control plane)"}
    Q1 -- yes --> CRED
    Q1 -- no --> Q2{"Origin in an EgressPolicy<br/>listed on this Agent?"}
    Q2 -- no --> BLOCK["Blocked"]
    Q2 -- yes --> CRED{"Credential binding<br/>for this origin + header?"}
    CRED -- yes --> SWAP["Replace placeholder header<br/>with the Secret value"] --> OUT["Forward to destination"]
    CRED -- no --> OUT
```

## The rule: deny by default

With no policy, an agent reaches only what kagent **infers** from its definition: its model provider, its
tool servers (MCP), artifact storage, and the kagent control plane. That's why `k8s-readonly` works with no
policy: its model and `kagent-tool-server` are inferred.

Anything else needs an `EgressPolicy`, referenced **from the Agent**, not the template. Two agents can share
a template and still get different network access.

## What a policy can express

- **Origins only:** scheme + DNS name + optional port (`https://api.github.com`). Every path on that
  origin is allowed.
- **Rejected:** paths, queries, IP addresses, non-HTTP protocols.
- **Wildcards:** replace exactly one leftmost label. `https://*.example.com` matches `api.example.com`,
  not `example.com` or `a.b.example.com`. A bare `*` or `*.com` is not accepted.
- **Redirects:** a redirect to another origin needs its own grant.
- **Limits:** up to 16 policies per agent, 1 to 64 destinations each.
- **Additive:** policies only add access. They can't remove inferred model or tool access.

## Credential injection: the agent never sees the secret

```yaml
destinations:
  - origin: https://api.github.com
    authentication:
      header: Authorization
      prefix: "Bearer "              # literal; keep the trailing space
      secretKeyRef: { name: github-token, key: token }
```

The agent sends a placeholder (`Authorization: Bearer kagent-credential-injected`). Substrate's egress
gateway replaces the header with the real value from the Secret. The token never enters the sandbox, so a
prompt-injected agent can't leak it. The gateway *replaces* an existing header but doesn't add a missing one.

```mermaid
sequenceDiagram
    autonumber
    participant SB as Agent sandbox
    participant EG as Substrate egress gateway
    participant CP as Credential provider
    participant K8s as Secret github-token (kagent ns)
    participant GH as api.github.com

    SB->>EG: GET https://api.github.com/... <br/>Authorization: Bearer kagent-credential-injected
    EG->>EG: origin allowed? (EgressPolicy github-api on this Agent)
    EG->>CP: credential for this origin + header?
    CP->>K8s: read token (cached up to 5 min)
    K8s-->>CP: real token
    CP-->>EG: real token
    EG->>EG: replace header value: "Bearer " + token
    EG->>GH: GET ... Authorization: Bearer ghp_real...
    GH-->>EG: response
    EG-->>SB: response (the sandbox never saw the token)
```

The same mechanism handles ModelConfig API keys in Module 1: kagent turns `apiKeySecret` into a binding
for the provider's origin, so the model key never enters the sandbox either.

## Exercise

Egress only matters for an agent that makes its own HTTP calls. `k8s-readonly` only calls in-cluster
tools. Use an agent on a harness that can run commands (check `kubectl get harness codex-default -n kagent
-o yaml`, or the claude-default harness).

1. Without a policy, ask the agent to fetch `https://api.github.com/zen`. Expect a blocked connection.
2. Apply the policy and reference it from the agent:
   ```bash
   kubectl apply -f manifests/lab-a/egress-github.yaml
   kubectl patch agent <your-agent> -n kagent --type merge \
     -p '{"spec":{"egressPolicyRefs":[{"name":"github-api"}]}}'
   ```
3. Check it was admitted: `kubectl get agent <your-agent> -n kagent -o yaml`, condition
   `EgressPoliciesApplied=True`.
4. Ask again; it should succeed. No new revision or snapshot is built: grants update running sessions
   directly.

| `EgressPoliciesApplied` reason | Meaning |
|---|---|
| `Applied` | All grants admitted |
| `EgressPolicyNotFound` | A referenced policy is missing |
| `InvalidEgressPolicy` | Bad origin, Secret reference, or too many refs |
| `EgressGrantConflict` | New grants held; earlier compatible grants remain |

## How this relates to agentgateway (Module 2)

kagent 1.0's built-in egress gateway answers **"may this agent reach this host, and with which
credential?"** agentgateway answers **LLM- and MCP-aware questions**: prompt guards, token budgets, model
routing and failover, MCP multiplexing and auth. They complement each other.

## References

- [Architecture: egress policies](https://github.com/kagent-dev/kagent/blob/main/docs/architecture/egress-policies.md)
- [Architecture: credential injection](https://github.com/kagent-dev/kagent/blob/main/docs/architecture/credential-injection.md)
