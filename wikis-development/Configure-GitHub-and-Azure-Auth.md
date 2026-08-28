# Configuring GitHub and Azure Tools in the Dev Container

This dev container includes the following tools by default:

- GitHub CLI (`gh`)
- GitHub Copilot (GitHub auth in VS Code)
- Azure CLI (`az`)
- Azure Developer CLI (`azd`)

This guide explains how to configure each tool using the appropriate authentication method, including Personal Access Tokens (PATs) for GitHub-related tools and sign-in flows for Azure tools.

---

## 1. GitHub CLI (`gh`)

The GitHub CLI supports authentication with a Personal Access Token (PAT) and also supports GitHub login flow.

### Check if GitHub CLI is installed

```bash
gh --version
```

### Authenticate with a Personal Access Token

If you already have a PAT, you can use it directly. Important: if `GH_TOKEN` is already set in the environment, `gh` will use that value for authentication instead of storing credentials. To store the token in the GitHub CLI credential cache, clear the environment variable first:

```bash
unset GH_TOKEN
printf '%s' "$GH_TOKEN" | gh auth login --with-token
```

Then verify the session:

```bash
gh auth status
```

You can also configure Git to use the same credentials:

```bash
gh auth setup-git
```

### Interactive GitHub sign-in

If you prefer the interactive flow instead of a PAT:

```bash
gh auth login -h github.com -w
```

This opens a browser-based sign-in flow. Once complete, GitHub CLI is authenticated for commands such as:

```bash
gh repo view
gh pr list
gh issue list
```

### Recommended PAT scopes

Use a PAT with the minimum required permissions:

- `repo` for private repositories
- `read:org` if you need organization visibility
- `workflow` if you work with GitHub Actions workflows
- `read:user` or `user` when needed for user-level access

> Keep PATs in a secure location and avoid committing them into source control.

---

## 2. GitHub Copilot

GitHub Copilot in VS Code is usually authenticated through your GitHub account and does not use a PAT directly in the editor experience.

### Typical setup in VS Code

1. Open VS Code.
2. Sign in to your GitHub account from the Accounts menu in the lower-left corner.
3. Open the GitHub Copilot extension and accept the sign-in flow.
4. Confirm the Copilot extension is enabled and active.

If you are already signed in through `gh` and your GitHub account has Copilot access, VS Code can usually pick up the session correctly after you sign into the GitHub account in the editor.

### Check GitHub authentication status

```bash
gh auth status
```

This is useful because the extension and the CLI share the same GitHub identity.

### Troubleshooting Copilot sign-in

- Make sure your GitHub account has an active Copilot subscription or organization entitlement.
- Sign out and sign back in from VS Code.
- Confirm the browser session is valid and the account is the correct one.
- Reopen the editor after changing accounts.

> Copilot itself is usually authenticated with GitHub OAuth, not a raw PAT. PATs are mainly used with `gh`, not directly by the Copilot extension UI.

---

## 3. Azure CLI (`az`)

The Azure CLI is authenticated through Azure identity, not a GitHub PAT. The normal workflow is `az login`.

### Check Azure CLI installation

```bash
az version
```

### Sign in interactively

```bash
az login
```

If you are in a remote environment or want a browserless approach:

```bash
az login --use-device-code
```

### Confirm the active account

```bash
az account show
```

### Set a subscription

```bash
az account list -o table
az account set --subscription "<subscription-name-or-id>"
```

### Azure authentication for service principals

If you are using a service principal instead of a user account:

```bash
az login --service-principal \
  --username "<app-id>" \
  --password "<client-secret>" \
  --tenant "<tenant-id>"
```

### Common Azure CLI auth patterns

- `az login` for interactive user login
- `az login --use-device-code` for headless or remote sessions
- `az account set` to select a subscription
- `az account get-access-token` to retrieve a token for scripts and APIs

---

## 4. Azure Developer CLI (`azd`)

`azd` uses Azure authentication and works with the same identity model as Azure CLI. It does not use a GitHub PAT.

### Check installation

```bash
azd version
```

### Sign in to Azure

```bash
azd auth login
```

For remote or browserless environments:

```bash
azd auth login --use-device-code
```

### Verify login

```bash
azd auth list
```

### Typical workflow

```bash
azd init
azd up
azd env new my-environment
```

### Troubleshooting

- Run `azd auth logout` and sign in again if credentials are stale.
- Compare with `az login` to confirm your Azure identity is valid.
- Make sure the right tenant and subscription are selected.

---

## 5. Recommended setup for this dev container

For this environment, a practical setup looks like this:

### GitHub

```bash
export GH_TOKEN="<your-github-token>"
echo "$GH_TOKEN" | gh auth login --with-token
gh auth status
gh auth setup-git
```

Then sign in to GitHub in VS Code for Copilot.

### Azure

```bash
az login --use-device-code
az account list -o table
az account set --subscription "<your-subscription>"
azd auth login --use-device-code
```

## 6. MCP servers

The workspace's `.vscode/mcp.json` defines optional MCP servers for GitHub, Azure DevOps, Context7, Terraform, Azure, Docker, and workspace files.

- The Azure MCP server uses the active Azure CLI or Azure Developer CLI identity. Sign in with `az login` or `azd auth login` before invoking Azure tools.
- The Docker MCP server connects through the Docker MCP Gateway's `default` profile. Install and configure the Docker MCP CLI plugin and profile in the environment that runs VS Code before using it.
- The filesystem MCP server is intentionally limited to the current workspace directory.
- Use the prompted VS Code inputs for server credentials. Do not place tokens in `mcp.json`.

---

## 7. Security recommendations

- Do not store PATs in the repository.
- Prefer environment variables or secure secret stores when possible.
- Rotate tokens regularly.
- Use the minimum required scopes and permissions.
- For Azure, prefer managed identity, service principals, or developer sign-in flows rather than embedding secrets directly in scripts.

---

## 8. Quick reference

### GitHub CLI

```bash
gh auth login -h github.com -w
# or
export GH_TOKEN="..."
echo "$GH_TOKEN" | gh auth login --with-token
```

### Copilot

- Sign in through VS Code GitHub authentication
- Use the same GitHub account that has Copilot access

### Azure CLI

```bash
az login --use-device-code
az account set --subscription "<subscription-id-or-name>"
```

### Azure Developer CLI

```bash
azd auth login --use-device-code
```

---

This setup is enough to use GitHub and Azure from the dev container in a secure and repeatable way.
