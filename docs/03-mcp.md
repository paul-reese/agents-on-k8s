# Module 3: Tools via MCP (outline)

**Solo labs:** Build, run & deploy MCP servers to Kubernetes;
[Multiplex MCP servers & control auth policy](https://www.solo.io/mcp-academy/multiplex-mcp-servers-auth-kgateway-agentgateway);
Secure your MCP servers with OAuth.

## Plan

- [ ] Deploy an MCP server as an `MCPServer` resource (kmcp controller ships with kagent ≥ 0.7).
- [ ] Route it through agentgateway; multiplex two MCP servers behind one endpoint.
- [ ] Add an auth policy so only one agent's identity can call a given tool.
- [ ] Attach the gateway-fronted tools to an agent and test from the UI.

## References

- [kmcp: install controller](https://kagent.dev/docs/kmcp/deploy/install-controller)
