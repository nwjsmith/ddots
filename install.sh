#!/usr/bin/env bash

die() {
    echo "Error: $1" >&2
    exit 1
}

[[ -f /etc/debian_version ]] || die "Only Debian is supported"

sudo apt update || die "Failed to update package list"
sudo apt install -y curl jq || die "Failed to install dependencies"

if ! command -v gt &> /dev/null; then
    echo "Installing Graphite CLI..."
    
    graphite_info=$(curl -s https://registry.npmjs.org/@withgraphite/graphite-cli/stable) || die "Failed to fetch Graphite info"
    version=$(echo "${graphite_info}" | jq -r .version) || die "Failed to parse version"
    
    [[ -n "${version}" && "${version}" != "null" ]] || die "Invalid Graphite version"
    
    sudo curl -L "https://github.com/withgraphite/homebrew-tap/releases/download/v${version}/gt-linux" -o /usr/local/bin/gt || die "Failed to download Graphite"
    sudo chmod +x /usr/local/bin/gt || die "Failed to make Graphite executable"
fi

if ! grep -q "export PATH=\"\${HOME}/.local/bin:\${PATH}\"" ~/.bash_profile 2>/dev/null; then
    echo "export PATH=\"\${HOME}/.local/bin:\${PATH}\"" >> ~/.bash_profile
fi

if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code..."
    
    curl -fsSL claude.ai/install.sh > /tmp/claude-install.sh || die "Failed to download Claude installer"
    bash /tmp/claude-install.sh || { rm -f /tmp/claude-install.sh; die "Failed to install Claude"; }
    rm -f /tmp/claude-install.sh
fi

if [[ -x "${HOME}/.local/bin/claude" ]]; then
    "${HOME}/.local/bin/claude" config set -g theme light || echo "Warning: Failed to set Claude theme"
    "${HOME}/.local/bin/claude" config set -g editorMode vim || echo "Warning: Failed to set Claude editorMode"
fi

if [[ -x /usr/local/bin/gt ]] && [[ -x "${HOME}/.local/bin/claude" ]]; then
    echo "Adding Graphite MCP to Claude..."
    "${HOME}/.local/bin/claude" mcp add graphite /usr/local/bin/gt mcp || echo "Warning: Failed to add Graphite MCP"
fi

echo "https://app.graphite.dev/settings/cli"
