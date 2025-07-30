#!/usr/bin/env bash

die() {
    echo "Error: $1" >&2
    exit 1
}

[[ -f /etc/debian_version ]] || die "Only Debian is supported"

apt update || die "Failed to update package list"
apt install -y curl jq || die "Failed to install dependencies"

if ! command -v gt &> /dev/null; then
    echo "Installing Graphite CLI..."
    
    graphite_info=$(curl -s https://registry.npmjs.org/@withgraphite/graphite-cli/stable) || die "Failed to fetch Graphite info"
    version=$(echo "${graphite_info}" | jq -r .version) || die "Failed to parse version"
    
    [[ -n "${version}" && "${version}" != "null" ]] || die "Invalid Graphite version"
    
    curl -L "https://github.com/withgraphite/homebrew-tap/releases/download/v${version}/gt-linux" -o /usr/local/bin/gt || die "Failed to download Graphite"
    chmod +x /usr/local/bin/gt || die "Failed to make Graphite executable"
fi

if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code..."
    
    curl -fsSL claude.ai/install.sh > /tmp/claude-install.sh || die "Failed to download Claude installer"
    bash /tmp/claude-install.sh || { rm -f /tmp/claude-install.sh; die "Failed to install Claude"; }
    rm -f /tmp/claude-install.sh
fi

echo "Done!"
