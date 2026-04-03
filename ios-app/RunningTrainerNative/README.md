# iOS Module Layout

Suggested groups:
- `App`
- `Domain`
- `Data`
- `Features/Onboarding`
- `Features/Plan`
- `Features/Progress`
- `Features/Settings`
- `Features/Pace`
- `Notifications`
- `AI`

Recommended boundaries:
- pure Swift domain logic for the plan generator
- storage repositories isolated behind protocols
- contract mappers aligned with `product-spec/contracts`
