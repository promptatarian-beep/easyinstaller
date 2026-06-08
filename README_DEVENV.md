# easyinstaller in a Codespace / Devcontainer

This workspace includes a devcontainer for developing the easyinstaller Python tool with all dependencies pre-installed.

## Quick Start (Codespaces / Devcontainer)

1. Open this repository in GitHub Codespaces or VS Code Remote - Containers.
2. The container will be built from `.devcontainer/Dockerfile` with Python and dependencies.
3. In the container, run VS Code tasks (Terminal > Run Task):
   - **"easyinstaller: setup config"** — Create config.yaml from template
   - **"easyinstaller: build installer"** — Build an installer using config.yaml
   - **"easyinstaller: run tests"** — Run test suite (if available)

## Manual Setup

```bash
pip install ruamel.yaml
cp config_sample.yaml config.yaml
python3 build.py --config config.yaml
```

## Files

- `.devcontainer/Dockerfile` — Python 3.10 + dev tools
- `.devcontainer/devcontainer.json` — VS Code devcontainer config
- `.devcontainer/post-create.sh` — Auto-install dependencies
- `.vscode/tasks.json` — VS Code task shortcuts
- `config_sample.yaml` — Template configuration

## Customization

Edit `config.yaml` to specify:
- Application name, version, entry point
- Installation paths
- Platform-specific settings (Windows/Mac/Linux)

Then run the **"easyinstaller: build installer"** task.

