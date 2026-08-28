---
description: 'Scans the current session history, strips noise, and creates a GitHub issue body ready for GitHub Copilot Coding Agent, using this repo''s label/milestone taxonomy.'
tools: ['search', 'read', 'github/*']
---
1. Extract from the conversation: task overview, technical requirements
   (reference spec at `docs/superpowers/specs/2026-08-26-world-capitals-map-design.md`),
   in-flight work with file paths, known risks, next actions, success criteria.
2. Use the existing label taxonomy (`type:*`, `priority:*`, `agent:*`) and the
   `MVP: dev-ready deploy` milestone — never invent new labels.
3. Create the issue with `gh issue create` (or the `github` MCP tool), with the
   full task text in the body (never a link-only reference), per
   `.github/copilot-instructions.md`.
4. Report the issue URL back to the user. Do not assign to Copilot coding agent
   unless the user explicitly asks for that.
