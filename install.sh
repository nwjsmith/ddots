#!/usr/bin/env bash

curl -fsSL https://install.determinate.systems/nix |
  sh -s -- install linux --no-confirm --init none --determinate

. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

nix run home-manager/master -- switch --flake .
