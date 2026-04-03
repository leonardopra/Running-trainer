# Android Module Layout

Suggested package structure:
- `app/src/main/java/.../core`
- `app/src/main/java/.../domain`
- `app/src/main/java/.../data`
- `app/src/main/java/.../features/onboarding`
- `app/src/main/java/.../features/plan`
- `app/src/main/java/.../features/progress`
- `app/src/main/java/.../features/settings`
- `app/src/main/java/.../features/pace`

Recommended adapters:
- Room entities for persisted plan data
- DTO mappers from `product-spec` contracts
- repository layer isolating storage and remote enrichment
