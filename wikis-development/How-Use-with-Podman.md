# Dev Containers with Podman Wiki

Welcome to the comprehensive guide on how to configure and run **VS Code Dev Containers** using **Podman** as the container engine on both **Windows** and **Linux**.

---

## Prerequisites

Before getting started, make sure you have the following installed on your machine:
* **Visual Studio Code** (latest version)
* **Dev Containers Extension** (`ms-vscode-remote.remote-containers`) from the VS Code Marketplace
* **Podman** (v5.0 or later)

---

## 1. Configuring VS Code to Use Podman

By default, the Dev Containers extension looks for the Docker CLI. You need to explicitly point VS Code to Podman by updating your user or workspace settings (`settings.json`).

Open your VS Code `settings.json` (Press `Ctrl+Shift+P` / `Cmd+Shift+P`, type `Preferences: Open User Settings (JSON)`) and add the following lines:

```json
{
  "dev.containers.dockerPath": "podman",
  "dev.containers.dockerComposePath": "podman-compose"
}
```

---

## 2. Platform-Specific Setup

### **Linux Setup**

On Linux, Podman runs natively as a daemonless, rootless container engine.

1. **Install Podman & Compose Provider:**
   Depending on your distribution:
   ```bash
   # Ubuntu / Debian
   sudo apt update && sudo apt install podman podman-compose -y

   # Fedora / RHEL
   sudo dnf install podman podman-compose -y
   ```

2. **Verify the Socket (Optional for Docker-compatible tools):**
   Podman provides a systemd service to expose a Docker-compatible API socket. Enable it if required:
   ```bash
   systemctl --user enable --now podman.socket
   ```
   The socket path will typically be located at:
   `unix:///run/user/$UID/podman/podman.sock`

3. **Handling Permissions (Rootless UID mapping):**
   Because Podman is rootless by default, file permission mapping between the host and container can sometimes cause issues. To prevent permission errors on mounted volumes, ensure your `devcontainer.json` includes proper user mapping arguments if necessary:
   ```json
   "runArgs": [
     "--userns=keep-id"
   ]
   ```

---

### **Windows Setup**

On Windows, Podman relies on a lightweight Linux virtual machine managed via **Podman Desktop** or the CLI.

1. **Install Podman and Initialize a Machine:**
   * Download and install [Podman Desktop](https://podman-desktop.io/) (recommended), which includes Podman and sets up a WSL-based or Hyper-V-based Podman machine.
   * Alternatively, via PowerShell:
     ```powershell
     winget install RedHat.Podman
     podman machine init
     podman machine start
     ```

2. **Enable Docker Compatibility Socket (Crucial for Windows):**
   * Open **Podman Desktop**.
   * Navigate to **Settings** -> **Docker Compatibility** (or *Third-Party Tool Compatibility*).
   * Enable the option so that tools looking for the Docker socket can transparently communicate with Podman.

3. **Verify Podman Connection:**
   Open PowerShell or Command Prompt and run:
   ```powershell
   podman info
   ```
   Ensure the machine status reports running properly.

---

## 3. Running Your Existing Dev Container

Since you already have your `.devcontainer` folder configured in your project repository, follow these steps to launch it:

1. Open your project folder in **VS Code**.
2. Open the Command Palette (`Ctrl+Shift+P` on Windows/Linux, `Cmd+Shift+P` on macOS).
3. Type and select:
   > **`Dev Containers: Reopen in Container`**
4. VS Code will trigger Podman to pull the required base images, build your container environment, and attach the workspace seamlessly.

---

## 4. Troubleshooting Common Issues

### **Issue 1: Volume Permission Errors (`EACCES` or Root Ownership)**
* **Cause:** Rootless Podman maps internal container UIDs differently from the host.
* **Fix:** Add `--userns=keep-id` to your `runArgs` inside `devcontainer.json`, or use the `:Z` suffix on volume mounts if applicable.

### **Issue 2: VS Code Cannot Connect to Container Engine**
* **Cause:** The Podman machine is not running (Windows/macOS) or the `dockerPath` setting is incorrect.
* **Fix:** Run `podman machine start` on Windows, or check that `"dev.containers.dockerPath": "podman"` is correctly configured in your VS Code settings.