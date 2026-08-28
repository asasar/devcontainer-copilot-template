---
description: 'Splits one exploratory task into N independent sub-issues (one per approach/component) under an Epic issue, for parallel sub-agent or Copilot coding agent dispatch.'
tools: ['search', 'read', 'github/*']
---
1. Confirm the sub-tasks are truly independent (no shared file edits, no
   sequential dependency) — if they aren't, this is the wrong prompt; use a
   normal dependency-ordered plan instead.
2. Create one Epic issue describing the overall goal and linking each sub-issue
   once created.
3. Create one sub-issue per independent approach/component, each with the full
   task text in the body, correct `type:*`/`priority:*`/`agent:*` labels, and
   the milestone.
4. Report all issue URLs and which agent role each was labeled for.
