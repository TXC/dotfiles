#!/usr/bin/env bash
# devc - Open a directory in a VS Code Dev Container

usage() {
  cat << HELP
Usage: devc [OPTIONS] [PATH]

Open a directory in a VS Code Dev Container.
If PATH is omitted, the current directory is used.

Options:
  -h, --help    Show this help text and exit

Examples:
  devc                        Open current directory in Dev Container
  devc ~/projects/my-project  Open specific project in Dev Container

Requirements:
  - VS Code with "Dev Containers" extension installed
  - devcontainer CLI installed (npm install -g @devcontainers/cli)
  - A .devcontainer/ folder or .devcontainer.json in the target directory
HELP
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
esac

TARGET="${1:-.}"

if [[ ! -d "$TARGET" ]]; then
  echo "Error: '$TARGET' is not a directory" >&2
  echo "Run 'devc --help' for usage." >&2
  exit 1
fi

ABS=$(realpath "$TARGET")

# Find devcontainer.json
DEVCONTAINER_JSON=""
if   [[ -f "$ABS/.devcontainer/devcontainer.json" ]]; then
  DEVCONTAINER_JSON="$ABS/.devcontainer/devcontainer.json"
elif [[ -f "$ABS/.devcontainer.json" ]]; then
  DEVCONTAINER_JSON="$ABS/.devcontainer.json"
else
  echo "Warning: No .devcontainer config found in '$ABS'" >&2
fi

# Read workspaceFolder from devcontainer.json (strip // comments first)
WORKSPACE_FOLDER=""
if [[ -n "$DEVCONTAINER_JSON" ]]; then
  WORKSPACE_FOLDER=$(python3 - "$DEVCONTAINER_JSON" << 'PYEOF'
import json, re, sys
with open(sys.argv[1]) as f:
    content = re.sub(r'//[^\n]*', '', f.read())
try:
    d = json.loads(content)
    print(d.get("workspaceFolder", ""))
except Exception:
    pass
PYEOF
)
fi
WORKSPACE_FOLDER="${WORKSPACE_FOLDER:-/workspaces/$(basename "$ABS")}"

echo "Starting dev container in '$ABS'..."
devcontainer up --workspace-folder "$ABS" || {
  echo "Error: Failed to start dev container" >&2
  exit 1
}

# Build correct vscode-remote URI: authority is hex(localPath), path is container workspaceFolder
HEX=$(printf '%s' "$ABS" | xxd -p | tr -d '\n')
exec code --folder-uri "vscode-remote://dev-container+${HEX}${WORKSPACE_FOLDER}"
