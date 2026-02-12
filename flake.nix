{
  description = "Nix and Home Manager configuration for team Aplicações";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # $ nix flake update nixpkgs-latest
    nixpkgs-latest.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-latest,
      home-manager,
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
      homeConfigurations."${username}@${system}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = specialArgsBase;
        modules = [
          ./home/core.nix
          ./home/modules.nix
          ./home/pkgs.nix
        ];
      };
    };
}
