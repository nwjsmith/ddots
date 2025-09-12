#!/usr/bin/env bash

curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux \
  --determinate \
  --extra-conf "sandbox = false" \
  --init none \
  --no-confirm

sudo chown -R wsdev:wsdev /nix

. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

nix run home-manager/master -- switch --flake .
