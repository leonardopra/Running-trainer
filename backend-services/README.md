# Backend Services

This workspace is reserved for optional shared services.

Scope for v1:
- AI week enrichment facade
- future sync/export endpoints

Non-goals:
- no server dependency for core plan generation
- no mandatory authentication for offline use
- no requirement that a client be online to browse or log training

Target stack:
- TypeScript service
- OpenAPI-first contract implementation
- stateless endpoints where possible

First milestone:
1. implement `POST /v1/ai/enrich-week`
2. map backend errors to the same semantics used by the Flutter reference
3. keep response format aligned with `product-spec/contracts/openapi.yaml`
