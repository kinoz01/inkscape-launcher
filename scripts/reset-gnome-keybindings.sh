#!/usr/bin/env bash
# Resets GNOME keyboard shortcut schemas so every binding is re-enabled.
# Optionally pass a schema directory (for portable AppImage builds) as $1.

set -euo pipefail

SCHEMAS=(
  "org.gnome.shell.keybindings"
  "org.gnome.settings-daemon.plugins.media-keys"
  "org.gnome.desktop.wm.keybindings"
  "org.gnome.mutter.keybindings"
)

if [[ $# -gt 0 && -n "${1:-}" ]]; then
  if [[ ! -d "$1" ]]; then
    echo "Schema directory '$1' does not exist." >&2
    exit 1
  fi
  export GSETTINGS_SCHEMA_DIR="$1${GSETTINGS_SCHEMA_DIR:+:$GSETTINGS_SCHEMA_DIR}"
fi

reset_bindings_for_schema() {
  local schema="$1"
  echo "Resetting keybindings in $schema…"
  while IFS= read -r key; do
    # Only reset array-of-string bindings (keyboard shortcuts).
    if gsettings range "$schema" "$key" 2>/dev/null | head -n 1 | grep -q "type as"; then
      gsettings reset "$schema" "$key"
    fi
  done < <(gsettings list-keys "$schema")
}

for schema in "${SCHEMAS[@]}"; do
  reset_bindings_for_schema "$schema"
done

echo "Ensuring overview/meta key is active…"
gsettings reset org.gnome.mutter overlay-key

echo "GNOME keybindings have been restored to their defaults."
