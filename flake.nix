{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations.wsdev = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [{
          home.username = "wsdev";
          home.homeDirectory = "/home/wsdev";
          home.stateVersion = "25.11";

          home.packages = with pkgs; [
            ponysay
          ];
        }];
      };
    };
}
