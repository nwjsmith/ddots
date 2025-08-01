#!/usr/bin/env bash

die() {
    echo "Error: $1" >&2
    exit 1
}

[[ -f /etc/debian_version ]] || die "Only Debian is supported"

sudo apt-get update || die "Failed to update package list"
sudo apt-get install -y curl jq || die "Failed to install dependencies"

# Install GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "Installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg || die "Failed to add GitHub CLI keyring"
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null || die "Failed to add GitHub CLI repository"
    sudo apt-get update || die "Failed to update package list for GitHub CLI"
    sudo apt-get install -y gh || die "Failed to install GitHub CLI"
fi

if [[ ! -x /usr/local/bin/gt ]]; then
    echo "Installing Graphite CLI..."
    
    graphite_info=$(curl -s https://registry.npmjs.org/@withgraphite/graphite-cli/stable) || die "Failed to fetch Graphite info"
    version=$(echo "${graphite_info}" | jq -r .version) || die "Failed to parse version"
    
    [[ -n "${version}" && "${version}" != "null" ]] || die "Invalid Graphite version"
    
    # Detect architecture
    arch=$(uname -m)
    if [[ "${arch}" == "aarch64" || "${arch}" == "arm64" ]]; then
        binary_name="gt-linux-arm64"
    else
        binary_name="gt-linux"
    fi
    
    sudo curl -L "https://github.com/withgraphite/homebrew-tap/releases/download/v${version}/${binary_name}" -o /usr/local/bin/gt || die "Failed to download Graphite"
    sudo chmod +x /usr/local/bin/gt || die "Failed to make Graphite executable"
fi

if ! grep -q "export PATH=\"\${HOME}/.local/bin:\${PATH}\"" ~/.bash_profile 2>/dev/null; then
    echo "export PATH=\"\${HOME}/.local/bin:\${PATH}\"" >> ~/.bash_profile
fi

if [[ ! -x "${HOME}/.local/bin/claude" ]]; then
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
    # Check if Graphite MCP is already configured
    if ! "${HOME}/.local/bin/claude" mcp list 2>/dev/null | grep -q "graphite: /usr/local/bin/gt mcp"; then
        echo "Adding Graphite MCP to Claude..."
        "${HOME}/.local/bin/claude" mcp add graphite /usr/local/bin/gt mcp || echo "Warning: Failed to add Graphite MCP"
    else
        echo "Graphite MCP already configured"
    fi
fi

echo "https://app.graphite.dev/settings/cli"
