---
description: "Guidance for editing and reviewing the React + Vite frontend."
applyTo: "frontend/src/**"
---
# Frontend Review Guidance

## Principles
- Map rendering uses `react-simple-maps` + the `world-atlas` topojson; feature `id` is the ISO 3166-1 numeric code string — keep it consistent with the backend.
- Keep components small and focused; extract a hook when a component mixes data-fetching with rendering logic.
- All API calls go through a single client module (`frontend/src/api/`), never inline `fetch` calls in components.

## Review Checklist
1. Loading and error states are handled for the country info panel (never a silent blank state).
2. New components have a corresponding Vitest + React Testing Library test.
3. No inline styles duplicating existing CSS/theme; prefer existing style patterns in the codebase.
4. Accessible: map regions and the info panel are reachable and readable via keyboard/screen reader where feasible.

## Testing
- Run: `cd frontend && npm test`
