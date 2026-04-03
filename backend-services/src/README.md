# Backend Source

Suggested initial modules:
- `api/enrich-week.ts`
- `contracts/`
- `services/anthropic-client.ts`
- `services/retry-policy.ts`
- `mappers/week-enrichment-mapper.ts`

Required behavior:
- preserve local-first client semantics
- return stable DTOs
- do not leak vendor-specific payloads to clients
