{
  description = "Nix and Home Manager configuration for team Aplicações";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # $ nix flake update nixpkgs-latest
    nixpkgs-latest.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-latest,
      home-manager,
      agenix,
      ...
    }:
    let
      system = "x86_64-linux";
      username = builtins.getEnv "USER";
      version = "25.05";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      pkgsLatest = import nixpkgs-latest {
        inherit system;
        config.allowUnfree = true;
      };
      specialArgsBase = {
        inherit
          pkgs
          pkgsUnstable
          pkgsLatest
          version
          inputs
          username
          ;
      };
    in
    {
      homeManagerModules = {
        packages = ./home/pkgs.nix;
        modules = ./home/modules.nix;
        secrets = ./home/modules/agenix.nix;
        default = {
          imports = [
            ./home/pkgs.nix
            ./home/modules.nix
          ];
        };
      };

      homeConfigurations."${username}@${system}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = specialArgsBase;
        modules = [
          agenix.homeManagerModules.default
          ./home/core.nix
          ./home/modules.nix
          ./home/pkgs.nix
        ];
      };
    };
}
