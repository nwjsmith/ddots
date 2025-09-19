{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: {
            claude-code-bin = final.callPackage ./pkgs/claude-code-bin.nix {};
          })
        ];
      };
    in {
      homeConfigurations.wsdev = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [{
          home.username = "wsdev";
          home.homeDirectory = "/home/wsdev";
          home.stateVersion = "25.11";

          home.packages = with pkgs; [
            ghostty.terminfo
          ];

          programs.claude-code = {
            enable = true;
            package = pkgs.claude-code-bin;
            settings = {
              defaultMode = "bypassPermissions";
              includeCoAuthoredBy = false;
              theme = "light";
            };
          };
        }];
      };
    };
}
