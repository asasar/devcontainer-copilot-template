---
description: "Guidance for editing and reviewing Bicep infrastructure code."
applyTo: "infra/**"
---
# Infrastructure Review Guidance

## Principles
- Bicep only — never introduce Terraform or ARM JSON authored by hand.
- All resource names come from `infra/modules/naming.bicep` functions; never inline a resource name string in `main.bicep` or a module.
- One shared ACR (`crwcmshared`) across dev/test/prod — modules must not create a per-environment registry.
- `main.bicep` is `targetScope = 'subscription'`; per-environment `.bicepparam` files supply `env`, `imageTag`, and secrets.

## Review Checklist
1. New resources use the naming module — grep for any raw string resource name before approving.
2. Parameters have descriptions and safe defaults; secrets (`acrPassword`, etc.) are `@secure()`.
3. `az deployment sub what-if` output reviewed for unexpected resource replacement before applying to `test`/`prod`.
4. Container Apps ingress/target port matches the Traefik proxy container's listening port (spec §2).

## Testing
- Run: `az bicep build --file infra/main.bicep` (must compile with no errors)
- Run: `az deployment sub validate --location westeurope --template-file infra/main.bicep --parameters infra/main.dev.bicepparam`
