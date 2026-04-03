# iOS App

Target:
- SwiftUI
- SwiftData or Core Data for local storage
- Keychain for secrets
- local notifications after core flow parity

Implementation order:
1. DTOs and domain models
2. local persistence
3. onboarding
4. local plan generation
5. plan overview and workout detail
6. workout logging
7. settings
8. pace calculator
9. insights
10. notifications
11. AI enrichment

Rules:
- reuse the shared fixtures and contracts from `product-spec`
- keep the app fully usable without network
- preserve secure local storage for sensitive preferences
