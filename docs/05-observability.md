# Module 5: Observability (outline)

**Solo lab:** [Observe Agent & MCP server interactions](https://www.solo.io/mcp-academy/observe-agent-mcp-server)
(demos Solo's enterprise kagent; this module uses the open-source path).

## Plan

- [ ] Install a lightweight Prometheus and scrape agentgateway's metrics (requests, tokens per model).
- [ ] Run Jaeger locally and send agentgateway + kagent OpenTelemetry traces to it.
- [ ] Trace one chat end to end: agent → gateway → LLM → MCP tool.
