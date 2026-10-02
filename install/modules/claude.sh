#! /usr/bin/env zsh
# vim: set tw=80 ts=2 sw=2 ft=zsh noet:
source "${0:A:h}/../common.sh"

heading "Installing claude stuff"

ensure_dir "${HOME}/.claude"

plugins=(
	superpowers
)

installed=$(claude plugins list --json)

for plugin in $plugins; do
	if ! jq --arg id "$plugin" '.[] | select(.id | startswith($id))' <<< "$installed" >/dev/null; then
		heading "Installing claude plugin: ${plugin}"
		claude plugins install "${plugin}"
	fi
done

link "${DOTFILES}/conf/claude/CLAUDE.md" "${HOME}/.claude/CLAUDE.md"

info "Disabling claude commit attribution"

CLAUDE_SETTINGS_TPL="${DOTFILES}/conf/claude/settings.json"
CLAUDE_SETTINGS="${HOME}/.claude/settings.json"

if [[ ! -f "${CLAUDE_SETTINGS}" ]]; then
	info "Creating ${CLAUDE_SETTINGS} from ${CLAUDE_SETTINGS_TPL}"
	cp "${CLAUDE_SETTINGS_TPL}" "${CLAUDE_SETTINGS}"
fi

jq '
  .attribution.commit = "" |
  .attribution.pr = "" |
  .attribution.sessionUrl = false |
  .extraKnownMarketplaces = {
    "claude-plugins-official" : {
      source: {
        source: "github",
        repo: "anthropics/claude-plugins-official"
      }
    }
  } |
  .theme = "dark" |
  .enabledPlugins = { "superpowers@claude-plugins-official": true }' \
  "${CLAUDE_SETTINGS}" > "${CLAUDE_SETTINGS}.tmp"
mv "${CLAUDE_SETTINGS}.tmp" "${CLAUDE_SETTINGS}"

#
#  "extraKnownMarketplaces": {
#    "claude-plugins-official": {
#      "source": {
#        "source": "github",
#        "repo": "anthropics/claude-plugins-official"
#      }
#    }
#  },
#  "theme": "dark",
#  "enabledPlugins": {
#    "superpowers@claude-plugins-official": true
#  },

info "You can configure claude by editing ${CLAUDE_SETTINGS}"
