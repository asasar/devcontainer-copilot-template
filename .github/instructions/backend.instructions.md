---
description: "Guidance for editing and reviewing FastAPI backend code."
applyTo: "backend/**/*.py"
---
# Backend Review Guidance

## Principles
- Keep routes thin: input validation + orchestration only; logic lives in `backend/app/services/`.
- Compute time server-side with `zoneinfo.ZoneInfo`; never trust a client-supplied timestamp.
- Country identifier is always the ISO 3166-1 **numeric** code as a string (e.g. `"250"`). Never alpha-2/alpha-3.
- No runtime network calls — the country/capital/timezone dataset is a static JSON file bundled with the service.

## Review Checklist
1. New endpoints return the documented response shape and correct HTTP status codes (404 for unknown country code).
2. Every new service function has a corresponding pytest test (happy path + at least one error case).
3. No hard-coded absolute paths; dataset path resolved relative to the package.
4. Pydantic models used for request/response validation — no raw dicts crossing the API boundary.

## Testing
- Run: `cd backend && python -m pytest -v`
