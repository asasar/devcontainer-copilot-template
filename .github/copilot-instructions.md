# Repository Instructions

## Scope

This repository is a reusable VS Code Dev Container template, not an application. Changes normally affect the container image, Dev Container lifecycle, installed tooling, or VS Code workspace defaults.

## Commands

There is no project build, test, lint, package manifest, or test suite in this repository. A single-test command is therefore not applicable.

- Rebuild and validate the template through VS Code: **Dev Containers: Rebuild and Reopen in Container**.
- To validate a modified shell script before rebuilding, run `bash -n .devcontainer/overlay/<script>.sh`.
- The Dev Container targets Ubuntu 22.04. Use its package-management and shell conventions when changing image setup.

## Architecture

- `.devcontainer/devcontainer.json` is the entrypoint for the template. It builds `Dockerfile.local`, declares Dev Container features, configures Docker access and environment variables, and invokes lifecycle hooks.
- `Dockerfile.local` starts from the VS Code Ubuntu base image, copies `overlay/` to `/tmp/overlay/`, then executes `overlay/install-packages.sh` during the image build.
- `overlay/install-packages.sh` installs OS-level dependencies, installs the Copilot CLI through `copilot-cli-install.sh`, and installs `tfenv`. The Copilot installer downloads architecture-specific release archives and accepts `VERSION` values of `latest`, `prerelease`, or a release version.
- After a container is created, `overlay/post-create-commands.sh` runs `npm install` only when the opened workspace has a `package.json`. `overlay/post-attach-commands.sh` applies Git/Zsh session configuration and prints host resource information.
- `.vscode/mcp.json` supplies optional GitHub, Azure DevOps, Context7, Terraform, Azure, Docker MCP Gateway, and workspace-scoped filesystem MCP server definitions. The Azure extension is also recommended through `.vscode/extensions.json`.
- `wikis-development/` documents GitHub/Azure authentication and using Podman as the Dev Container engine. Keep configuration changes aligned with these documented workflows.

## Repository Conventions

- Keep Dev Container configuration in JSONC style: comments and trailing commas are intentional in `.devcontainer/devcontainer.json`.
- Lifecycle scripts use Bash and are sourced/executed from `/tmp/overlay` in the built image. Preserve that location contract when reorganizing scripts.
- `install-packages.sh` is run as root during the image build and is intentionally fail-fast (`#!/usr/bin/env -S bash -e`). Avoid adding interactive package installation.
- Reuse `retry` from `overlay/common.sh` for installation steps that need retry behavior rather than duplicating retry loops.
- Treat `VERSION` in `copilot-cli-install.sh` as the supported override for pinning the Copilot CLI. Do not hard-code a release version elsewhere.
- The configured Docker feature expects Docker-compatible access. Preserve `host.docker.internal:host-gateway`, `LOCAL_WORKSPACE_FOLDER`, and `CONTAINER_WORKSPACE_FOLDER` unless the corresponding container-launch behavior is updated together.
- MCP entries must use VS Code input variables for secrets. Do not add tokens or credentials to `.vscode/mcp.json`, shell scripts, or documentation. Authentication guidance belongs in `wikis-development/Configure-GitHub-and-Azure-Auth.md`.
- Keep the filesystem MCP server limited to `${workspaceFolder}`; do not broaden its allowed path without an explicit repository need.
- The `docker-mcp` entry connects to Docker's MCP Gateway `default` profile and requires the Docker MCP CLI plugin and that profile to be configured in the active environment. Do not assume it is available merely because the Docker engine is installed.
- When changing available tooling, authentication, MCP servers, or Podman compatibility, update the matching guide under `wikis-development/` in the same change.
